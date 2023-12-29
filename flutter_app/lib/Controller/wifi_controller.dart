import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiController extends GetxController {
  final RxString receivedData = ''.obs;
  final RxString deviceID = ''.obs;
  final RxString ssid = ''.obs;
  final RxString response = ''.obs;
  final RxList<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[].obs;
  final RxList<String> receivedDataList = <String>[].obs;
  final TextEditingController textController = TextEditingController();

  void startScan() async {
    // check platform support and necessary requirements
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch(can) {
      case CanStartScan.yes:
        // start full scan async-ly
        final isScanning = await WiFiScan.instance.startScan();
        //...
        break;
      // ... handle other cases of CanStartScan values
      case CanStartScan.notSupported:
        // TODO: Handle this case.
      case CanStartScan.noLocationPermissionRequired:
        // TODO: Handle this case.
      case CanStartScan.noLocationPermissionDenied:
        // TODO: Handle this case.
      case CanStartScan.noLocationPermissionUpgradeAccuracy:
        // TODO: Handle this case.
      case CanStartScan.noLocationServiceDisabled:
        // TODO: Handle this case.
      case CanStartScan.failed:
        // TODO: Handle this case.
    }
  }

  void getScannedResults() async {
  // check platform support and necessary requirements
  final can = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
  switch(can) {
    case CanGetScannedResults.yes:
      // get scanned results
      accessPoints.value = await WiFiScan.instance.getScannedResults();
      // ...
      break;
    // ... handle other cases of CanGetScannedResults values
    case CanGetScannedResults.notSupported:
      // TODO: Handle this case.
    case CanGetScannedResults.noLocationPermissionRequired:
      // TODO: Handle this case.
    case CanGetScannedResults.noLocationPermissionDenied:
      // TODO: Handle this case.
    case CanGetScannedResults.noLocationPermissionUpgradeAccuracy:
      // TODO: Handle this case.
    case CanGetScannedResults.noLocationServiceDisabled:
      // TODO: Handle this case.
  }
}
}
