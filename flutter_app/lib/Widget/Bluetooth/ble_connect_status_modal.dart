import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/Controller/wifi_connect_controller.dart';

class BleModalWidget extends StatefulWidget {
  final String deviceId;

  const BleModalWidget({Key? key, required this.deviceId}) : super(key: key);

  @override
  State<BleModalWidget> createState() => _BleModalWidgetState();
}

class _BleModalWidgetState extends State<BleModalWidget> {
  final WifiConnectController controller = Get.find();
  final flutterReactiveBle = FlutterReactiveBle();
  String connectionStatus = 'Waiting';

  @override
  void initState() {
    super.initState();

    flutterReactiveBle
        .connectToDevice(
      id: widget.deviceId,
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((connectionStateUpdate) {
      setState(() {
        switch (connectionStateUpdate.connectionState) {
          case DeviceConnectionState.connecting:
            connectionStatus = 'Connecting to device';
            break;
          case DeviceConnectionState.connected:
            connectionStatus = 'Connected to device';
            controller.setDeviceID(widget.deviceId);
            break;
          case DeviceConnectionState.disconnecting:
            connectionStatus = 'Disconnecting from device';
            break;
          case DeviceConnectionState.disconnected:
            connectionStatus = 'Disconnected from device';
            break;
          default:
            connectionStatus = 'Connection state unknown';
        }
      });
    }, onError: (Object error) {
      setState(() {
        connectionStatus = 'Failed to connect to device: $error';
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.amber,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(connectionStatus),
            ElevatedButton(
              child: const Text('Close BottomSheet'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
