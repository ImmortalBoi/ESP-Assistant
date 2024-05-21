import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

class MqttController extends GetxController {
  late MqttServerClient client;
  RxList<String> messages = <String>[].obs; // Use RxList for GetX

  @override
  void onInit() {
    super.onInit();
    _initializeClient();
  }

  Future<void> _initializeClient() async {
    client = MqttServerClient(
        'a2a8tevfyn336a-ats.iot.eu-central-1.amazonaws.com', 'PhoneAWS_test1');
    client.onSubscribed = (topic) {
      print("Subscribed Successfully");
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String newMessage =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        messages.add(newMessage); // Update the RxList
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
        await Future.delayed(Duration(milliseconds: 20));
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