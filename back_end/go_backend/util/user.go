package util

import (
	"errors"
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/iot"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/google/uuid"
	"github.com/joho/godotenv"
)

type User struct {
	Name     string
	Password string
	// ID          string
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
func CreateUser(user User) (error, User) {

	godotenv.Load(".env")
	// req.User = uuid.New().String()

	phone_id := uuid.New().String()
	err, phone_cert := createIotCred(phone_id, "phone")
	if err != nil {
		return err, User{}
	}

	esp_id := uuid.New().String()
	err, esp_cert := createIotCred(esp_id, "device")
	if err != nil {
		return err, User{}
	}

	topicA := "users/" + phone_cert.Thing_name + "/phone/data"
	topicB := "users/" + phone_cert.Thing_name + "/devices/" + esp_cert.Thing_name + "data"

	phone_cert.Pub_topic, phone_cert.Sub_topic = topicA, topicB
	esp_cert.Pub_topic, esp_cert.Sub_topic = topicB, topicA

	user.Mobile_cert = phone_cert
	user.ESP_cert = esp_cert

	// Create database entry
	if err := createDatabaseEntry(user); err != nil {
		return err, User{}
	}

	// Create S3 folder
	if err := createS3Folder(user.Name); err != nil {
		return err, User{}
	}
	return nil, user
}

func UpdateUser(user User) error {
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("us-east-2"),
		Credentials: credentials.NewStaticCredentials(os.Getenv("AWS_SESSION_ACCESS_KEY_ID"), os.Getenv("AWS_SESSION_SECRET_ACCESS_KEY"), ""),
	})
	if err != nil {
		return errors.New("failed to create AWS session")
	}

	svc := dynamodb.New(sess)
	tableName := "ESP-Assistant-DB" // Replace with your actual table name

	// Define UpdateExpression to target specific fields
	updateExpression := "SET #mobile_cert = :mobile_cert, #esp_cert = :esp_cert, Config_gen = :config_gen"

	eav := map[string]*dynamodb.AttributeValue{} // Expression Attribute Values
	ean := map[string]*string{}                  // Expression Attribute Names

	mobile_cert, err0 := dynamodbattribute.MarshalMap(user.Mobile_cert)
	esp_cert, err1 := dynamodbattribute.MarshalMap(user.ESP_cert)
	config_gen, err2 := dynamodbattribute.MarshalList(user.Config_gen)
	if err0 != nil {
		return err0
	}
	if err1 != nil {
		return err1
	}
	if err2 != nil {
		return err2
	}

	// Add placeholders for updated values
	eav[":mobile_cert"] = &dynamodb.AttributeValue{M: mobile_cert} // Assuming Cert is a struct
	eav[":esp_cert"] = &dynamodb.AttributeValue{M: esp_cert}       // Assuming Cert is a struct
	eav[":config_gen"] = &dynamodb.AttributeValue{L: config_gen}   // Convert Config slice to AV list

	// Define ExpressionAttributeNames
	ean["#mobile_cert"] = aws.String("Mobile_cert")
	ean["#esp_cert"] = aws.String("ESP_cert")

	// Key definition for update operation
	key := map[string]*dynamodb.AttributeValue{}
	key["Name"] = &dynamodb.AttributeValue{S: aws.String(user.Name)} // Replace "UserID" with your actual primary key

	// Build UpdateItem Input
	input := &dynamodb.UpdateItemInput{
		TableName:                 aws.String(tableName),
		Key:                       key,
		UpdateExpression:          aws.String(updateExpression),
		ExpressionAttributeValues: eav,
		ExpressionAttributeNames:  ean, // Add this line
	}

	_, err = svc.UpdateItem(input)
	if err != nil {
		return err
	}

	return nil
}

func GetUser(userID string) (error, User) {
	godotenv.Load(".env")
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String("us-east-2"),
		Credentials: credentials.NewStaticCredentials(os.Getenv("AWS_SESSION_ACCESS_KEY_ID"), os.Getenv("AWS_SESSION_SECRET_ACCESS_KEY"), ""),
	})
	if err != nil {
		return err, User{}
	}
	svc := dynamodb.New(sess)

	// Define the key for the user
	key := make(map[string]*dynamodb.AttributeValue)
	key["Name"] = &dynamodb.AttributeValue{S: aws.String(userID)}

	// Get user item from DynamoDB
	result, err := svc.GetItem(&dynamodb.GetItemInput{
		TableName: aws.String("ESP-Assistant-DB"),
		Key:       key,
	})
	if err != nil {
		return err, User{}
	}

	// Check if user item exists
	if result.Item == nil {
		return errors.New("User doesn't exist"), User{}
	}

	// Unmarshal the result.Item into a User struct
	var userItem User
	err = dynamodbattribute.UnmarshalMap(result.Item, &userItem)
	if err != nil {
		return errors.New("Failed to unmarshal user item"), User{}
	}
	return nil, userItem
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
