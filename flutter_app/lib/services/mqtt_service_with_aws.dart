import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

class MqttService {
  late MqttServerClient client;
  List<String> messages = [];

  MqttService() {
    _initializeClient();
  }
  // Future<dynamic> sendPeripheralData(List<Peripheral> peripherals,
  //     String request, String result, String resultDataType) async {
  //   const String url =
  //       'http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:8080/config';
  //   final Map<String, dynamic> data = {
  //     'Peripherals':
  //         peripherals.map((peripheral) => peripheral.toMap()).toList(),
  //     'Request': request,
  //     'Result': result,
  //     'Result_Datatype': resultDataType,
  //   };

  //   final String json = jsonEncode(data);
  //   print('JSON Payload: $json');

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: json,
  //     );

  //     if (response.statusCode == 200) {
  //       await mqttService.waitForConnection();

  //       try {
  //         await mqttService.publishMessageOnSuccess(
  //             'esp32/sub', '{"type":"update"}');
  //         print("MQTT message sent successfully.");
  //         return true;
  //       } catch (e) {
  //         print("Error sending MQTT message: $e");
  //         return false;
  //       }
  //     } else {
  //       print('Failed to send data');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error sending data: $e');
  //     return false;
  //   }
  // }

  Future<void> _initializeClient() async {
    client = MqttServerClient(
        'a2a8tevfyn336a-ats.iot.eu-central-1.amazonaws.com', 'PhoneAWS_test1');
    client.onSubscribed = (topic) {
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String newMessage =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        messages.add(newMessage);
        print(newMessage);
      });
    };
    client.port = 8883;
    client.logging(on: false);
    client.secure = true;
    client.useWebSocket = false;

    final rootCa = await rootBundle.loadString('assets/AmazonRootCA1.pem');
    final privateKey = await rootBundle.loadString('assets/private.pem.key');
    final deviceCertificate =
        await rootBundle.loadString('assets/device_certificate.crt');

    final rootCaBytes = Uint8List.fromList(rootCa.codeUnits);
    final privateKeyBytes = Uint8List.fromList(privateKey.codeUnits);
    final deviceCertificateBytes =
        Uint8List.fromList(deviceCertificate.codeUnits);

    client.securityContext = SecurityContext.defaultContext;
    client.securityContext.setTrustedCertificatesBytes(rootCaBytes);
    client.securityContext.usePrivateKeyBytes(privateKeyBytes);
    client.securityContext.useCertificateChainBytes(deviceCertificateBytes);

    await _connectClient();
    client.subscribe("esp32/pub", MqttQos.atLeastOnce);

  }

  Future<void> publishMessage(String topic, String payload) async {
    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      await _connectClient();
    }

    Uint8List payloadBuffer = Uint8List.fromList(utf8.encode(payload));
    Uint8Buffer payloadBufferAsUint8Buffer = Uint8Buffer();
    payloadBufferAsUint8Buffer.addAll(payloadBuffer);

    print("Payload to be sent: $payload");
    client.publishMessage(
        topic, MqttQos.atLeastOnce, payloadBufferAsUint8Buffer);
  }

  Future<void> publishMessageOnSuccess(String topic, String payload) async {
    try {
      if (client.connectionStatus!.state != MqttConnectionState.connected) {
        await _connectClient();
      }

      Uint8List payloadBuffer = Uint8List.fromList(
        utf8.encode(payload),
      );
      Uint8Buffer payloadBufferAsUint8Buffer = Uint8Buffer();
      payloadBufferAsUint8Buffer.addAll(payloadBuffer);

      print("Payload to be sent: $payload");
      client.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        payloadBufferAsUint8Buffer,
      );

      print("Type update sent successfully.");
    } catch (e) {
      print("Error publishing message: $e");
    }
  }

  Future<void> _connectClient() async {
    try {
      await client.connect();
      while (client.connectionStatus!.state != MqttConnectionState.connected) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      print("Client connected successfully.");
    } catch (e) {
      print("Failed to connect to MQTT broker: $e");
    }
  }

  Future<void> waitForConnection() async {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      return;
    }
    while (client.connectionStatus!.state != MqttConnectionState.connected) {
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
}
// import 'package:mqtt_client/mqtt_client.dart' as mqtt; // Example library

// Future<void> connectAndSubscribe(String brokerAddress, int brokerPort, String topic) async {
//   final client = mqtt.MqttClient(brokerAddress, 'yourClientId');
//   client.logging(onPrint: print); // Optional logging for debugging

//   await client.connect();

//   final mqtt.MqttSubscribeMessage subscription = mqtt.MqttSubscribeMessage(
//     topic: topic, // Replace with actual topic
//     qos: mqtt.Qos.atLeastOnce, // Adjust QoS level as needed
//   );

// client.subscribe(subscription);

//   // Handle incoming messages on the subscribed topic
//   client.unsubscribe(topic); // Unsubscribe when finished
//   await client.disconnect();
// }

// void main() async {
//   final brokerAddress = 'your_broker_address';
//   final brokerPort = 1883; // Typical port for MQTT
//   final topic = 'users/device_dc7ff370-c543-47a1-8ea4-8c3b19debcbb/phone/data'; // Example topic

 // await connectAndSubscribe(brokerAddress, brokerPort, topic);
// }
