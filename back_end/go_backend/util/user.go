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

	codeDataEmpty := []string{
		"ArduinoJson", //libraries
		`Preferences preferences;
WebServer server(80);
WiFiClientSecure espClient = WiFiClientSecure();
HTTPClient http;
PubSubClient client(espClient);
long contentLength = 0;
bool isValidContentType = false;
StaticJsonDocument<200> receivedJson;`, //global Declarations
		`void publishMessage() {
  StaticJsonDocument<200> sentJson;
  sentJson["hello"] = "hello";
  char jsonBuffer[512];
  serializeJson(sentJson, jsonBuffer);
  Serial.println("Message published!");
  client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
}`, //publishMessage
		`void messageHandler(char* topic, byte* payload, unsigned int length) {
	Serial.print("incoming: ");
	Serial.println(topic);
	String tpc(topic);
	deserializeJson(receivedJson, payload);
	Serial.println(tpc);
	const char* type = receivedJson["type"];
	String typ(type);
	const uint8_t value = receivedJson["value"];
	const uint8_t pin = receivedJson["pin"];
	const int index = receivedJson["update"];

	if (index) {
		updatefunction(index);
	}
		  }`, //messageHandler
		`void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  WiFi.disconnect();
  preferences.begin("my-app", false);
  wifiSetup();
  connectAWS();
  printSuccess();
  pinMode(2, OUTPUT);
  digitalWrite(2, HIGH);
}`, //Setup
	}

	codeDataCar := []string{
		`WebServer
uri/UriBraces
Update
WiFi
HTTPClient
Preferences
PubSubClient
ArduinoJson`, //libraries
		`Preferences preferences;
WebServer server(80);
WiFiClientSecure espClient = WiFiClientSecure();
HTTPClient http;
PubSubClient client(espClient);
long contentLength = 0;
bool isValidContentType = false;
StaticJsonDocument<200> receivedJson;
#define ENA_PIN 14
#define IN1_PIN 27
#define IN2_PIN 26
#define IN3_PIN 25
#define IN4_PIN 33
#define ENB_PIN 32`, //global declarations
		`
void publishMessage() {
	StaticJsonDocument<200> sentJson;
	sentJson["hello"] = "hello";
	char jsonBuffer[512];
	serializeJson(sentJson, jsonBuffer);
	Serial.println("Message published!");
	client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
}`, //publishMessage
		`
void messageHandler(char* topic, byte* payload, unsigned int length) {
  Serial.print("incoming: ");
  Serial.println(topic);
  String tpc(topic);
  deserializeJson(receivedJson, payload);
  Serial.println(tpc);
  const char* type = receivedJson["type"];
  String typ(type);
  const uint8_t value = receivedJson["value"];
  const uint8_t pin = receivedJson["pin"];
  const int index = receivedJson["update"];

  if (index) {
    updatefunction(index);
  }

  if (typ.equals("IN_PIN")) {
    digitalWrite(pin, value);
  }

  if (typ.equals("LED_PIN")) {
    digitalWrite(pin, value);
  }
}
		`, //messageHandler
		`void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  WiFi.disconnect();
  preferences.begin("my-app", false);
  wifiSetup();
  connectAWS();
  printSuccess();
  pinMode(2, OUTPUT);
  digitalWrite(2, HIGH);
  pinMode(ENA_PIN, OUTPUT);
  pinMode(IN1_PIN, OUTPUT);
  pinMode(IN2_PIN, OUTPUT);
  pinMode(IN3_PIN, OUTPUT);
  pinMode(IN4_PIN, OUTPUT);
  pinMode(ENB_PIN, OUTPUT);
  digitalWrite(ENB_PIN, HIGH);
  digitalWrite(ENA_PIN, HIGH);
}`, //setup
	}
	codeDataWaterTank := []string{
		`DHT11`, //libraries
		`Preferences preferences;
WebServer server(80);
WiFiClientSecure espClient = WiFiClientSecure();
HTTPClient http;
PubSubClient client(espClient);
long contentLength = 0;
bool isValidContentType = false;
StaticJsonDocument<200> receivedJson;
StaticJsonDocument<200> sentJson;
#define TRIG_PIN 5
#define ECHO_PIN 18
#define SOUND_SPEED 0.034
#define TANK_HEIGHT_CM 100
#define relay 14`, //global declarations
		`void publishMessage(String message, float temp, float humidity) {
  sentJson["temp"] = temp;
  sentJson["humidity"] = humidity;
  sentJson["message"] = message;
  char jsonBuffer[512];
  serializeJson(sentJson, jsonBuffer);  // print to client

  Serial.println("Message published!");
  client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
} `, //publishMessage
		`void messageHandler(char* topic, byte* payload, unsigned int length) { 
  Serial.print("incoming: ");
  Serial.println(topic);
  String tpc(topic);
  deserializeJson(receivedJson, payload);
  Serial.println(tpc);
  const char* type = receivedJson["type"];
  String typ(type);
  const uint8_t value = receivedJson["value"];
  const uint8_t pin = receivedJson["pin"];
  uint8_t active = receivedJson["active"];
  const uint8_t event = receivedJson["event"];
  const int index = receivedJson["update"];

  if (receivedJson["update"] > -1) {
    updatefunction(receivedJson["update"]);
  }

  while (1 == active) {
    // Clear the TRIG_PIN by setting it LOW:
    digitalWrite(TRIG_PIN, LOW);
    delayMicroseconds(5);

    // Trigger the sensor by setting the TRIG_PIN high for 10 microseconds:
    digitalWrite(TRIG_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG_PIN, LOW);

    // Read the time it takes for the pulse to return:
    long duration = pulseIn(ECHO_PIN, HIGH);

    // Calculate the distance:
    float distance = (duration * SOUND_SPEED) / 2;

    // Calculate the water level:
    float waterLevel = TANK_HEIGHT_CM - distance;

    // Print the distance and water level to the Serial Monitor:
    Serial.print("Distance to water surface: ");
    Serial.print(distance);
    Serial.println(" cm");

    Serial.print("Water Level: ");
    Serial.print(waterLevel);
    Serial.println(" cm");
    if (waterLevel > event) {
      digitalWrite(relay, LOW);
    } else {
      digitalWrite(relay, HIGH);
    }

    // Delay a bit before the next measurement:
    client.loop();
    active = receivedJson["active"];
    delay(1000);
  }

  if (typ.equals("PUMP_PIN")) {
    digitalWrite(pin, value);
  }

  if (typ.equals("LED_PIN")) {
    digitalWrite(pin, value);
  }
}`, //messageHandler
		`void setup() { 
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  WiFi.disconnect();
  preferences.begin("my-app", false);
  wifiSetup();
  connectAWS();
  printSuccess();
  pinMode(2, OUTPUT);
  digitalWrite(2, HIGH);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(relay, OUTPUT);

}`, //setup
	}
	codeDataThermo := []string{
		`DHT11`, //libraries
		`Preferences preferences;
WebServer server(80);
WiFiClientSecure espClient = WiFiClientSecure();
HTTPClient http;
PubSubClient client(espClient);
long contentLength = 0;
bool isValidContentType = false;
StaticJsonDocument<200> receivedJson;
StaticJsonDocument<200> sentJson;
#define DHTPIN 27
#define DHTTYPE DHT11
#define LED_PIN 21
#define LDR_PIN 32
#define ENA_PIN 21
#define IN1_PIN 23
#define IN2_PIN 22
DHT dht(DHTPIN, DHTTYPE);
float humidity = 0.0;
float temp = 0.0;`, //global declarations
		`void publishMessage(String message, float temp, float humidity) {
  sentJson["temp"] = temp;
  sentJson["humidity"] = humidity;
  sentJson["message"] = message;
  char jsonBuffer[512];
  serializeJson(sentJson, jsonBuffer);  // print to client

  Serial.println("Message published!");
  client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
}  //end of fully-generated function
`, //publishMessage
		`void messageHandler(char* topic, byte* payload, unsigned int length) { 
  Serial.print("incoming: ");
  Serial.println(topic);
  String tpc(topic);
  deserializeJson(receivedJson, payload);
  Serial.println(tpc);
  const char* type = receivedJson["type"];
  String typ(type);
  const uint8_t value = receivedJson["value"];
  const uint8_t pin = receivedJson["pin"];
  uint8_t active = receivedJson["active"];
  const uint8_t event = receivedJson["event"];
  const int index = receivedJson["update"];

  if (index) {
    updatefunction(index);
  }
  if(value == 1){
    digitalWrite(4, LOW);
  }
  while (1 == active) {
    humidity = dht.readHumidity();
    temp = dht.readTemperature();
    float f = dht.readTemperature(true);
    int LDRState = digitalRead(LDR_PIN);
    Serial.println(LDRState);
    Serial.println(humidity);
    Serial.println(temp);
    if (isnan(humidity) || isnan(temp) || isnan(f)) {
      publishMessage("Sensor read failed", -1.0, -1.0);
      return;
    }
    if (event > temp) {
      Serial.println("Fan is ON");
      digitalWrite(IN1_PIN, LOW);
      digitalWrite(IN2_PIN, HIGH);
    } else {
      Serial.println("Fan is OFF");
      digitalWrite(IN1_PIN, LOW);
      digitalWrite(IN2_PIN, LOW);
    }
    if (LDRState == HIGH) {
      // turn LED on:
      digitalWrite(LED_PIN, HIGH);
    } else {
      // turn LED off:
      digitalWrite(LED_PIN, LOW);
    }

    client.loop();
    publishMessage("Data Sent successfully", temp, humidity);
    active = receivedJson["active"];
    delay(2500);
  }

  if (typ.equals("FAN_PIN")) {
    digitalWrite(pin, value);
  }

  if (typ.equals("LED_PIN")) {
    digitalWrite(pin, value);
  }

}`, //messageHandler
		`void setup() { 
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  WiFi.disconnect();
  preferences.begin("my-app", false);
  wifiSetup();
  connectAWS();
  printSuccess();
  pinMode(2, OUTPUT);
  digitalWrite(2, HIGH);
  pinMode(LED_PIN, OUTPUT);
  pinMode(LDR_PIN, INPUT);
  pinMode(DHTPIN, INPUT);
  pinMode(ENA_PIN, OUTPUT);
  pinMode(IN1_PIN, OUTPUT);
  pinMode(IN2_PIN, OUTPUT);
  digitalWrite(ENA_PIN, HIGH);
  dht.begin();
}`, //setup
	}
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

	// Add Car
	user, err = PostConfigNoLLM(Config{Peripherals: []Peripheral{
		{Pin: 14, Name: "ENA_PIN", Type: "IN_PIN", Value: 1},
		{Pin: 27, Name: "IN1_PIN", Type: "IN_PIN", Value: 0},
		{Pin: 26, Name: "IN2_PIN", Type: "IN_PIN", Value: 0},
		{Pin: 25, Name: "IN3_PIN", Type: "IN_PIN", Value: 0},
		{Pin: 33, Name: "IN4_PIN", Type: "IN_PIN", Value: 0},
		{Pin: 32, Name: "ENB_PIN", Type: "IN_PIN", Value: 1},
	}, Request: "My ESP32 is connected to an H-Bridge, generate code that will control this H-bridge",
		Result:          "None",
		Result_Datatype: "Void"}, user, codeDataCar)
	if err != nil {
		return err, User{}
	}
	// Add thermo
	user, err = PostConfigNoLLM(Config{Peripherals: []Peripheral{
		{Pin: 21, Name: "FAN", Type: "FAN_PIN", Value: 0},
		{Pin: 32, Name: "LDR", Type: "LDR_PIN", Value: 0},
		{Pin: 27, Name: "DHT", Type: "DHTPIN", Value: 0},
		{Pin: 21, Name: "ENA_PIN", Type: "IN_PIN", Value: 1},
		{Pin: 23, Name: "IN1_PIN", Type: "IN_PIN", Value: 0},
		{Pin: 22, Name: "IN2_PIN", Type: "IN_PIN", Value: 0},
	}, Request: "My ESP32 is connected to an LDR Module and Temprature sensor, generate code that will control them",
		Result:          "None",
		Result_Datatype: "Void"}, user, codeDataThermo)
	if err != nil {
		return err, User{}
	}
	// Add Water Tank
	user, err = PostConfigNoLLM(Config{Request: "My ESP32 is connected to a Water Tank of size 100 cm through a pump, the speed of sound is 0.034, My ESP is also connected to an ultrasonic sensor that is above the pump that detects the height of it, generate code to control the water Tank", Result: "On the press of active I want the pump to push water out", Result_Datatype: "Void", Peripherals: []Peripheral{
		{Pin: 5, Name: "TRIG_PIN", Type: "OUTPUT", Value: 0},
		{Pin: 18, Name: "ECHO_PIN", Type: "OUTPUT", Value: 0},
		{Pin: 14, Name: "relay", Type: "PUMP_PIN", Value: 0},
	}}, user, codeDataWaterTank)
	if err != nil {
		return err, User{}
	}
	// Add Empty
	user, err = PostConfigNoLLM(Config{}, user, codeDataEmpty)
	if err != nil {
		return err, User{}
	}

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
