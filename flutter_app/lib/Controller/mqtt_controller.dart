import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttController extends GetxController {
  var client = MqttServerClient('broker.emqx.io:1883', 'phone-test-123');
  RxList<String> messages = RxList<String>();

  MqttController() {
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;
    final connMessage = MqttConnectMessage()
        .withWillQos(MqttQos.atMostOnce)
        .authenticateAs('emqx', 'public');
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
    client.subscribe('emqx/esp32/s', MqttQos.exactlyOnce);
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
    });
  }


}
