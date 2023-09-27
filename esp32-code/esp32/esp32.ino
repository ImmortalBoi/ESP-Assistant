#include <WiFi.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include <PubSubClient.h>

//UUID BLE Service
#define SERVICE_UUID          "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_R_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define CHARACTERISTIC_S_UUID "ddbc2cd8-3336-41ab-9b56-6ea85b2fefd7"
//BLE objects
BLEServer *pServer;
BLEService *pService;
BLECharacteristic *pCharacteristicGet;
BLECharacteristic *pCharacteristicSend;
BLEDescriptor pCharacteristicGetDescriptor(BLEUUID((uint16_t)0x2902));
BLEDescriptor pCharacteristicSendDescriptor(BLEUUID((uint16_t)0x2902));
bool deviceConnected = false;
// MQTT BROKER
const char *mqtt_broker = "broker.emqx.io";
const char *mqtt_username = "emqx";
const char *mqtt_password = "public";
const int mqtt_port = 1883;
// App protocol
const char *topic_publish = "emqx/esp32/p";
const char *topic_subscribe = "emqx/esp32/s";
WiFiClient espClient;
PubSubClient client(espClient);

class MyServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
  };
  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
  }
};

void callback(char *topic, byte *payload, unsigned int length) {
    Serial.print("Message arrived in topic: ");
    Serial.println(topic);
    Serial.print("Message:");
    String message;
    for (int i = 0; i < length; i++) {
       message += (char) payload[i];
    }
    Serial.println(message);
    if(message == "on"){
      digitalWrite(2, HIGH);
    }
    if(message == "off"){
      digitalWrite(2, LOW);
    }
    Serial.println(message);
    Serial.println("-----------------------");
}

void wifiScan(){
   if (WiFi.status() == WL_CONNECTED) {
    return;
  }

  Serial.println("scan start");
  int n = WiFi.scanNetworks();
  String networkarray[n];
  Serial.println("scan done");

  if (n == 0) {
      Serial.println("no networks found");
      return;
  } else {
    Serial.print(n);
    Serial.println(" networks found");
    for (int i = 0; i < n; ++i) {
      std::string rxValue = pCharacteristicSend->getValue();
      Serial.print("value received = ");
      Serial.println(rxValue.c_str());
      pCharacteristicSend->setValue(WiFi.SSID(i).c_str());
      pCharacteristicSend->notify();
      delay(3000);
    }
  }
  //  Serial.println("\nWhat Network would you like to join?");

  // while (Serial.available() == 0) {
  // }

  // int menuChoice = Serial.parseInt();

  // String ssid = WiFi.SSID(menuChoice - 1);

  // Serial.println(ssid);


  // while(Serial.available() == 0){
  // }

  // String password;

  // if(WiFi.encryptionType(menuChoice - 1) == 0){
  //   password = "";
  // }
  // else {
  //   Serial.println("Please enter your password: ");
  //   password = Serial.readString();
  // }

  // WiFi.begin(ssid,password);
  
  // Serial.print("Connecting to WiFi");
  
  // while (WiFi.status() != WL_CONNECTED) {
  //   delay(1000);
  //   Serial.print(".");
  // }
  
  // Serial.println("\nConnected to WiFi");


  // // Wait a bit before scanning again
  // delay(5000);
}

void setupMQTT(){
  Serial.println("Configuring MQTT Broker");
  client.setServer(mqtt_broker,mqtt_port);

  while(!client.connected()){
    String client_ID = "ESP32-client-";
    client_ID += String(WiFi.macAddress());
    Serial.println("Connecting to MQTT Broker with client ID = ");
    Serial.println(client_ID.c_str());
    if(client.connect(client_ID.c_str(),mqtt_username,mqtt_password)) {
      Serial.println("Connected to public MQTT!");
    }
    else {
      Serial.println("Failed to connect with state: ");
      Serial.println(client.state());
      delay(2000);
    }
  }
  client.publish(topic_publish,"ESP32 Hello World");
  client.subscribe(topic_subscribe);
  client.setCallback(callback);
}

void setupBLE(){
  BLEDevice::init("ESP32BLE");
  pServer = BLEDevice::createServer();
  pService = pServer->createService(SERVICE_UUID);
  pServer->setCallbacks(new MyServerCallbacks());
  pCharacteristicGet = pService->createCharacteristic( //Receive Data
                                         CHARACTERISTIC_R_UUID,
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristicGetDescriptor.setValue("Read Data Here");
   pCharacteristicGet->addDescriptor(&pCharacteristicGetDescriptor); 
  pCharacteristicSend = pService->createCharacteristic( //Send Data
                                         CHARACTERISTIC_S_UUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_NOTIFY
                                       );
  pCharacteristicSendDescriptor.setValue("Send Data Here");    
  pCharacteristicSend->addDescriptor(&pCharacteristicSendDescriptor);                                   
  pCharacteristicSend->setValue("Hello World ESP32");
  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.print("Connecting to device via bluetooth.");
  while(!deviceConnected){
    Serial.print(".");
    delay(1000);
  }
}
void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  setupBLE();
  Serial.println("Characteristics defined! Now you can read it in your phone!");
  wifiScan();
  //setupMQTT();
}

void loop() {
      wifiScan();
      std::string rxValue = pCharacteristicGet->getValue();
      Serial.print("value received = ");
      Serial.println(rxValue.c_str());
}