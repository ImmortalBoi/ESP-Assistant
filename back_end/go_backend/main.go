package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func sendJSONtoS3(data json.RawMessage) (int, string) {
	if err := godotenv.Load(); err != nil {
		fmt.Println("Error loading .env file")
	}

	aws_access_key_id := os.Getenv("AWS_SECRET_KEY_ID")
	region := os.Getenv("REGION")
	aws_secret_access_key := os.Getenv("AWS_SECRET_ACCESS_KEY")
	token := ""
	creds := credentials.NewStaticCredentials(aws_access_key_id, aws_secret_access_key, token)
	_, err := creds.Get()
	if err != nil {
		fmt.Println("Error getting credentials:", err)
		return 4, "Error getting credentials"
	}
	cfg := aws.NewConfig().WithRegion(region).WithCredentials(creds)

	sess, err := session.NewSession(cfg)
	if err != nil {
		fmt.Println("Error creating session:", err)
		return 1, "Error creating session"
	}

	svc := s3.New(sess)

	// Marshal the JSON data
	jsonBytes, err := json.Marshal(data)
	if err != nil {
		fmt.Println("Error marshaling JSON:", err)
		return 2, "Error marshaling JSON"
	}

	bucket := "esp32-assistant-bucket"
	key := "ESP32-Peripheral-Dump/test.json" // Use a .json extension for clarity

	// Upload the JSON bytes to S3
	_, err = svc.PutObject(&s3.PutObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
		Body:   bytes.NewReader(jsonBytes),
	})
	if err != nil {
		fmt.Println("Error uploading file:", err)
		return 3, "Error uploading file"
	}

	fmt.Println("JSON file uploaded successfully!")
	return 0, "Success"
}

// TODO change the payload to fit the config type we decided
type Payload struct {
	Key string `json:"key"`
}

func main() {
	router := gin.Default()
	router.GET("/", getRoutes)
	router.POST("/config", postConfig)

	router.Run(":8080")
}

func getRoutes(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"routes": []string{"/config [POST]", "/ [GET]"},
	})
}

// postConfig adds an album from JSON received in the request body.
func postConfig(c *gin.Context) {
	// This binds the received information to a specified type where it denies anything that doesn't look like it
	// TODO replace this with the correct code
	// var req Payload
	// if err := c.BindJSON(&req); err != nil {
	// 	c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
	// 	return
	// }
	// c.JSON(http.StatusCreated, req)

	// Read the body into a byte slice
	bodyBytes, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Error reading request body"})
		return
	}

	// Convert the byte slice to a string
	bodyString := json.RawMessage(string(bodyBytes))

	if errNo, errStr := sendJSONtoS3(bodyString); errNo != 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": errStr})
		return
	}

	// Return the string
	c.JSON(http.StatusOK, gin.H{"receivedData": bodyString})
}
