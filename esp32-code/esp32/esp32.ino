#define CONFIG_ESP32_COREDUMP_DATA_FORMAT_ELF
#define CONFIG_ESP32_COREDUMP_ENABLE
#include <WiFi.h>
#include <WiFiClient.h>
#include <WebServer.h>
#include <uri/UriBraces.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Preferences.h>
#include <ThingsBoard.h>
#include <Arduino_MQTT_Client.h>

//Data Saving method
Preferences preferences;
//Web Server Setup
WebServer server(80);

// MQTT BROKER
const char *mqtt_broker = "demo.thingsboard.io";
const char *token = "lfpk4if8m0i3eyfsnglj";
const int mqtt_port = 1883;
constexpr uint16_t MAX_MESSAGE_SIZE = 512U;

WiFiClient espClient;
// Initalize the Mqtt client instance
Arduino_MQTT_Client mqttClient(espClient);
// Initialize ThingsBoard instance with the maximum needed buffer size
ThingsBoard tb(mqttClient, MAX_MESSAGE_SIZE);

// For telemetry
const int telemetrySendInterval = 2000;
uint32_t previousDataSend;

void sendWiFiScanHtml() {
  Serial.print("Request sent");
  int n = WiFi.scanNetworks();
  String json;
  StaticJsonDocument<200> doc;
  JsonArray wifiArray = doc.createNestedArray("wifi");
  if (n == 0) {
    Serial.println("no networks found");
  } else {
    for (int i = 0; i < n; ++i) {
      String ssid = WiFi.SSID(i);  // Create a copy of the SSID string
      wifiArray.add(ssid);         // Add the copied string to the JSON array
    }

    serializeJson(doc, json);
  }
  server.send(200, "application/json", json);
  WiFi.scanDelete();  // Delete the old scan results
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
  String password_AP = "TestingPassword";
  String ssid_AP = "ESP32";
  WiFi.softAP(ssid_AP, password_AP);
  Serial.println("Created AP");
  Serial.print("ESP AP IP: ");
  Serial.println(WiFi.softAPIP());
  Serial.println(Wifi)

  server.on(UriBraces("/reply"),sendWiFiScanHtml);
  server.on(UriBraces("/wifi/{}/pass/{}"), []() {
    Serial.print("input Recieved");
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
    preferences.putString("wifiIndex", wifiIndex);
    preferences.putString("pass", pass);
  });
  server.begin();
  Serial.println("HTTP server started");
  while (true) {
    if (WiFi.softAPgetStationNum() > 0) {
      Serial.println("Client connected");
    }
    server.handleClient();
    // wifiIndex = server.pathArg(0);
    // pass = server.pathArg(1);
    delay(3000);
  }
}

void setupMQTT() {
  Serial.println("Configuring MQTT Broker");
  while (!tb.connected()) {
    Serial.print(".");
    if (!tb.connect(mqtt_broker, token)) {
      Serial.println("Failed to connect... Reconnecting");
    } else {
      Serial.println("Connected to Thingsboard");
      ;
    }
  }
  // tb.setRpcCallback(RpcCallback);
}

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  pinMode(2, OUTPUT);
  WiFi.disconnect();
  preferences.begin("my-app", false);
  wifiSetup();
  setupMQTT();
}

void loop() {
  delay(1000);

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Reconnecting to wifi...");
    WiFi.reconnect();
    delay(5000);
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("Connected...");
      setupMQTT();
    }
  }

  if (!tb.connected()) {
    if (!tb.connect(mqtt_broker, token, mqtt_port)) {
      Serial.println("Failed to connect");
      return;
    }
  }

  tb.sendTelemetryData("temperature", random(10, 31));
  tb.sendTelemetryData("humidity", random(40, 90));

  tb.loop();
}
