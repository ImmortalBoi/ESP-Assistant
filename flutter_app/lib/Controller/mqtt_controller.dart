import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttController extends GetxController {
  late MqttServerClient client;
  RxList<String> messages = RxList<String>();
  RxString topic = ''.obs;

  MqttController(topic) {
    this.topic.value = topic;
    client = MqttServerClient('broker.emqx.io', 'phone-test-123');
    client.port = 1883;
    client.logging(on: true);
    client.keepAlivePeriod = 30;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;
    final connMessage = MqttConnectMessage()
        .withClientIdentifier('phone-test-123')
        .authenticateAs('ESP32testing', '123456');
    client.connectionMessage = connMessage;

    connect();
  }

  void connect() async {
    try {
      await client.connect();
      print("Connected Successfully");
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  void onConnected() {
    client.subscribe(topic.value, MqttQos.atLeastOnce);
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  void onSubscribed(String topic) {
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String newMessage =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      messages.add(newMessage);
      print(newMessage);
    });
  }

  void sendData(Map<String, dynamic> json) {}
}
