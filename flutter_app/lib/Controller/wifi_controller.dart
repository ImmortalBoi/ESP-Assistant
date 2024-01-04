import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class WifiController extends GetxController {
  final RxString receivedData = ''.obs;
  final RxString deviceID = ''.obs;
  final RxString ssid = ''.obs;
  final RxString ip = ''.obs;
  final RxString uri = ''.obs;
  final RxString response = ''.obs;
  final RxInt retryCount = 0.obs;
  final RxList<String> receivedDataList = <String>[].obs;
  final TextEditingController textController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    // Request necessary permissions
    await [Permission.location].request();
  }

void connectToESPWifi() async {
  print("Trying to connect");
  await WiFiForIoTPlugin.findAndConnect("ESP32",password: "12345678").then((value) async {
    ip.value = (await WiFiForIoTPlugin.getIP())!;
    ip.value = changeLastOctetToOne(ip.value);
    uri.value = "http://${ip.value}/reply";

    http.Response? res;
    const maxRetryCount = 100; // Maximum number of retry attempts
    while(retryCount.value < maxRetryCount && (res == null || res.statusCode != 200)) {
      try {
        res = await http.get(Uri.parse(uri.value));
        response.value = "${res.statusCode}";
        if (res.statusCode != 200) {
          response.value = "status code isn't 200";
          await Future.delayed(const Duration(seconds: 2)); // Add delay here
          retryCount.value++;
        }
      } catch (e) {
        // Handle exception
        response.value = "$e";
        await Future.delayed(const Duration(seconds: 2)); // Add delay here
        retryCount.value++;
      }
    }
  });
}

  String changeLastOctetToOne(String ipAddress) {
    var octets = ipAddress.split('.');
    octets[3] = '1';
    return octets.join('.');
  }

}
