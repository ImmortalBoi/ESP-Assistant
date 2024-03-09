#define CONFIG_ESP32_COREDUMP_DATA_FORMAT_ELF
#define CONFIG_ESP32_COREDUMP_ENABLE
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <WebServer.h>
#include <Preferences.h>
#include <pgmspace.h>
#include <MQTTClient.h>
#include <ArduinoJson.h>
#include <uri/UriBraces.h>
#include <ESPping.h>
//Waiting on libs (MQTT CLIENT/BROKER LIB)

//PROGRAM INSTANCES & GLOBAL VALS

//DATA MANAGEMENT INSTANCE
Preferences preferences;

// MQTT BROKER CONFIG
#define THINGNAME "arn:aws:iot:eu-central-1:473891061633:thing/ESP32-test-1"  //change this
#define AWS_IOT_PUBLISH_TOPIC   "esp32/pub"
#define AWS_IOT_SUBSCRIBE_TOPIC "esp32/sub"

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
static const char AWS_CERT_CRT[] PROGMEM = R"KEY(
-----BEGIN CERTIFICATE-----
MIIDWjCCAkKgAwIBAgIVAJXGkdperf9pYsvdgFECm7oDw5daMA0GCSqGSIb3DQEB
CwUAME0xSzBJBgNVBAsMQkFtYXpvbiBXZWIgU2VydmljZXMgTz1BbWF6b24uY29t
IEluYy4gTD1TZWF0dGxlIFNUPVdhc2hpbmd0b24gQz1VUzAeFw0yNDAzMDUxMTQ5
NTVaFw00OTEyMzEyMzU5NTlaMB4xHDAaBgNVBAMME0FXUyBJb1QgQ2VydGlmaWNh
dGUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCo2mv9YUJlfRo2Qsga
SJ6qqTaFkl8VkiNRW6eznCEYlnq044SJHz4L8gtdiwHYlt7sjlsuOBj+1pFfa6eG
3JK4OOSRdBZ1AL3GEvx0mDna4oOrkYYCI2hc9fcCnyA+RO4dOa/hhFyqlo8YS2v3
huWJYNyMHGopc5V6pOGgGJ700mcy/Hxa7PEj5QNYsbgO2maIIXD1FpgKYJ4u2Htt
8C8Wm1hOavMksYq7iHg7vOHap7Wg0vrMA/L/HEnP6zWmJNJmMR72yHX3G7VKS3A3
Ebn4q4Q7BYzegQbVhwuBAQ5ttjT2zcHFo63WD9otl3jtOWIt0bA+L5Sh5nMS5WSL
Z147AgMBAAGjYDBeMB8GA1UdIwQYMBaAFHs1fpkrBI0nXb8fLc9FiiXtP9D7MB0G
A1UdDgQWBBSAQ3XayfYeaYmQFF6PxincYBia+jAMBgNVHRMBAf8EAjAAMA4GA1Ud
DwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAQEAD9JBVZbaMNE42BGhsXRp8Iko
G8yJtmPBTs+w1Qkopypycp/138vwSxwzy9KuN2+GsyNZSNR6GuSkJ7gNHgt9thrH
446Xz3faX+kYY+aqZqA+WjvHZ2dJNCFqY2/DI2wv97x9MT13UAGECiYoxwxo6Alm
0eZ8e13B4iCyDfdfQ+Fm3khatUnkm+0sxxSvJ0UDnZJPFj9Rd8lQofiZDDi5anKm
TyYF1Mm9OsGATy6LlJp8CiNJye/73u5Aqcj/MztS43u1fAs2kJO47IJm3zps6z9Z
LWFlb1Ykv55si8SJ95ysuOUaV/2f5RQNrMy3aLrvQZUACd9/YOHqwAV4Pv1NqA==
-----END CERTIFICATE-----


)KEY";

// Device Private Key                                               //change this
static const char AWS_CERT_PRIVATE[] PROGMEM = R"KEY(
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAqNpr/WFCZX0aNkLIGkieqqk2hZJfFZIjUVuns5whGJZ6tOOE
iR8+C/ILXYsB2Jbe7I5bLjgY/taRX2unhtySuDjkkXQWdQC9xhL8dJg52uKDq5GG
AiNoXPX3Ap8gPkTuHTmv4YRcqpaPGEtr94bliWDcjBxqKXOVeqThoBie9NJnMvx8
WuzxI+UDWLG4DtpmiCFw9RaYCmCeLth7bfAvFptYTmrzJLGKu4h4O7zh2qe1oNL6
zAPy/xxJz+s1piTSZjEe9sh19xu1SktwNxG5+KuEOwWM3oEG1YcLgQEObbY09s3B
xaOt1g/aLZd47TliLdGwPi+UoeZzEuVki2deOwIDAQABAoIBAHVZj9HCBW4ZOt1Z
Hk6+B5+eCGleZ7zLGsaRR4TZTlsTQeZzdQoDb5DHwERbtoW7nOSUryP5Es4Re2jw
nbZpl4J278ty/aSFRl7hlRjHLvZDlLTpZ1QXHZH105y70KHWMBKZo/W8ktZv2rVM
vZWC6AXJDp5FpTZ3wPxCmRg15EtKyY6DWI8vJXmRsirvsu6hwEx63t74ZH9ELu92
pSg4Z+xOhn6aCbDHZW8PNdc+9XJHTx2NQ/ZWBRcSoZg/Co5cc0y1Nu5Ld3ZHQ7Uf
5vBERQIW+r3wLWWQYPXU9K61FiS/NXGN/b98EH3AiJerDKOQH7u0PPWGrV9CgqDo
PbzK7RECgYEA3mY/AWI4beSqqHy3jcFTKUXnijindzAHUBkZm528L4ceFRZFG+H7
ADW1ApfwXBHSKdtlW2jUnHqfKksFFi+KdWEOmscZRo0uCshY5cQ8C+mDfaOvlBs/
COdJvm6KfoN2cG6JdTi9Uq5a3PQ/weKYnRBtEnbWdBmqvJ+vP9+WG7MCgYEAwl0q
tFZw5L+ibUTKUW5u0Ay9aj3LrImFcTRI1U8oR1Hlh+V17TuAWh2peuXrn3gbeZEk
v8IvENa94SpNk4DWhx9yi0VcUSIMaR8RJPrBdhCpqNLdHFv22PxGRMLdrv35rZt5
txdYwdrrLNQ966WGzSF2ZWT9gbwPqMi6qr/mz1kCgYEAwoBhcfBYsaNerWQFk/AT
rvD4AqZxr4dNnfuVrcdRoa9l28NSRYRpZFGUMOR4zcy4JOs/xaX067VCJlbd5/1D
9kwf3bVqoY0vSzbUqH3qlfBvkx3onHsHsd21XNqIPQT0PHgvt1kcGodp5/ulFwf5
uMN44MEV5QvdioGNXytHuIkCgYBrVENmvm0tBF3PdTM78H2kycQ3TNSR/IcB0lt9
325go+raNm3+iOMB4GtcgGay8wJJCUt/0N1osQy9sDySfYz5pPX9zlmCPAkaa5tu
DkKSzfTCU17icC5J+FVdVzZPkdQ0eCyoXG4Y7qj7YmCnJgrgb+APcctDvvPuwpnB
/KKaUQKBgQCGjCdxhrH91ztNNZBhhaB0Sm/8LNgkJm4GaTmNYtB1kJYA2b7LoDli
dImKeR5Gy5Y57mE4jXmPqRlE+4Moo5xPxGT38OxbrjW3+tNeNSMtYdsZcP6egDgu
gx/xf6RVP8PfDqqI31dK8vaAQaFl97iW/L4z8Sgh37CTuCFzrfVMEA==
-----END RSA PRIVATE KEY-----

)KEY";

//WEB CLIENT INSTANCE
WebServer server(80);

//WIFI CLIENT INSTANCE
WiFiClientSecure espClient = WiFiClientSecure();

//MQTT CLIENT INSTANCE
MQTTClient client = MQTTClient(256);

void messageHandler(String &topic, String &payload) {
  Serial.println("incoming: " + topic + " - " + payload);

//  StaticJsonDocument<200> doc;
//  deserializeJson(doc, payload);
//  const char* message = doc["message"];
}

void publishMessage()
{
  StaticJsonDocument<200> doc;
  char jsonBuffer[512];
  serializeJson(doc, jsonBuffer); // print to client
 
  client.publish(AWS_IOT_PUBLISH_TOPIC, "hello");
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

  server.on("/reply", HTTP_GET, []() {
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

void connectAWS()
{
  // Configure WiFiClientSecure to use the AWS IoT device credentials
  espClient.setCACert(AWS_CERT_CA);
  espClient.setCertificate(AWS_CERT_CRT);
  espClient.setPrivateKey(AWS_CERT_PRIVATE);

  // Connect to the MQTT broker on the AWS endpoint we defined earlier
  client.begin(AWS_IOT_ENDPOINT, 8883 , espClient);

  // Create a message handler
  client.onMessage(messageHandler);

  Serial.println("Connecting to AWS IOT");
  while ()
  {
    !client.connect(THINGNAME)
    Serial.print(".");
    delay(100);
  }

  if (!client.connected())
  {
    Serial.println("AWS IoT Timeout!");
    return;
  }

  // Subscribe to a topic
  client.subscribe(AWS_IOT_SUBSCRIBE_TOPIC);

  Serial.println("AWS IoT Connected!");
}

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  pinMode(2, OUTPUT);
  WiFi.disconnect();
  preferences.begin("my-app", false);
  wifiSetup();
  connectAWS();
}

void loop() {
  bool ret = Ping.ping("a2a8tevfyn336a-ats.iot.eu-central-1.amazonaws.com");
  if(ret){
    Serial.println("success");
  }
  else{
    Serial.println("fail");
  }
  delay(1000);
  publishMessage();
  // if (WiFi.status() != WL_CONNECTED) {
  //   Serial.println("Connecting to wifi...");
  //   delay(5000);
  //   if (WiFi.status() == WL_CONNECTED) {
  //     Serial.println("Connected...");
  //     //connectAWS();
  //   }
  }

