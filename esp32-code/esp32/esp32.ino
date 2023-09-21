#include <WiFi.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer *pServer;
BLEService *pService;
BLECharacteristic *pCharacteristic;
void wifiScan(){
   if (WiFi.status() == WL_CONNECTED) {
    return;
  }
  Serial.println("scan start");
  // WiFi.scanNetworks will return the number of networks found
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
      std::string rxValue = pCharacteristic->getValue();
      Serial.print("value received = ");
      Serial.println(rxValue.c_str());
      pCharacteristic->setValue(WiFi.SSID(i).c_str());
      delay(1000);
    }
  }
   Serial.println("\nWhat Network would you like to join?");

  while (Serial.available() == 0) {
  }

  int menuChoice = Serial.parseInt();

  String ssid = WiFi.SSID(menuChoice - 1);

  Serial.println(ssid);


  while(Serial.available() == 0){
  }

  String password;

  if(WiFi.encryptionType(menuChoice - 1) == 0){
    password = "";
  }
  else {
    Serial.println("Please enter your password: ");
    password = Serial.readString();
  }

  WiFi.begin(ssid,password);
  
  Serial.print("Connecting to WiFi");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  
  Serial.println("\nConnected to WiFi");


  // Wait a bit before scanning again
  delay(5000);
}
void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  BLEDevice::init("ESP32BLE");
  pServer = BLEDevice::createServer();
  pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristic->setValue("Hello World says Neil");
  pService->start();
  
  // BLEAdvertising *pAdvertising = pServer->getAdvertising();  // this still is working for backward compatibility
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println(F("Characteristic defined! Now you can read it in your phone!"));
  wifiScan();
}

void loop() {
      wifiScan();
      Serial.println(WiFi.macAddress());
}