#include <WiFi.h>
#include <WiFiClient.h>
#include <WebServer.h>
#include <uri/UriBraces.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>
#include <Preferences.h>
#include <Update.h>

//Data Saving method
Preferences preferences;
//Web Server Setup
WebServer server(80);
// MQTT BROKER
const char *mqtt_broker = "demo.thingsboard.io";
const char *mqtt_username = "5ib4axhk1dd4k6od695v";
const char *mqtt_password = "t26rl0qolkdhl3cr01kp";
const char *client_ID = "vk9wzyduu0vnk62l8kmu";
const char *telemetry = "v1/devices/me/telemetry";
const int mqtt_port = 1883;
// App protocol
const char *topic_publish = "emqx/esp32/p";
const char *topic_subscribe = "emqx/esp32/s";
WiFiClient espClient;
PubSubClient client(espClient);
// Peripherals ID
Servo myservo;

void callback(char *topic, byte *payload, unsigned int length) {
  Serial.print("Message arrived in topic: ");
  Serial.println(topic);
  Serial.print("Message:");
  String message;

  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  DynamicJsonDocument doc(1024);
  deserializeJson(doc, message);
  JsonObject root = doc.as<JsonObject>();
  uint8_t PinNumb;
  uint8_t PinState;
  for (JsonPair kv : root) {
    PinNumb = atoi(kv.key().c_str());
    PinState = kv.value();
    if (strcmp(topic, "emqx/esp32/LED") == 0) {
      digitalWrite(PinNumb, PinState);
    }
    if (strcmp(topic, "emqx/esp32/SERVO") == 0) {
      int pos = 0;
      myservo.attach(PinNumb);
      myservo.write(PinState);
    }
    if (strcmp(topic, "emqx/esp32/TEMPERATURE") == 0) {
      int adcVal = analogRead(PinNumb);
      float milliVolt = adcVal * (3300.0 / 4096.0);
      std::string tempC = std::to_string(milliVolt / 10);
      client.publish("emqx/esp32/TEMPERATURE", tempC.c_str());
    }
    if (strcmp(topic, "emqx/esp32/UPDATE") == 0) {
      Serial.println("Update ongoing");
      payload[length] = '\0';  // Null-terminate the payload
      String updateUrl = String((char *)payload);

      // // Perform OTA update
      // t_httpUpdate_return result = ESPhttpUpdate.update(updateUrl);
      // switch (result) {
      //   case HTTP_UPDATE_FAILED:
      //     Serial.printf("HTTP_UPDATE_FAILED Error (%d): %s\n", ESPhttpUpdate.getLastError(), ESPhttpUpdate.getLastErrorString().c_str());
      //     break;

      //   case HTTP_UPDATE_NO_UPDATES:
      //     Serial.println("HTTP_UPDATE_NO_UPDATES");
      //     break;

      //   case HTTP_UPDATE_OK:
      //     Serial.println("Update complete");
      //     break;
      // }
    }
  }

  Serial.println(message);
  Serial.println("-----------------------");
}

void sendWiFiScanHtml() {
  int n = WiFi.scanNetworks();
  String creds = "";

  if (n == 0) {
    Serial.println("no networks found");
  } else {
    for (int i = 0; i < n; ++i) {
      creds = WiFi.SSID(i).c_str();
      +"," + creds;
    }
  }
  String response = creds;
  server.send(200, "text/plaintext", response);
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
  while (wifiIndex == "") {
    server.handleClient();
    wifiIndex = server.pathArg(0);
    pass = server.pathArg(1);
    delay(3000);
  }
}

// void wifiScan() {
//   if (WiFi.status() == WL_CONNECTED) {
//     return;
//   }

//   Serial.println("scan start");
//   int n = WiFi.scanNetworks();
//   String networkarray[n];
//   Serial.println("scan done");

//   if (n == 0) {
//     Serial.println("no networks found");
//     return;
//   } else {
//     Serial.print(n);
//     Serial.println(" networks found");
//     for (int i = 0; i < n; ++i) {
//       Serial.print("value received = ");
//     }
//   }
//   std::string wifiCred[2];
//   std::string s = "";
//   std::string delimiter = ";;;";

//   while (s == "") {
//     delay(100);
//   }

//   size_t pos = 0;
//   std::string token;
//   while ((pos = s.find(delimiter)) != std::string::npos) {
//     token = s.substr(0, pos);
//     wifiCred[0] = token;
//     Serial.println(token.c_str());
//     s.erase(0, pos + delimiter.length());
//     Serial.println(s.c_str());
//     wifiCred[1] = s;
//   }

//   WiFi.begin(wifiCred[0].c_str(), wifiCred[1].c_str());

//   Serial.print("Connecting to WiFi");

//   while (WiFi.status() != WL_CONNECTED) {
//     delay(1000);
//     Serial.print(".");
//     // if () {         //todo add refresh wifi function cond
//     // statements
//     // }
//   }

//   Serial.println("\nConnected to WiFi");

//   // Wait a bit before scanning again
//   delay(5000);
// }

void setupMQTT() {
  Serial.println("Configuring MQTT Broker");
  client.setServer(mqtt_broker, mqtt_port);

  while (!client.connected()) {
    //client_ID += String(WiFi.macAddress());
    Serial.println("Connecting to MQTT Broker with client ID = ");
    Serial.println(client_ID);
    if (client.connect(client_ID, mqtt_username, mqtt_password)) {
      Serial.println("Connected to public MQTT!");
    } else {
      Serial.println("Failed to connect with state: ");
      Serial.println(client.state());
      delay(2000);
    }
  }
  client.publish(topic_publish, "ESP32 Hello World");
  client.subscribe(topic_subscribe);
  client.subscribe("emqx/esp32/LED");
  client.subscribe("emqx/esp32/SERVO");
  client.subscribe("emqx/esp32/TEMPERATURE");
  client.subscribe("emqx/esp32/UPDATE");
  client.subscribe("emqx/esp32/UPDATE");
  client.setCallback(callback);
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
  client.loop();
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Reconnecting to wifi...");
    WiFi.reconnect();
    delay(5000);
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("Connected...");
      setupMQTT();
    }
  }
}