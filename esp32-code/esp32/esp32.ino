/**
  AWS Plug-n-Play Init connection
  Date: 23th March 2024
  Author(s): Mohamed Ahmed Abdel Aal <https://github.com/Devikaze> , Khaled Eldesuokey <https://github.com/ImmortalBoi>
  Purpose: Establishes an AWS IoT core connection to communicate via MQTT and receive OTA updates From S3 buckets 

  MIT License

  Copyright (c) [2024] [ESP-Assistant Team]

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*/

#define CONFIG_ESP32_COREDUMP_DATA_FORMAT_ELF
#define CONFIG_ESP32_COREDUMP_ENABLE

// MQTT BROKER CONFIG
#define THINGNAME "ESP32_AWStest2"  //change this based on the user deviceID
#define AWS_IOT_PUBLISH_TOPIC "esp32/pub" //changed this based on the user publish topic
#define AWS_IOT_SUBSCRIBE_TOPIC "esp32/sub" //changed this based on the user subscribe topic

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

// S3 Bucket Config
String fileURL = ""; //Put Bin file location 

// Variables to validate response from S3
long contentLength = 0;
bool isValidContentType = false;

// Global Environment Values
StaticJsonDocument<200> receivedJson;
//start of fully-generated part, this part is used for global pin delarations based on the prompt
#define PIN_14 14   
#define PIN_12 12



//end of the fully-generated part

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
    if (1 == receivedJson["active"]) {
    //start of fully-generated custom function here





   //end of fully-generated custom here
  }
  //start of fully-generated part, this part is generated based on the types of peripherals sent in the prompt
  if (typ.equals("peripheral1")) {   
    Serial.println("led called");
    Serial.println(value);
    Serial.println(pin);
    digitalWrite(pin, value);
  }
  else if (typ.equals("peripheral2")) {   
    Serial.println("led called");
    Serial.println(value);
    Serial.println(pin);
    digitalWrite(pin, value);
  }




  //end of fully-generated part
  else if(typ.equals("update")){
    Serial.println("update called");
    execOTA();
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
//start of fully-generated part, this part is used to initialize pins and 
pinMode(2, OUTPUT);
pinMode(PIN_14, OUTPUT);

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