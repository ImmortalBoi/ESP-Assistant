package util

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"slices"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/generative-ai-go/genai"
	"github.com/joho/godotenv"
	"google.golang.org/api/option"
)

// TODO change the payload to fit the config type we decided
type Config struct {
	Peripherals     []Peripheral
	Request         string
	Result          string
	Result_Datatype string
	Bucket_link     string
}

type Payload struct {
	Config   Config
	Username string
}

type Peripheral struct {
	Pin   int
	Name  string
	Type  string
	Value float32
}

type compilePost struct {
	Code        string   `json:"code"`
	Bucket_link string   `json:"bucket_link"`
	Libraries   []string `json:"libraries"`
}

func PostConfigV1(c *gin.Context) {
	// This binds the received information to a specified type where it denies anything that doesn't look like it
	// TODO replace this with the correct code
	var req Config
	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx := context.Background()
	godotenv.Load(".env")
	// Access your API key as an environment variable (see "Set up your API key" above)
	client, err := genai.NewClient(ctx, option.WithAPIKey(os.Getenv("GEMINI_API_KEY")))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	defer client.Close()

	model := client.GenerativeModel("gemini-1.5-pro-latest")
	model.SetTemperature(0.3)
	resp, err := model.GenerateContent(ctx, genai.Text(createPrompt(req)))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	libraries, globalDeclarations, publishMessage, messageHandler, setup := extractSections(formatResponse(resp))
	libraryBase := []string{
		"WiFi",
		"HTTPClient",
		"Preferences",
		"PubSubClient",
		"ArduinoJson",
	}
	declarationBase := []string{
		"Preferences preferences;",
		"WebServer server(80);",
		"WiFiClientSecure espClient = WiFiClientSecure();",
		"HTTPClient http;",
		"PubSubClient client(espClient);",
		`String fileURL = "https://esp32-assistant-bucket.s3.eu-central-1.amazonaws.com/Container/dist/testing.ino.bin";`,
		"long contentLength = 0;",
		"bool isValidContentType = false;",
		"StaticJsonDocument<200> receivedJson;",
	}

	libraries = insertConvert(libraryBase, libraries)
	globalDeclarations = strings.Join(insertConvert(declarationBase, strings.Split(globalDeclarations, "\n")), "\n")

	code := createCodeV1(libraries, globalDeclarations, publishMessage, messageHandler, setup)
	// c.JSON(http.StatusCreated, gin.H{"reply": formatResponse(resp), "setup": setup, "customFunction": customFunction, "libraries": libraries, "messageHandler": messageHandler, "publishMessage": publishMessage, "code": code, "globalDeclarations": globalDeclarations})

	status, body := sendCompileRequestV1(code, libraries)
	c.JSON(status, gin.H{"compileRequestResp": body, "reply": formatResponse(resp), "setup": setup, "libraries": libraries, "messageHandler": messageHandler, "publishMessage": publishMessage, "code": code, "globalDeclarations": globalDeclarations})

}

func PostConfigV2(c *gin.Context) {
	var req Payload
	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	err, user := GetUser(req.Username)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Create the initial context
	ctx := context.TODO()
	godotenv.Load(".env")

	req.Config.Bucket_link = `https://esp32-assistant-bucket.s3.eu-central-1.amazonaws.com/User-sketches/` + user.Name + `/` + strconv.Itoa(len(user.Config_gen)+1) + `/testing.ino.bin`
	upload_bucket_link := `User-sketches/` + user.Name + `/` + strconv.Itoa(len(user.Config_gen))
	// Access your API key as an environment variable (see "Set up your API key" above)
	client, err := genai.NewClient(ctx, option.WithAPIKey(os.Getenv("GEMINI_API_KEY")))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	defer client.Close()

	model := client.GenerativeModel("gemini-1.5-pro")
	model.SetTemperature(0.3)
	resp, err := model.GenerateContent(ctx, genai.Text(createPrompt(req.Config)))

	if err != nil {
		fmt.Println(err.Error())
		fmt.Println("API Limit reached, Waiting...")
		time.Sleep(20 * time.Second)
		resp, _ = model.GenerateContent(ctx, genai.Text(createPrompt(req.Config)))
		// c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		// return
	}

	libraries, globalDeclarations, publishMessage, messageHandler, setup := extractSections(formatResponse(resp))
	libraryBase := []string{
		"WiFi",
		"HTTPClient",
		"Preferences",
		"PubSubClient",
		"ArduinoJson",
	}
	declarationBase := []string{
		"Preferences preferences;",
		"WebServer server(80);",
		"WiFiClientSecure espClient = WiFiClientSecure();",
		"HTTPClient http;",
		"PubSubClient client(espClient);",
		`String fileURL = "` + req.Config.Bucket_link + `";`,
		"long contentLength = 0;",
		"bool isValidContentType = false;",
		"StaticJsonDocument<200> receivedJson;",
	}

	libraries = insertConvert(libraryBase, libraries)
	globalDeclarations = strings.Join(insertConvert(declarationBase, strings.Split(globalDeclarations, "\n")), "\n")

	code := createCodeV2(libraries, globalDeclarations, publishMessage, messageHandler, setup, user)
	// c.JSON(http.StatusCreated, gin.H{"reply": formatResponse(resp), "setup": setup, "customFunction": customFunction, "libraries": libraries, "messageHandler": messageHandler, "publishMessage": publishMessage, "code": code, "globalDeclarations": globalDeclarations})

	status, body := sendCompileRequestV2(code, libraries, upload_bucket_link)

	// if status == 400 {
	// 	c.JSON(status, gin.H{"compileRequestResp": body, "compilerRequestStatus": status, "reply": formatResponse(resp), "setup": setup, "libraries": libraries, "messageHandler": messageHandler, "publishMessage": publishMessage, "code": code, "globalDeclarations": globalDeclarations})
	// }
	for status == 400 {
		fmt.Println("RETRYING")
		// time.Sleep(20 * time.Second)
		model := client.GenerativeModel("gemini-1.5-pro")
		model.SetTemperature(0.3)
		retrialPrompt := createRetrialPrompt(req.Config, code, body)
		resp, err = model.GenerateContent(ctx, genai.Text(retrialPrompt))

		if err != nil {
			fmt.Println(err.Error())
			fmt.Println("API Limit reached in retrial, Waiting...")
			time.Sleep(20 * time.Second)
			resp, err = model.GenerateContent(ctx, genai.Text(createPrompt(req.Config)))
			// c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			// return
		}
		for err != nil {
			fmt.Println(err.Error())
			fmt.Println("API Limit reached in retrial, Waiting...")
			time.Sleep(20 * time.Second)
			resp, _ = model.GenerateContent(ctx, genai.Text(retrialPrompt))
			// c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			// return
		}
		fmt.Println(formatResponse(resp))

		libraries, globalDeclarations, publishMessage, messageHandler, setup := extractSections(formatResponse(resp))

		fmt.Println("-------------------------\nLogs:")
		fmt.Println(body)
		fmt.Println("-------------------------\nExtractions:")
		fmt.Println(libraries)
		code := createCodeV2(libraries, globalDeclarations, publishMessage, messageHandler, setup, user)

		// fmt.Println(code)

		status, body = sendCompileRequestV2(code, libraries, upload_bucket_link)
	}

	user.Config_gen = append(user.Config_gen, req.Config)
	err = UpdateUser(user)
	if err == nil {
		err = errors.New("no error")
	}
	c.JSON(status, gin.H{"updateDynamoDB": err.Error(), "compileRequestResp": body, "compilerRequestStatus": status, "reply": formatResponse(resp), "setup": setup, "libraries": libraries, "messageHandler": messageHandler, "publishMessage": publishMessage, "code": code, "globalDeclarations": globalDeclarations})
}

func sendCompileRequestV1(code string, libraries []string) (int, string) {
	// Define the URL
	link := "http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:5000/compile"
	// link := "http://localhost:5000/compile"

	// Create a compilePost object
	data := compilePost{
		Code:        code,
		Libraries:   libraries,
		Bucket_link: "https://esp32-assistant-bucket.s3.eu-central-1.amazonaws.com/Container/dist/",
	}

	// Convert the compilePost object to URL-encoded form data
	formData := url.Values{}
	formData.Set("code", data.Code)
	formData.Set("bucket_link", data.Bucket_link)
	for _, lib := range data.Libraries {
		formData.Add("libraries", lib)
	}

	// fmt.Println(formData)
	// Create a new request using http
	client := &http.Client{}
	r, _ := http.NewRequest("POST", link, bytes.NewBufferString(formData.Encode()))
	r.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	r.Header.Add("Content-Length", fmt.Sprint(len(formData.Encode())))

	// Send the request via a client
	resp, err := client.Do(r)

	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	// Read the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	// Print the response
	s, _ := strconv.Atoi(resp.Status)
	return s, string(body)
}

func sendCompileRequestV2(code string, libraries []string, bucket_link string) (int, string) {
	// Define the URL
	link := "http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:5000/compile"
	// link := "http://localhost:5000/compile"

	// Create a compilePost object
	data := compilePost{
		Code:        code,
		Bucket_link: bucket_link,
		Libraries:   libraries,
	}

	// Convert the compilePost object to URL-encoded form data
	formData := url.Values{}
	formData.Set("code", data.Code)
	for _, lib := range data.Libraries {
		formData.Add("libraries", lib)
	}
	formData.Set("bucket_link", data.Bucket_link)

	// fmt.Println(formData)
	// Create a new request using http
	client := &http.Client{}
	r, _ := http.NewRequest("POST", link, bytes.NewBufferString(formData.Encode()))
	r.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	r.Header.Add("Content-Length", fmt.Sprint(len(formData.Encode())))

	// Send the request via a client
	resp, err := client.Do(r)

	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	// Read the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	// Print the response
	s, _ := strconv.Atoi(resp.Status[0:3])
	return s, string(body)
}

func createPrompt(data Config) string {
	basePrompt := `
	First, understand this ESP32 code and make note of where it says semi-generated and fully generated:

#define CONFIG_ESP32_COREDUMP_DATA_FORMAT_ELF
#define CONFIG_ESP32_COREDUMP_ENABLE

//Libraries:
//start of semi-generated part , this part is used for addon libraries based on the prompt  
#include <WiFi.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

//end of semi-generated part

// Program Instances & Global Values:

// Data MANAGEMENT INSTANCE
Preferences preferences;

// WEB CLIENT INSTANCE
WebServer server(80);

// WIFI CLIENT INSTANCE
WiFiClientSecure espClient = WiFiClientSecure();

// HTTP CLIENT INSTANCE
HTTPClient http;

// MQTT CLIENT INSTANCE
PubSubClient client(espClient);

// Variables to validate response from S3
long contentLength = 0;
bool isValidContentType = false;

// Global Environment Values
StaticJsonDocument<200> receivedJson;
//start of fully-generated part, this part is used for global pin delarations based on the prompt

//end of the fully-generated part

void messageHandler(char* topic, byte* payload, unsigned int length) { //start of semi-generated function , this function is used to hand incoming messages from AWS IoT core
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

  if (receivedJson["update"] > -1) {
    updatefunction(receivedJson["update"]);
  }

  if (1 == receivedJson["active"]) {
    //start of fully-generated custom function here which the user decides in his request
    
    client.loop();
    //end of fully-generated custom here
  }

  //start of fully-generated part, this part is generated based on the types of peripherals sent in the prompt
  if (typ.equals("UniqueType1")) {   
    Serial.println("Unique Type Called");
    Serial.println(value);
    Serial.println(pin);
    // Write function related to this type
    digitalWrite(pin, value);
  }
  else if (typ.equals("UniqueType2")) {   
    Serial.println("Unique Type Called");
    Serial.println(value);
    Serial.println(pin);
    // Write function related to this type
    digitalWrite(pin, value);
  }

} //end of semi-generated function

void publishMessage() {  //start of fully-generated function,this function sends data to AWS IoT core based on the need to returned values in the prompt
  StaticJsonDocument<200> sentJson;
  sentJson["hello"] = "hello";
  char jsonBuffer[512];
  serializeJson(sentJson, jsonBuffer);  // print to client

  Serial.println("Message published!");
  client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
} //end of fully-generated function

void setup() {  //start of semi-generated function
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  WiFi.disconnect();
  preferences.begin("my-app", false);
  wifiSetup();
  connectAWS();
  printSuccess();
//start of fully-generated part, this part is used to initialize pins
// Example of pin setup
pinMode(2, OUTPUT);
pinMode(14, OUTPUT);

//end of fully-generated part
}//end of semi-generated function

void loop() { //start of non-generated function
  client.loop();
  if (1 == receivedJson["send_data"]) {
    publishMessage() ;
  }
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Connecting to wifi...");
    delay(5000);
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("Connected...");
      connectAWS();
    }
    delay(1000);
  }
} //end of non-generated function

Second, I want you to rewrite those parts of the code where it says semi-generated and fully-generated according to this information:`
	peripheralSection := `The user's ESP32 has these peripherals, `
	for i := 0; i < len(data.Peripherals); i++ {
		peripheralSection += "Type " + data.Peripherals[i].Type + " called " + data.Peripherals[i].Name + " on Pin " + strconv.Itoa(data.Peripherals[i].Pin) + ", "
	}
	basePrompt += peripheralSection + `Find the unique Types in the User's esp32 peripherals, for each Type that is an actuator discover the suitable write function for it. Then in the messageHandler function, change the if conditions that listen on the unique types to the name of the unique types that you found and change the write function in these if conditions to that of the suitable one for the type you found. However for each type that is a sensor, send that type in the publishMessage function.

Third, I want you to adjust the custom function part of the publishMessage function such that it applies the following request tweaking as well the parts of the global declarations, publishMessage, setup functions such that they help with applying the request:
`
	basePrompt += data.Request + ", The result wanted is " + data.Result + ", this result is used usually in the receivedJSON active section of the code therefore the return type is " + data.Result_Datatype + " \n"
	basePrompt += `
Fourth, include the appropriate libraries needed to run all this code under generated libraries, select libraries that are needed to write and read to and from the peripherals the user gave, select it from this list of Arduino libraries that are made for the ESP32 architecture making sure that any library that gets chosen gets utilised, alongside that select libraries that are closely related to the peripherals:

DHT11, DHT12, esp32-ds18b20, ESP32-PTQS1005, ESP32Servo

Fifthly, Avoid using types and libraries when possible unless it's the DHT and in case include the specified library in the Generated Libraries of the type such as DHT11 and use the digitalWrite and digitalRead as well as keep all the logic needed for the code to work such as extra functions inside the setup, publishMessage, messageHandler functions.

Finally, reply only with all the static libraries already in the code and the selected libraries underneath a label called "##Generated Libraries" in a list of their names,the global declarations needed to run the code under a label called "##Global Variables", the publishMessage code under a label "Publish Message Function", and the messageHandler code under a label called "##Message Handler Function" and the setup function under a label called "##Setup Function" and remove all comments and implement them fully.`

	return basePrompt
}

func createRetrialPrompt(data Config, code string, log string) string {
	basePrompt := `
	First, understand that this ESP32 code has failed at compiling and make note of where it says semi-generated and fully generated:

` + code + `

Second, I want you to understand that those parts of the code where it says semi-generated and fully-generated were written according to this information:`
	peripheralSection := `The user's ESP32 has these peripherals, `
	for i := 0; i < len(data.Peripherals); i++ {
		peripheralSection += "Type " + data.Peripherals[i].Type + " called " + data.Peripherals[i].Name + " on Pin " + strconv.Itoa(data.Peripherals[i].Pin) + ", "
	}
	basePrompt += peripheralSection + `Find the unique Types in the User's esp32 peripherals, for each Type that is an actuator discover the suitable write function for it. Then in the messageHandler function, change the if conditions that listen on the unique types to the name of the unique types that you found and change the write function in these if conditions to that of the suitable one for the type you found. However for each type that is a sensor, send that type in the publishMessage function.

Third, I want you to know that the custom function part of the publishMessage function were adjusted such that it applies the following request and as well the parts of the global declarations, publishMessage, setup functions were tweaked such that they help with applying the request:
`
	basePrompt += data.Request + ", The result wanted is " + data.Result + ", therefore the return type is " + data.Result_Datatype + " \n"
	basePrompt += `
Fourth, seemingly the appropriate libraries needed to run all this code were added under generated libraries, select libraries that are needed to write and read to and from the peripherals the user gave, select it from this list of Arduino libraries that are made for the ESP32 architecture making sure that any library that gets chosen gets utilised, alongside that select libraries that are closely related to the peripherals:

DHT11, DHT12, esp32-ds18b20, ESP32-PTQS1005, ESP32Servo

Fifthly, Avoid using types and libraries when possible unless it's the DHT and in which case include DHT11 library in the Generated Libraries  and use the digitalWrite and digitalRead as well as keep all the logic needed for the code to work such as extra functions inside the setup, publishMessage, messageHandler functions.

Sixthly, this was the log that was sent of the compilation that failed:
` + log + `
Try to understand why the previous compilation failed and fix the error that caused it by changing the Generated Libraries, global declarations, publishMessage, messageHandler or setup function

Finally, reply only with all the static libraries already in the code and the selected libraries underneath a label called "##Generated Libraries" in a list of their names where for example,the global declarations needed to run the code under a label called "##Global Variables", the publishMessage code under a label "Publish Message Function", and the messageHandler code under a label called "##Message Handler Function" and the setup function under a label called "##Setup Function" and remove all comments and implement them fully.`

	return basePrompt
}

func extractSections(code string) ([]string, string, string, string, string) {

	// Split the code by section headers
	sections := strings.Split(code, "##")
	sections = sections[1:]

	if len(sections) == 0 {
		// Handle empty code case (return default values or error)
		return nil, "", "", "", ""
	}

	// Extract each section based on header
	for i := 1; i < len(sections); i++ {
		sections[i] = strings.Replace(strings.Replace(sections[i], "\n\n", "", -1), "```", "", -1)
		lines := strings.Split(sections[i], "\n")

		val := 1
		if strings.Contains(lines[1], "cpp") {
			val = 2
		}
		tmp := strings.Join(lines[val:], "\n")
		sections[i] = tmp
	}

	// Check if first element is empty (no leading header)
	if sections[0] == "" {
		sections = sections[1:] // Remove the empty element
	}

	res := formatLibraries(sections[0])
	return res, sections[1], sections[2], sections[3], sections[4]
}

func formatLibraries(libraries string) []string {
	libraries = strings.Replace(libraries, "\n\n", "", -1)
	libraries = strings.Replace(libraries, " ", "", -1)
	librarySplit := strings.Split(libraries, "\n")[1:] // Skip the first line
	var libraryArr []string

	// Adjusted regular expression to match the new pattern
	re := regexp.MustCompile(`(?:\*\s|-)\s?(\w+\.h)|#include<(.+)>`)

	for _, library := range librarySplit {
		match := re.FindStringSubmatch(library)
		if len(match) > 0 {
			// Extracting library name based on the match
			if len(match) == 3 { // This means we're dealing with #include<...> syntax
				fmt.Println("-----------Match:")
				fmt.Println(match)
				libraryName := match[2] // Match group 2 contains the library name after #include<
				libraryArr = append(libraryArr, libraryName)
			} else { // This is for the other patterns like -* or *library.h
				libraryName := match[1] // Match group 1 contains the library name
				// Remove the.h suffix if present
				libraryName = strings.TrimSuffix(libraryName, ".h")
				libraryArr = append(libraryArr, libraryName)
			}
		} else {
			fmt.Println("Library regexp not found:", library)
			libraryName := strings.TrimSuffix(library, ".h")
			libraryArr = append(libraryArr, libraryName)
			// Fallback logic if needed
		}
	}
	return libraryArr
}

func createCodeV1(libraries []string, globalDeclarations string, publishMessage string, messageHandler string, setup string) string {
	libraryCode := ``
	for i := 0; i < len(libraries); i++ {
		libraryCode += "#include <" + libraries[i] + ".h>\n"
	}

	codeTemplate := `

#define CONFIG_ESP32_COREDUMP_DATA_FORMAT_ELF
#define CONFIG_ESP32_COREDUMP_ENABLE
#define THINGNAME "ESP32_AWStest2"  //change this
#define AWS_IOT_PUBLISH_TOPIC "esp32/pub"
#define AWS_IOT_SUBSCRIBE_TOPIC "esp32/sub"

//Static-Libraries:
#include <WebServer.h>
#include <uri/UriBraces.h>
#include <Update.h>
#include <WifiClientSecure.h>
` + libraryCode + `
// Program Instances & Global Values:
` + globalDeclarations + `

const char AWS_IOT_ENDPOINT[] = "` + os.Getenv("AWS_IOT_ENDPOINT") + `";  //change this

// Amazon Root CA 1
static const char AWS_CERT_CA[] PROGMEM = R"EOF(` + os.Getenv("AWS_CERT_CA") + `)EOF";

// Device Certificate                                               //change this
static const char AWS_CERT_CRT[] PROGMEM = R"KEY(` + os.Getenv("AWS_CERT_CRT") + `)KEY";

// Device Private Key                                               //change this
static const char AWS_CERT_PRIVATE[] PROGMEM = R"KEY(` + os.Getenv("AWS_CERT_PRIVATE") + `)KEY";


// OTA Logic
void execOTA() { //start of non-generated function
  Serial.println("Connecting to: " + String(fileURL));

  http.begin(fileURL);        // Specify the URL
  int httpCode = http.GET();  // Make the request

  if (httpCode > 0) {  // Check for the returning code
    // Get the payload
    Stream& payload = http.getStream();

    // Check if the HTTP Response is 200
    if (httpCode == HTTP_CODE_OK) {
      // Check if there is enough to OTA Update
      bool canBegin = Update.begin(http.getSize());

      // If yes, begin
      if (canBegin) {
        Serial.println("Begin OTA. This may take 2 - 5 mins to complete. Things might be quite for a while.. Patience!");
        size_t written = Update.writeStream(payload);

        if (written == http.getSize()) {
          Serial.println("Written : " + String(written) + " successfully");
        } else {
          Serial.println("Written only : " + String(written) + "/" + String(http.getSize()) + ". Retry?");
        }

        if (Update.end()) {
          Serial.println("OTA done!");
          if (Update.isFinished()) {
            Serial.println("Update successfully completed. Rebooting.");
            ESP.restart();
          } else {
            Serial.println("Update not finished? Something went wrong!");
          }
        } else {
          Serial.println("Error Occurred. Error #: " + String(Update.getError()));
        }
      } else {
        // not enough space to begin OTA
        Serial.println("Not enough space to begin OTA");
      }
    } else {
      Serial.println("Got a non 200 status code from server. Exiting OTA Update.");
    }
  } else {
    Serial.println("Failed to connect to server. Exiting OTA Update.");
  }

  http.end();  // End the connection
} //end of non-generated function

void printSuccess() { //start of non-generated function
  StaticJsonDocument<200> sentJson;
  sentJson["type"] = "done";
  char jsonBuffer[512];
  serializeJson(sentJson, jsonBuffer);
  Serial.println("Message published!");
  Serial.println("ESP Working!!");
  client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
} //end of non-generated function


void wifiSetup() {  //start of non-generated function
  String wifiIndex = "";
  String pass = "";
  unsigned long previousMillis = 0;
  const long interval = 10000;
  if (preferences.getString("wifiIndex", "") != "") {  //fetch wifi credis from flash mem
    Serial.println("Fetching Wifi");

    wifiIndex = preferences.getString("wifiIndex", "");
    pass = preferences.getString("pass", "");

    WiFi.begin(wifiIndex, pass, 6);

    Serial.print("Connecting to WiFi");

    while (WiFi.status() != WL_CONNECTED) {
      unsigned long currentMillis = millis();
      delay(1000);
      Serial.print(".");
      if (currentMillis - previousMillis >= interval) {
        preferences.putString("wifiIndex", "");
        preferences.putString("pass", "");
        wifiSetup();
      }
    }
    Serial.println("Connected!");
    return;
  }
  String password_AP = "12345678";
  String ssid_AP = "ESP32";
  WiFi.softAP(ssid_AP, password_AP);
  Serial.println("Created AP");
  Serial.print("ESP AP IP: ");
  Serial.println(WiFi.softAPIP());

  server.on(UriBraces("/reply"), HTTP_GET, []() {
    Serial.println("Request sent");
    int n = WiFi.scanNetworks();
    String json;
    StaticJsonDocument<200> doc;
    JsonArray wifiArray = doc.createNestedArray("wifi");
    if (n == 0) {
      Serial.println("no networks found");
    } else {
      for (int i = 0; i < n; ++i) {
        wifiArray.add(WiFi.SSID(i));  // Add the copied string to the JSON array
      }

      serializeJson(doc, json);

      server.send(200, "application/json", json);
      WiFi.scanDelete();  // Delete the old scan results
    }
  });

  server.on(UriBraces("/wifi/{}/pass/{}"), HTTP_GET, []() {
    Serial.println("input Recieved");
    String wifiIndex = server.pathArg(0);
    String pass = server.pathArg(1);
    wifiIndex.replace("%20", " ");
    Serial.println(wifiIndex);
    Serial.println(pass);

    WiFi.begin(wifiIndex, pass, 6);
    Serial.print("Connecting to WiFi");

    while (WiFi.status() != WL_CONNECTED) {
      delay(1000);
      Serial.print(".");
    }
    Serial.println("Connected!");
    preferences.putString("wifiIndex", wifiIndex);
    preferences.putString("pass", pass);
  });

  server.begin();
  Serial.println("HTTP server started");
  while (WiFi.status() != WL_CONNECTED) {
    if (WiFi.softAPgetStationNum() > 0) {
      Serial.println("Client connected");
    }
    server.handleClient();
    delay(3000);
  }
}  //end of non-generated function

void connectAWS() { //start of non-generated function
  // Configure WiFiClientSecure to use the AWS IoT device credentials
  espClient.setCACert(AWS_CERT_CA);
  espClient.setCertificate(AWS_CERT_CRT);
  espClient.setPrivateKey(AWS_CERT_PRIVATE);

  // Connect to the MQTT broker on the AWS endpoint we defined earlier
  client.setServer(AWS_IOT_ENDPOINT, 8883);

  // Create a message handler
  client.setCallback(messageHandler);

  Serial.println("Connecting to AWS IoT");

  while (!client.connect(THINGNAME)) {
    Serial.print(".");
    delay(100);
  } 

  if (!client.connected()) {
    Serial.println("AWS IoT Timeout!");
    return;
  }

  // Subscribe to a topic
  client.subscribe(AWS_IOT_SUBSCRIBE_TOPIC);
  Serial.println("AWS IoT Connected!");
} //end of non-generated function

` + messageHandler + `

` + publishMessage + `

` + setup + `

void loop() { //start of non-generated function
  client.loop();
  if (1 == receivedJson["send_data"]) {
    publishMessage() ;
  }
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Connecting to wifi...");
    delay(5000);
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("Connected...");
      connectAWS();
    }
    delay(1000);
  }
} //end of non-generated function
`
	return codeTemplate
}

func createCodeV2(libraries []string, globalDeclarations string, publishMessage string, messageHandler string, setup string, user User) string {
	libraryCode := ``
	for i := 0; i < len(libraries); i++ {
		libraryCode += "#include <" + libraries[i] + ".h>\n"
	}

	codeTemplate := `

#define CONFIG_ESP32_COREDUMP_DATA_FORMAT_ELF
#define CONFIG_ESP32_COREDUMP_ENABLE
#define THINGNAME "` + user.ESP_cert.Thing_name + `"  //change this
#define AWS_IOT_PUBLISH_TOPIC "` + user.ESP_cert.Pub_topic + `"
#define AWS_IOT_SUBSCRIBE_TOPIC "` + user.ESP_cert.Sub_topic + `"

//Static-Libraries:
#include <WebServer.h>
#include <uri/UriBraces.h>
#include <Update.h>
#include <WiFiClientSecure.h>
` + libraryCode + `
// Program Instances & Global Values:
` + globalDeclarations + `

const char AWS_IOT_ENDPOINT[] = "` + os.Getenv("AWS_IOT_ENDPOINT") + `";  //change this

// Amazon Root CA 1
static const char AWS_CERT_CA[] PROGMEM = R"EOF(` + os.Getenv("AWS_CERT_CA") + `)EOF";

// Device Certificate                                               //change this
static const char AWS_CERT_CRT[] PROGMEM = R"KEY(` + user.ESP_cert.AWS_CERT_CRT + `)KEY";

// Device Private Key                                               //change this
static const char AWS_CERT_PRIVATE[] PROGMEM = R"KEY(` + user.ESP_cert.AWS_CERT_PRIVATE + `)KEY";


// OTA Logic
void execOTA() { //start of non-generated function
  Serial.println("Connecting to: " + String(fileURL));

  http.begin(fileURL);        // Specify the URL
  int httpCode = http.GET();  // Make the request

  if (httpCode > 0) {  // Check for the returning code
    // Get the payload
    Stream& payload = http.getStream();

    // Check if the HTTP Response is 200
    if (httpCode == HTTP_CODE_OK) {
      // Check if there is enough to OTA Update
      bool canBegin = Update.begin(http.getSize());

      // If yes, begin
      if (canBegin) {
        Serial.println("Begin OTA. This may take 2 - 5 mins to complete. Things might be quite for a while.. Patience!");
        size_t written = Update.writeStream(payload);

        if (written == http.getSize()) {
          Serial.println("Written : " + String(written) + " successfully");
        } else {
          Serial.println("Written only : " + String(written) + "/" + String(http.getSize()) + ". Retry?");
        }

        if (Update.end()) {
          Serial.println("OTA done!");
          if (Update.isFinished()) {
            Serial.println("Update successfully completed. Rebooting.");
            ESP.restart();
          } else {
            Serial.println("Update not finished? Something went wrong!");
          }
        } else {
          Serial.println("Error Occurred. Error #: " + String(Update.getError()));
        }
      } else {
        // not enough space to begin OTA
        Serial.println("Not enough space to begin OTA");
      }
    } else {
      Serial.println("Got a non 200 status code from server. Exiting OTA Update.");
    }
  } else {
    Serial.println("Failed to connect to server. Exiting OTA Update.");
  }

  http.end();  // End the connection
} //end of non-generated function

void printSuccess() { //start of non-generated function
  StaticJsonDocument<200> sentJson;
  sentJson["type"] = "done";
  char jsonBuffer[512];
  serializeJson(sentJson, jsonBuffer);
  Serial.println("Message published!");
  Serial.println("ESP Working!!");
  client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
} //end of non-generated function


void wifiSetup() { //start of non-generated function
  String wifiIndex = "";
  String pass = "";
  unsigned long previousMillis = 0;
  const long interval = 10000;
  if (preferences.getString("wifiIndex", "") != "") {  //fetch wifi credis from flash mem
    Serial.println("Fetching Wifi");

    wifiIndex = preferences.getString("wifiIndex", "");
    pass = preferences.getString("pass", "");

    WiFi.begin(wifiIndex, pass, 6);

    Serial.print("Connecting to WiFi");

    while (WiFi.status() != WL_CONNECTED) {
      unsigned long currentMillis = millis();
      delay(1000);
      Serial.print(".");
      if (currentMillis - previousMillis >= interval) {
        preferences.putString("wifiIndex", "");
        preferences.putString("pass", "");
        wifiSetup();
      }
    }
    Serial.println("Connected!");
    return;
  }
  String password_AP = "12345678";
  String ssid_AP = "ESP32";
  WiFi.softAP(ssid_AP, password_AP);
  Serial.println("Created AP");
  Serial.print("ESP AP IP: ");
  Serial.println(WiFi.softAPIP());

  server.on(UriBraces("/reply"), HTTP_GET, []() {
    Serial.println("Request sent");
    int n = WiFi.scanNetworks();
    String json;
    StaticJsonDocument<200> doc;
    JsonArray wifiArray = doc.createNestedArray("wifi");
    if (n == 0) {
      Serial.println("no networks found");
    } else {
      for (int i = 0; i < n; ++i) {
        wifiArray.add(WiFi.SSID(i));  // Add the copied string to the JSON array
      }

      serializeJson(doc, json);

      server.send(200, "application/json", json);
      WiFi.scanDelete();  // Delete the old scan results
    }
  }); 

  server.on(UriBraces("/wifi/{}/pass/{}"), HTTP_GET, []() {
    Serial.println("input Recieved");
    String wifiIndex = server.pathArg(0);
    String pass = server.pathArg(1);
    wifiIndex.replace("%20", " ");
    Serial.println(wifiIndex);
    Serial.println(pass);

    WiFi.begin(wifiIndex, pass, 6);
    Serial.print("Connecting to WiFi");

    while (WiFi.status() != WL_CONNECTED) {
      delay(1000);
      Serial.print(".");
    }
    Serial.println("Connected!");
    preferences.putString("wifiIndex", wifiIndex);
    preferences.putString("pass", pass);
  });

  server.begin();
  Serial.println("HTTP server started");
  while (WiFi.status() != WL_CONNECTED) {
    if (WiFi.softAPgetStationNum() > 0) {
      Serial.println("Client connected");
    }
    server.handleClient();
    delay(3000);
  }
} //end of non-generated function

void connectAWS() {  //start of non-generated function
  // Configure WiFiClientSecure to use the AWS IoT device credentials
  espClient.setCACert(AWS_CERT_CA);
  espClient.setCertificate(AWS_CERT_CRT);
  espClient.setPrivateKey(AWS_CERT_PRIVATE);

  // Connect to the MQTT broker on the AWS endpoint we defined earlier
  client.setServer(AWS_IOT_ENDPOINT, 8883);

  // Create a message handler
  client.setCallback(messageHandler);

  Serial.println("Connecting to AWS IoT");

  while (!client.connect(THINGNAME)) {
    Serial.print(".");
    delay(100);
  }

  if (!client.connected()) {
    Serial.println("AWS IoT Timeout!");
    return;
  }

  // Subscribe to a topic
  client.subscribe(AWS_IOT_SUBSCRIBE_TOPIC);
  Serial.println("AWS IoT Connected!");
}  //end of non-generated function

void updatefunction(int index) {
  Serial.println("update called");
  String strindex = String(index);
  String index1 = "http://esp32-assistant-bucket.s3.eu-central-1.amazonaws.com/User-sketches/` + user.Name + `/" + strindex;
  Serial.println(index1);
  String index2 = index1 + "/testing.ino.bin";
  Serial.println(index2);
  fileURL = index2;
  execOTA();
}

` + messageHandler + `

` + publishMessage + `

` + setup + `

void loop() { //start of non-generated function
  client.loop();
  if (1 == receivedJson["send_data"]) {
    publishMessage() ;
  }
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Connecting to wifi...");
    delay(5000);
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("Connected...");
      connectAWS();
    }
    delay(1000);
  }
} //end of non-generated function
`
	return codeTemplate
}

func formatResponse(resp *genai.GenerateContentResponse) string {
	var formattedContent strings.Builder
	if resp != nil && resp.Candidates != nil {
		for _, cand := range resp.Candidates {
			if cand.Content != nil {
				for _, part := range cand.Content.Parts {
					formattedContent.WriteString(fmt.Sprintf("%v", part))
				}
			}
		}
	}

	return formattedContent.String()
}

func insertConvert(base []string, arr []string) []string {
	for _, val := range arr {
		if val == "WebServer" || val == "uri/UriBraces" || val == "Update" || val == "" || val == "WiFiClientSecure" || val == "WebServer server = WebServer(80);" || val == "WebServer server;" {
			continue
		}
		if !slices.Contains(base, val) {
			base = append(base, val)
		}
	}
	return base
}

func PostConfigNoLLM(config Config, user User, codeData []string) (User, error) {
	godotenv.Load(".env")

	config.Bucket_link = `https://esp32-assistant-bucket.s3.eu-central-1.amazonaws.com/User-sketches/` + user.Name + `/` + strconv.Itoa(len(user.Config_gen)+1) + `/testing.ino.bin`
	upload_bucket_link := `User-sketches/` + user.Name + `/` + strconv.Itoa(len(user.Config_gen))
	// Access your API key as an environment variable (see "Set up your API key" above)

	libraries, globalDeclarations, publishMessage, messageHandler, setup := strings.Split(codeData[0], "\n"), codeData[1], codeData[2], codeData[3], codeData[4]
	libraryBase := []string{
		"WiFi",
		"HTTPClient",
		"Preferences",
		"PubSubClient",
		"ArduinoJson",
	}
	declarationBase := []string{
		"Preferences preferences;",
		"WebServer server(80);",
		"WiFiClientSecure espClient = WiFiClientSecure();",
		"HTTPClient http;",
		"PubSubClient client(espClient);",
		`String fileURL = "` + config.Bucket_link + `";`,
		"long contentLength = 0;",
		"bool isValidContentType = false;",
		"StaticJsonDocument<200> receivedJson;",
	}

	libraries = insertConvert(libraryBase, libraries)
	globalDeclarations = strings.Join(insertConvert(declarationBase, strings.Split(globalDeclarations, "\n")), "\n")

	code := createCodeV2(libraries, globalDeclarations, publishMessage, messageHandler, setup, user)
	// c.JSON(http.StatusCreated, gin.H{"reply": formatResponse(resp), "setup": setup, "customFunction": customFunction, "libraries": libraries, "messageHandler": messageHandler, "publishMessage": publishMessage, "code": code, "globalDeclarations": globalDeclarations})

	status, body := sendCompileRequestV2(code, libraries, upload_bucket_link)

	if status == 500 {
		return user, errors.New(body)
	}
	user.Config_gen = append(user.Config_gen, config)

	return user, nil
	// c.JSON(status, gin.H{"updateDynamoDB": err.Error(), "compileRequestResp": body, "compilerRequestStatus": status, "reply": formatResponse(resp), "setup": setup, "libraries": libraries, "messageHandler": messageHandler, "publishMessage": publishMessage, "code": code, "globalDeclarations": globalDeclarations})

}
