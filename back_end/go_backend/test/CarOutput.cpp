

#define CONFIG_ESP32_COREDUMP_DATA_FORMAT_ELF
#define CONFIG_ESP32_COREDUMP_ENABLE
#define THINGNAME "device_6d3f914d-3fd4-423e-891a-dcc0de83c5e9"  //change this
#define AWS_IOT_PUBLISH_TOPIC "users/device_dc7ff370-c543-47a1-8ea4-8c3b19debcbb/devices/device_6d3f914d-3fd4-423e-891a-dcc0de83c5e9data"
#define AWS_IOT_SUBSCRIBE_TOPIC "users/device_dc7ff370-c543-47a1-8ea4-8c3b19debcbb/phone/data"

//Static-Libraries:
#include <WebServer.h>
#include <uri/UriBraces.h>
#include <Update.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <WiFi.h.h>
#include <HTTPClient.h.h>
#include <Preferences.h.h>

// Program Instances & Global Values:
Preferences preferences;
WebServer server(80);
WiFiClientSecure espClient = WiFiClientSecure();
HTTPClient http;
PubSubClient client(espClient);
String fileURL = "https://esp32-assistant-bucket.s3.eu-central-1.amazonaws.com/User-sketches/test/6/testing.ino.bin";
long contentLength = 0;
bool isValidContentType = false;
StaticJsonDocument<200> receivedJson;
WebServer server = WebServer(80);
StaticJsonDocument<200> sentJson;// Pin Definitions
const int IN1_PIN = 27;
const int IN2_PIN = 26;
const int IN3_PIN = 25;
const int IN4_PIN = 33;
const int ENA_PIN = 14;
const int ENB_PIN = 32;

const char AWS_IOT_ENDPOINT[] = "a2a8tevfyn336a-ats.iot.eu-central-1.amazonaws.com";  //change this

// Amazon Root CA 1
static const char AWS_CERT_CA[] PROGMEM = R"EOF(
-----BEGIN CERTIFICATE-----
MIIDQTCCAimgAwIBAgITBmyfz5m/jAo54vB4ikPmljZbyjANBgkqhkiG9w0BAQsF
ADA5MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRkwFwYDVQQDExBBbWF6
b24gUm9vdCBDQSAxMB4XDTE1MDUyNjAwMDAwMFoXDTM4MDExNzAwMDAwMFowOTEL
MAkGA1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJv
b3QgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJ4gHHKeNXj
ca9HgFB0fW7Y14h29Jlo91ghYPl0hAEvrAIthtOgQ3pOsqTQNroBvo3bSMgHFzZM
9O6II8c+6zf1tRn4SWiw3te5djgdYZ6k/oI2peVKVuRF4fn9tBb6dNqcmzU5L/qw
IFAGbHrQgLKm+a/sRxmPUDgH3KKHOVj4utWp+UhnMJbulHheb4mjUcAwhmahRWa6
VOujw5H5SNz/0egwLX0tdHA114gk957EWW67c4cX8jJGKLhD+rcdqsq08p8kDi1L
93FcXmn/6pUCyziKrlA4b9v7LWIbxcceVOF34GfID5yHI9Y/QCB/IIDEgEw+OyQm
jgSubJrIqg0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AYYwHQYDVR0OBBYEFIQYzIU07LwMlJQuCFmcx7IQTgoIMA0GCSqGSIb3DQEBCwUA
A4IBAQCY8jdaQZChGsV2USggNiMOruYou6r4lK5IpDB/G/wkjUu0yKGX9rbxenDI
U5PMCCjjmCXPI6T53iHTfIUJrU6adTrCC2qJeHZERxhlbI1Bjjt/msv0tadQ1wUs
N+gDS63pYaACbvXy8MWy7Vu33PqUXHeeE6V/Uq2V8viTO96LXFvKWlJbYK8U90vv
o/ufQJVtMVT8QtPHRh8jrdkPSHCa2XV4cdFyQzR1bldZwgJcJmApzyMZFo6IQ6XU
5MsI+yMRQ+hDKXJioaldXgjUkK642M4UwtBV8ob2xJNDd2ZhwLnoQdeXeGADbkpy
rqXRfboQnoZsG4q5WTP468SQvvG5
-----END CERTIFICATE-----
)EOF";

// Device Certificate                                               //change this
static const char AWS_CERT_CRT[] PROGMEM = R"KEY(-----BEGIN CERTIFICATE-----
MIIDWjCCAkKgAwIBAgIVAIh7sjnOwD6V0ckpH1HMpNr05kBMMA0GCSqGSIb3DQEB
CwUAME0xSzBJBgNVBAsMQkFtYXpvbiBXZWIgU2VydmljZXMgTz1BbWF6b24uY29t
IEluYy4gTD1TZWF0dGxlIFNUPVdhc2hpbmd0b24gQz1VUzAeFw0yNDA0MjYxNTAw
MjVaFw00OTEyMzEyMzU5NTlaMB4xHDAaBgNVBAMME0FXUyBJb1QgQ2VydGlmaWNh
dGUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDcO88e5af898Ic7u6n
LhNzkWqMMltF4ZyUiWkSn4AmmuMVfnxTv3rrQXkbFLCxQo/4J8oQ9BnbhfMN4blV
F2OqwnvOzE3BLew62+zrUzt+qzfFwR2CwrgkhiNNIlzC8cBiLCgPLXcm2IKawQVJ
RBfXfr+pevrle5JHfp4eGa1KCfYkiYhyhrv+FVY8pDn1go1MU7XOrOtm4mjftb+M
lg7TiUxzLwLTjqLAzB17m/2yymkB7kY2hDQEAQHPUuS8U39P0GosvzMzn5+0Ln71
zMTHWbHGyvP3GcTagzmbmmz/38qvdD0RS+thChNzq+I55RvktDZDCfGDmohiOuKb
it2fAgMBAAGjYDBeMB8GA1UdIwQYMBaAFL7ZR1TWQLWRSvrO4zQtBLBXyeNrMB0G
A1UdDgQWBBTbPY0t6VgsQxw5tgbob3yaH6afSzAMBgNVHRMBAf8EAjAAMA4GA1Ud
DwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAQEANzJ7mWc080icsIMQr3FIfLr3
Nv7VKIBmi4ngIrzgpWO4jDP9YaQGgbL8tRsOEJCAx6rpr/pwqcCbeHh4y3LcjcfY
9HjwQqjvwR+/cQSphSRhX1IhjpWH/+aHB4sZUAuqJvNr8c3Uln4FNxHA08o6F2cm
Yg/HzT5a87x5Auwyqb5/HH0cXVXc3+TQE3yAfEurUFhM4NCApJ/8dlOXSrmmx1aS
AcvJcLP0DT/clT6tDmnbOnFjYHoMCNTMIrrmMg5PKFry9kEFXjDYaNmvNXuulVwM
rSFY8ig0TcCNKV+5I0rXTNXd3HCB9bkkt1Z8RP3iG7Wt0ZJeN0gkYJiBDqK4bg==
-----END CERTIFICATE-----
)KEY";

// Device Private Key                                               //change this
static const char AWS_CERT_PRIVATE[] PROGMEM = R"KEY(-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEA3DvPHuWn/PfCHO7upy4Tc5FqjDJbReGclIlpEp+AJprjFX58
U79660F5GxSwsUKP+CfKEPQZ24XzDeG5VRdjqsJ7zsxNwS3sOtvs61M7fqs3xcEd
gsK4JIYjTSJcwvHAYiwoDy13JtiCmsEFSUQX136/qXr65XuSR36eHhmtSgn2JImI
coa7/hVWPKQ59YKNTFO1zqzrZuJo37W/jJYO04lMcy8C046iwMwde5v9ssppAe5G
NoQ0BAEBz1LkvFN/T9BqLL8zM5+ftC5+9czEx1mxxsrz9xnE2oM5m5ps/9/Kr3Q9
EUvrYQoTc6viOeUb5LQ2Qwnxg5qIYjrim4rdnwIDAQABAoIBACgpI/D/ci3YRGag
T5be+R8XAnYEbM6GgNY5ZJbHzUe88PIneaaQAWtLKjl9AWehur1HDDshOGHmwFbk
tbZFqKAoDQm+CePTawOkvUSAjhXgRTBjsez5czj92Qwk2wOVsD52zOtPoC3OR6rO
zhb5OtvKOks+qOgWK6ur9EuK5SXd6ou/Vbq+vfjJ1JvBjqeAdjuvC59kLpi8ZBXW
eG1Ys1YVB98IYi8CKnU3JTyTxT53J6VQ012cRbOw0I6NfUeo0YSPItujS23OFOJa
gZzEipQC1XhEWPybPRrc3A/i9cepSFFUCB5ShzAhJB6w1WTu18a/4w/1NxrNJCPh
tu0iELkCgYEA81VrObAFvPPmbPR8HroxcsX0xoN7xXxmAN6uhOGtgwFgXDKKsc/C
7mDqDLLcjdRgYwhxQzLVV7bk7vltT446/fwnSPaVCNTG+LB/z8F10zsTxn6q8zaJ
EPCCj15Le51i+HALKE4hErO0M6UarKMlCH9ybAD2a4+xflEYVAaXlZMCgYEA57KR
J+Eap1pjD/oIDVQOK1ZL7YydhCXX4H26bg9ehG93Z2TF9sK2Ox/oWoVALgmh/laz
mUsblfo+MQ1rJR/pvWH0rAXxdpVk5qrteDChapBKmZSk3uiIGQoc9qcl6GVmRAAg
PaWoNh85CVhuuFM0lviIP0MIxMeV3RUvxxfaX0UCgYAMviRnWPhz9LHUctktIsME
J6mx26DXrrQIx6CMBOV5PtE1AtCQjzi+EwUutQ8nvj9t8Ds+MaNKfKFwgk9fIyuj
sVi9UWxskff5fgSzdIYfEbDvbCK3qdtzr6SmrWF2j79nEzcCXVUODasaKUNEVybR
UxtC3KoK5/N7kfOcMtwtUQKBgBpibEM1UBq0oUlFeLtD0iU/O4A+ngVZZd7rklpM
J8A/DULZ5+00uRm8hXIhcHCNqkPTTbpsIiUPDRv64jOlEbH+QKWCO7/8PTRDTK1+
JDOFYOliUvALXMw1KZ0w5ZE0UtP1i7ZZcfFP1ufoiRs2Zmu2u5UwpgP6kmdNrVYn
sjddAoGAO9B3pG1oF07oJW1sdKAin1lGsUluFYym1w/Zkj2oVtVOq70NjHZi2tnX
t6flgRIGncpvNFGjl6PotQuwDU9pEytGkRdFgcPELzgcYgwZO4x8ftQYlhE3dtkD
GXotpew8/6GUovUqPa8iE5O7wug+xRTPuX0NeFKhV2sj1XSRdDE=
-----END RSA PRIVATE KEY-----
)KEY";


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

void updatefunction(int index) {
  Serial.println("update called");
  String strindex = String(index);
  String index1 = "http://esp32-assistant-bucket.s3.eu-central-1.amazonaws.com/User-sketches/test/" + strindex;
  Serial.println(index1);
  String index2 = index1 + "/testing.ino.bin";
  Serial.println(index2);
  fileURL = index2;
  execOTA();
}

void publishMessage() {  
  sentJson.clear();
  sentJson["IN1_PIN"] = digitalRead(IN1_PIN);
  sentJson["IN2_PIN"] = digitalRead(IN2_PIN);
  sentJson["IN3_PIN"] = digitalRead(IN3_PIN);
  sentJson["IN4_PIN"] = digitalRead(IN4_PIN);
  sentJson["ENA_PIN"] = digitalRead(ENA_PIN);
  sentJson["ENB_PIN"] = digitalRead(ENB_PIN);
  char jsonBuffer[512];
  serializeJson(sentJson, jsonBuffer);   Serial.println("Message published!");
  client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
} 

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
  const int index = receivedJson["update"];  if (receivedJson["update"] > -1) {
    updatefunction(receivedJson["update"]);
  }  if (1 == receivedJson["active"]) {
    client.loop();
  }  if (typ.equals("IN_PIN")) {   
    Serial.println("IN_PIN Called");
    Serial.println(value);
    Serial.println(pin);
    digitalWrite(pin, value);
  }
} 

void setup() {  
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  WiFi.disconnect();
  preferences.begin("my-app", false);
  wifiSetup();
  connectAWS();
  printSuccess();
  pinMode(IN1_PIN, INPUT);
  pinMode(IN2_PIN, INPUT);
  pinMode(IN3_PIN, INPUT);
  pinMode(IN4_PIN, INPUT);
  pinMode(ENA_PIN, INPUT);
  pinMode(ENB_PIN, INPUT);
} 


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
