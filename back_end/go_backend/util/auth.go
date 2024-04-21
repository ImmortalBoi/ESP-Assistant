package util

import (
	"errors"
	"fmt"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/iot"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/joho/godotenv"
)

type User struct {
	Name     string
	Password string
	// User        string
	Mobile_cert Cert
	ESP_cert    Cert
	Config_gen  []Config
}

type Cert struct {
	Thing_name       string
	Pub_topic        string
	Sub_topic        string
	ID               string
	AWS_CERT_CRT     string
	AWS_CERT_PRIVATE string
}

// CreateUser creates a new user entry
func CreateUser(c *gin.Context) {
	var req User
	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	godotenv.Load(".env")
	// req.User = uuid.New().String()

	phone_id := uuid.New().String()
	err, phone_cert := createIotCred(phone_id, "phone")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	esp_id := uuid.New().String()
	err, esp_cert := createIotCred(esp_id, "device")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	topicA := "users/" + phone_cert.Thing_name + "/phone/data"
	topicB := "users/" + phone_cert.Thing_name + "/devices/" + esp_cert.Thing_name + "data"

	phone_cert.Pub_topic, phone_cert.Sub_topic = topicA, topicB
	esp_cert.Pub_topic, esp_cert.Sub_topic = topicB, topicA

	req.Mobile_cert = phone_cert
	req.ESP_cert = esp_cert

	// Create database entry
	if err := createDatabaseEntry(req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Create S3 folder
	if err := createS3Folder(req.Name); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": req})
}

// CheckUser checks user credentials (implementation omitted)
func CheckUser(c *gin.Context) {
	godotenv.Load(".env")
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("us-east-2"),
		Credentials: credentials.NewStaticCredentials(os.Getenv("AWS_SESSION_ACCESS_KEY_ID"), os.Getenv("AWS_SESSION_SECRET_ACCESS_KEY"), ""),
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	svc := dynamodb.New(sess)
	user := c.Param("user")
	password := c.Param("password")

	// Define the key for the user
	key := make(map[string]*dynamodb.AttributeValue)
	key["Name"] = &dynamodb.AttributeValue{S: aws.String(user)}

	// Get user item from DynamoDB
	result, err := svc.GetItem(&dynamodb.GetItemInput{
		TableName: aws.String("ESP-Assistant-DB"),
		Key:       key,
	})
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if user item exists
	if result.Item == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User doesn't exist"})
		return
	}

	// Unmarshal the result.Item into a User struct
	var userItem User
	err = dynamodbattribute.UnmarshalMap(result.Item, &userItem)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to unmarshal user item"})
		return
	}

	// Compare the password from the request with the password from the unmarshalled item
	if userItem.Password != password {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Password isn't right"})
		return
	}

	// Return the resultant unmarshalled item
	c.JSON(http.StatusOK, userItem)
	return
}

// createDatabaseEntry creates a DynamoDB entry for the user
func createDatabaseEntry(user User) error {
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("us-east-2"),
		Credentials: credentials.NewStaticCredentials(os.Getenv("AWS_SESSION_ACCESS_KEY_ID"), os.Getenv("AWS_SESSION_SECRET_ACCESS_KEY"), ""),
	})
	if err != nil {
		return errors.New("failed to create AWS session")
	}

	svc := dynamodb.New(sess)
	tableName := "ESP-Assistant-DB" // Replace with your actual table name

	av, err := dynamodbattribute.MarshalMap(user)
	if err != nil {
		return errors.New("Got error marshalling new User: " + err.Error())
	}

	// Build the DynamoDB input object with user data
	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(tableName),
	}

	_, err = svc.PutItem(input)
	if err != nil {
		return fmt.Errorf("failed to create DynamoDB entry: %v", err)
	}

	return nil
}

// createIotCred creates AWS IoT credentials for the user
func createIotCred(device_id string, deviceType string) (error, Cert) {
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("eu-central-1"),
		Credentials: credentials.NewStaticCredentials(os.Getenv("AWS_SESSION_ACCESS_KEY_ID"), os.Getenv("AWS_SESSION_SECRET_ACCESS_KEY"), ""),
	})
	if err != nil {
		return errors.New("failed to create AWS session"), Cert{}
	}

	svc := iot.New(sess)

	// Define the IoT thing parameters
	var thingTypeName string
	var attributeName string

	switch deviceType {
	case "device":
		thingTypeName = "user_esp"
		attributeName = "device_id"
	case "phone":
		thingTypeName = "user_phone"
		attributeName = "user_id"
	default:
		return fmt.Errorf("unsupported device type: %s", deviceType), Cert{}
	}

	createThingInput := &iot.CreateThingInput{
		ThingName:        aws.String("device_" + device_id),
		AttributePayload: &iot.AttributePayload{Attributes: map[string]*string{attributeName: &device_id}},
		ThingTypeName:    aws.String(thingTypeName),
	}

	thing, err := svc.CreateThing(createThingInput)
	if err != nil {
		return fmt.Errorf("failed to create IoT thing: %v", err), Cert{}
	}

	createKeysAndCertificateInput := &iot.CreateKeysAndCertificateInput{
		SetAsActive: aws.Bool(true),
	}
	keysAndCert, err := svc.CreateKeysAndCertificate(createKeysAndCertificateInput)
	if err != nil {
		return fmt.Errorf("failed to create Keys and Certificate: %v", err), Cert{}
	}

	attachPolicyInput := &iot.AttachPolicyInput{
		PolicyName: aws.String("ESP32_Pol"),
		Target:     aws.String(*keysAndCert.CertificateArn),
	}
	// Attach policy (assuming AttachPolicy and AttachThingPrincipal are defined elsewhere)
	_, err = svc.AttachPolicy(attachPolicyInput) // Replace "ESP32_Pol" with your policy name
	if err != nil {
		return fmt.Errorf("failed to attach policy: %v", err), Cert{}
	}

	attachThingPrincipalInput := &iot.AttachThingPrincipalInput{
		Principal: keysAndCert.CertificateArn,
		ThingName: thing.ThingName,
	}
	_, err = svc.AttachThingPrincipal(attachThingPrincipalInput)
	if err != nil {
		return fmt.Errorf("failed to attach certificate to thing: %v", err), Cert{}
	}

	return nil, Cert{Thing_name: *thing.ThingName, ID: device_id, AWS_CERT_CRT: *keysAndCert.CertificatePem, AWS_CERT_PRIVATE: *keysAndCert.KeyPair.PrivateKey}
}

// createS3Folder creates an S3 folder for the user
func createS3Folder(userid string) error {
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("eu-central-1"),
		Credentials: credentials.NewStaticCredentials(os.Getenv("AWS_SESSION_ACCESS_KEY_ID"), os.Getenv("AWS_SESSION_SECRET_ACCESS_KEY"), ""),
	})
	if err != nil {
		return errors.New("failed to create AWS session")
	}

	svc := s3.New(sess)
	bucketName := "esp32-assistant-bucket" // Replace with your S3 bucket name

	// Create the S3 folder with appropriate permissions (refer to AWS documentation)
	_, err = svc.PutObject(&s3.PutObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String("User-sketches/" + userid + "/"), // Add trailing slash for folder
		ACL:    aws.String("public-read"),                   // Grant read access to authenticated user
	})
	if err != nil {
		return fmt.Errorf("failed to create S3 folder: %v", err)
	}

	return nil
}
