import 'dart:async';
import 'dart:convert';
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
  final RxList<dynamic> receivedDataList = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final TextEditingController textController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    // Request necessary permissions
    await [Permission.location].request();
  }

  void requestESPWifiList() async {
    print("Trying to request 12345678");
    await WiFiForIoTPlugin.findAndConnect("ESP32", password: "12345678")
        .then((value) async {
      WiFiForIoTPlugin.forceWifiUsage(true);
      ip.value = (await WiFiForIoTPlugin.getIP())!;
      ip.value = changeLastOctetToOne(ip.value);
      uri.value = "http://${ip.value}/reply";
      bool foundBool = true;
      // uri.value = "https://www.google.com/";

      http.Response? res;
      // const maxRetryCount = 100; // Maximum number of retry attempts
      while (foundBool) {
        try {
          res = await http.get(Uri.parse(uri.value));
          response.value = res.body;
          if (res.statusCode != 200) {
            response.value = "status code isn't 200";
            await Future.delayed(const Duration(seconds: 2)); // Add delay here
            retryCount.value++;
          }
          if (res.statusCode == 200) {
            foundBool = false;
          }
        } catch (e) {
          // Handle exception
          response.value = "$e";
          await Future.delayed(const Duration(seconds: 2)); // Add delay here
          retryCount.value++;
        }
      }
      print('received request');
      receivedDataList.value = json.decode(res!.body)['wifi'];
      isLoading.value = false;
    });
  }

  Future<bool> connectESPWifi(String name, String password) async {
    print("Trying to send wifi information");
    await WiFiForIoTPlugin.findAndConnect("ESP32", password: "12345678")
        .then((value) async {
      WiFiForIoTPlugin.forceWifiUsage(true);
      ip.value = (await WiFiForIoTPlugin.getIP())!;
      ip.value = changeLastOctetToOne(ip.value);
      uri.value = "http://${ip.value}/wifi/${name}/pass/${password}";
      bool foundBool = true;
      // uri.value = "https://www.google.com/";

      http.Response? res;
      // const maxRetryCount = 100; // Maximum number of retry attempts
      while (foundBool) {
        try {
          res = await http.get(Uri.parse(uri.value));
          response.value = res.body;
          if (res.statusCode != 200) {
            response.value = "status code isn't 200";
            await Future.delayed(const Duration(seconds: 2)); // Add delay here
            retryCount.value++;
          }
          if (res.statusCode == 200) {
            foundBool = false;
          }
        } catch (e) {
          // Handle exception
          response.value = "$e";
          await Future.delayed(const Duration(seconds: 2)); // Add delay here
          retryCount.value++;
        }
      }
      print('ESP successfully connected');
    });
    return true;
  }

  String changeLastOctetToOne(String ipAddress) {
    var octets = ipAddress.split('.');
    octets[3] = '1';
    return octets.join('.');
  }
}
