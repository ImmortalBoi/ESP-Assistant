package main

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"slices"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/generative-ai-go/genai"
	"github.com/joho/godotenv"
	"google.golang.org/api/option"
)

// TODO change the payload to fit the config type we decided
type Payload struct {
	Peripherals     []Peripheral
	Request         string
	Result          string
	Result_Datatype string
}

type Peripheral struct {
	Pin   int
	Name  string
	Type  string
	Value float32
}

type compilePost struct {
	Code      string   `json:"code"`
	Libraries []string `json:"libraries"`
}

func main() {
	router := gin.Default()
	router.GET("/", getRoutes)
	// router.GET("/compile", sendCompileRequest)
	router.POST("/config", postConfig)

	router.Run(":8080")
}

func getRoutes(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"routes": []string{"/config [POST]", "/ [GET]"},
	})
}

func postConfig(c *gin.Context) {
	// This binds the received information to a specified type where it denies anything that doesn't look like it
	// TODO replace this with the correct code
	var req Payload
	if err := c.BindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx := context.Background()
	godotenv.Load(".env")
	// Access your API key as an environment variable (see "Set up your API key" above)
	client, err := genai.NewClient(ctx, option.WithAPIKey(os.Getenv("API_KEY")))
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

	libraries, globalDeclarations, customFunction, publishMessage, messageHandler, setup := extractSections(formatResponse(resp))
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
		`String fileURL = "http://esp32-assistant-bucket.s3.eu-central-1.amazonaws.com/Container/dist/sketch.ino.bin";`,
		"long contentLength = 0;",
		"bool isValidContentType = false;",
		"StaticJsonDocument<200> receivedJson;",
	}

	libraries = insertConvert(libraryBase, libraries)
	globalDeclarations = strings.Join(insertConvert(declarationBase, strings.Split(globalDeclarations, "\n")), "\n")

	code := createCode(libraries, globalDeclarations, customFunction, publishMessage, messageHandler, setup)
	// c.JSON(http.StatusCreated, gin.H{"reply": formatResponse(resp), "setup": setup, "customFunction": customFunction, "libraries": libraries, "messageHandler": messageHandler, "publishMessage": publishMessage, "code": code, "globalDeclarations": globalDeclarations})

	status, body := sendCompileRequest(code, libraries)
	c.JSON(status, gin.H{"compileRequestResp": body, "reply": formatResponse(resp), "setup": setup, "customFunction": customFunction, "libraries": libraries, "messageHandler": messageHandler, "publishMessage": publishMessage, "code": code, "globalDeclarations": globalDeclarations})

	return
}

func sendCompileRequest(code string, libraries []string) (int, string) {
	// Define the URL
	// link := "http://ec2-18-191-97-70.us-east-2.compute.amazonaws.com:5000/compile"
	link := "http://localhost:5000/compile"

	// Create a compilePost object
	data := compilePost{
		Code:      code,
		Libraries: libraries,
	}

	// Convert the compilePost object to URL-encoded form data
	formData := url.Values{}
	formData.Set("code", data.Code)
	for _, lib := range data.Libraries {
		formData.Add("libraries", lib)
	}

	fmt.Println(formData)
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

func createPrompt(data Payload) string {
	basePrompt := `
	First, understand this ESP32 code and make not of where it says semi-generated and fully generated:

#define CONFIG_ESP32_COREDUMP_DATA_FORMAT_ELF
#define CONFIG_ESP32_COREDUMP_ENABLE

// MQTT BROKER CONFIG
#define THINGNAME "ESP32_AWStest1"  //change this
#define AWS_IOT_PUBLISH_TOPIC "esp32/pub"
#define AWS_IOT_SUBSCRIBE_TOPIC "esp32/sub"

//Libraries:
#include <WiFi.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

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

// S3 Bucket Config
String fileURL = "http://esp32-assistant-bucket.s3.eu-central-1.amazonaws.com/Container/dist/sketch.ino.bin";

// Variables to validate response from S3
long contentLength = 0;
bool isValidContentType = false;

// Global Environment Values
StaticJsonDocument<200> receivedJson;

// OTA Logic
void execOTA() {
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
}

void wifiSetup() {
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
}

void connectAWS() {
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
  client.subscribe("esp32/led");
  Serial.println("AWS IoT Connected!");
}

void messageHandler(char* topic, byte* payload, unsigned int length) {  //semi-generated
  Serial.print("incoming: ");
  Serial.println(topic);
  // String tpc(topic);
  deserializeJson(receivedJson, payload);
  // Serial.println(tpc);
  const char* type = receivedJson["type"];
  String typ(type);
  const uint8_t value = receivedJson["value"];
  const uint8_t pin = receivedJson["pin"];
  if (typ.equals("led")) {  //fully-generated
    Serial.println("led called");
    Serial.println(value);
    Serial.println(pin);
    digitalWrite(pin, value);
  }
  if (typ.equals("led")) {
    Serial.println("led called");
    Serial.println(value);
    Serial.println(pin);
    digitalWrite(pin, value);
  }
  if(typ.equals("update")){
    Serial.println("update called");
    execOTA();
  }
}

void publishMessage() {  //semi-generated
  StaticJsonDocument<200> sentJson;
  sentJson["hello"] = "hello";
  char jsonBuffer[512];
  serializeJson(sentJson, jsonBuffer);  // print to client

  Serial.println("Message published!");
  client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
}

void customFunc() { //fully-generated
	
}

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  pinMode(2, OUTPUT);
  WiFi.disconnect();
  preferences.begin("my-app", false);
  wifiSetup();
  connectAWS();
  //execOTA();
}

void loop() {
  client.loop();
  if (1 == receivedJson["active"]) {
    customFunc()
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
}

Second, I want you to rewrite those parts of the code where it says semi-generated and fully-generated according to this information:`
	peripheralSection := `The user's ESP32 has these peripherals, `
	for i := 0; i < len(data.Peripherals); i++ {
		peripheralSection += data.Peripherals[i].Type + " called " + data.Peripherals[i].Name + " on Pin " + strconv.Itoa(data.Peripherals[i].Pin) + ", "
	}
	basePrompt += peripheralSection + `Change the messageHandler function such that it would listen to and apply changes it would see in a json sent to
it, follow by example in the given if condition. Change the publishMessage function such that it would publish a message in a json format similar to the one you listen to in the messageHandler function. Also change the setup function initialise the modules and sensors properly on the correct pins.

Third, I want you to overwrite the customFunc such that it applies the following request:
`
	basePrompt += data.Request + ", The result wanted is " + data.Result + ", therefore the return type is " + data.Result_Datatype + " \n"
	basePrompt += `
Fourth, include the appropriate libraries needed to run all this code under generated libraries, select libraries that are needed to write and read to and from the peripherals the user gave, select it from this list of Arduino libraries that are made for the ESP32 architecture making sure that any library that gets chosen gets utilised, alongside that select libraries that are closely related to the peripherals:

107-Arduino-BMP388, 107-Arduino-NMEA-Parser, 107-Arduino-Sensor, AstroMech, ATC_MiThermometer, BH1750, BMI270_Sensor, Bonezegei ILI9341, Bonezegei_XPT2046, BresserWeatherSensorReceiver, CROZONE-VEML6040, CS5490, CurrentTransformerWithCallbacks, dhtESP32-rmt, DIYables_IRcontroller, ds1302, ESPectro32, ESPiLight, ESP Rotary Encoder, ESP32 BLE ANCS Notifications, ESP32 BLE Arduino, ESP32-Chimera-Core, ESP32 Encoder, ESP32 ESP32S2 AnalogWrite, ESP32 MX1508, ESP32 RMT Peripheral VAN bus reader library, ESP32Servo, ESP32Servo360, ESP32_BleSerial, ESP32_Button, ESP32_C3_ISR_Servo, ESP32_C3_TimerInterrupt, ESP32_ENC28J60, ESP32_Encoder, ESP32_IO_Expander, ESP32_ISR_Servo, ESP32_Knob, ESP32_PWM, ESP32_RTC_EEPROM, ESP32_S2_ISR_Servo, ESP32_S2_TimerInterrupt, ESP32_SC_ENC_Manager, ESP32_SC_Ethernet_Manager, ESP32_SC_W5500_Manager, ESP32_SC_W6100_Manager, ESP32httpUpdate, FaBo 202 9Axis MPU9250, FaBo 203 Color S11059, FaBo 206 UV Si1132, FaBo 207 Temperature ADT7410, FaBo 217 Ambient Light ISL29034, FaBo 222 Environment BME680, FaBo 223 Gas CCS811, FaBo 230 Color BH1749NUC, FaBo Motor DRV8830, FaBo PWM PCA9685, Freenove WS2812 Lib for ESP32, HS_CAN_485_ESP32, HS_JOY_ESP32, IRremote

Finally, reply only with all the static libraries already in the code and the selected libraries underneath a label called "##Generated Libraries" in a list of their names,the global declarations needed to run the code under a label called "##Global Variables",the customFunc code under a label called "##Custom Function Function", the publishMessage code under a label "Publish Message Function", and the messageHandler code under a label called "##Message Handler Function" and the setup function under a label called "##Setup Function" and remove all comments and implement them fully.`

	return basePrompt
}

func extractSections(code string) ([]string, string, string, string, string, string) {

	// Split the code by section headers
	sections := strings.Split(code, "##")
	sections = sections[1:]

	if len(sections) == 0 {
		// Handle empty code case (return default values or error)
		return nil, "", "", "", "", ""
	}

	// Extract each section based on header
	for i := 1; i < len(sections); i++ {
		// fmt.Println("--------------------------------------------------")
		// fmt.Println(sections[i])
		sections[i] = strings.Replace(strings.Replace(sections[i], "\n\n", "", -1), "```", "", -1)
		lines := strings.Split(sections[i], "\n")

		// newLines := lines[:0]
		// for _, line := range lines {
		// 	if line != "\n" {
		// 		newLines = append(newLines, line)
		// 	}
		// }

		tmp := strings.Join(lines[2:], "\n")
		sections[i] = tmp
		// fmt.Println("-------------------------")
		fmt.Println(sections[i])
		// fmt.Println("--------------------------------------------------")
		// lines = lines[2 : len(lines)-1]
		// sections[i] = strings.Join(lines, "\n")
	}

	// Check if first element is empty (no leading header)
	if sections[0] == "" {
		sections = sections[1:] // Remove the empty element
	}

	res := formatLibraries(sections[0])
	return res, sections[1], sections[2], sections[3], sections[4], sections[5]
}

func formatLibraries(libraries string) []string {
	libraries = strings.Replace(libraries, "\n\n", "", -1)
	libraries = strings.Replace(libraries, " ", "", -1)
	librarySplit := strings.Split(libraries, "\n")[1:]
	var libraryArr []string
	// Define a regular expression to match the library name
	re := regexp.MustCompile(`\*([^\.]+)`)

	for _, library := range librarySplit {
		// Extract the name using the regular expression
		match := re.FindStringSubmatch(library)
		if match != nil {
			libraryArr = append(libraryArr, match[1]) // Print the captured group (library name)
		} else {
			fmt.Println("Library regexp not found:", library)
			tmp := strings.Split(library, "-")
			if len(tmp) == 0 {
				// tmp = strings.Split(library, "*")
				// tmp = strings.Split(tmp[len(tmp)-1], ".h")
			}
			libraryArr = append(libraryArr, tmp[len(tmp)-1])
		}
	}
	return libraryArr
}

func createCode(libraries []string, globalDeclarations string, customFunction string, publishMessage string, messageHandler string, setup string) string {
	libraryCode := ``
	for i := 0; i < len(libraries); i++ {
		libraryCode += "#include <" + libraries[i] + ".h>\n"
	}

	codeTemplate := `

#define CONFIG_ESP32_COREDUMP_DATA_FORMAT_ELF
#define CONFIG_ESP32_COREDUMP_ENABLE
#define THINGNAME "ESP32_AWStest1"  //change this
#define AWS_IOT_PUBLISH_TOPIC "esp32/pub"
#define AWS_IOT_SUBSCRIBE_TOPIC "esp32/sub"

//Static-Libraries:
#include <WebServer.h>
#include <uri/UriBraces.h>
#include <Update.h>
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
void execOTA() {
  Serial.println("Connecting to: " + String(fileURL));

  http.begin(fileURL); // Specify the URL
  int httpCode = http.GET(); // Make the request

  if (httpCode > 0) { // Check for the returning code
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

  http.end(); // End the connection
}

void wifiSetup() {
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
}

void connectAWS() {
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
  client.subscribe("esp32/led");
  Serial.println("AWS IoT Connected!");
}

` + messageHandler + `

` + publishMessage + `

` + customFunction + `

` + setup + `

void loop() {
  client.loop();
  if (1 == receivedJson["active"]) {
    customFunc();
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
}
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
		if !slices.Contains(base, val) {
			base = append(base, val)
		}
	}
	return base
}
