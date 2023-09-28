import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class WifiConnectController extends GetxController {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  final RxString receivedData = ''.obs;
  final RxString deviceID = ''.obs;
  final RxString ssid = ''.obs;
  final RxString response = ''.obs;
  final RxBool isSubscribed = false.obs;
  final RxList<String> receivedDataList = <String>[].obs;
  final TextEditingController textController = TextEditingController();

  void setDeviceID(String deviceId) {
    if (deviceId.isNotEmpty) {
      isSubscribed.value = true;
      deviceID.value = deviceId;
      subscribeToCharacteristic(deviceId);
    }
  }

  void subscribeToCharacteristic(String deviceId){
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b"),
        characteristicId: Uuid.parse("ddbc2cd8-3336-41ab-9b56-6ea85b2fefd7"),
        deviceId: deviceId,
      );

      _ble.subscribeToCharacteristic(characteristic).listen((data) {
        final receivedData = String.fromCharCodes(data);
        if (!receivedDataList.contains(receivedData)) {
          print("I LISTENED");
          receivedDataList.add(receivedData);
        }
      });
    } catch (e) {
      // Handle any errors
      print('Error subscribing to characteristic: $e');
    }
  }

  void writeCharacteristic(String text) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b"),
      characteristicId: Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8"),
      deviceId: deviceID.value,
    );

    try {
      await _ble.writeCharacteristicWithResponse(characteristic, value: "${ssid.value};;;$text".codeUnits).then((value) => response.value);
    } catch (e) {
      // Handle any errors
      print('Error writing to characteristic: $e');
    }
  }
}
