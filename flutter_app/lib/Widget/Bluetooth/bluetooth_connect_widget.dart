import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Widget/Bluetooth/ble_connect_status_modal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class BluetoothConnectWidget extends StatefulWidget {
  const BluetoothConnectWidget({super.key});

  @override
  State<BluetoothConnectWidget> createState() => _BluetoothConnectWidgetState();
}

class _BluetoothConnectWidgetState extends State<BluetoothConnectWidget> {
  List<DiscoveredDevice> uniqueDevices = [];
  final flutterReactiveBle = FlutterReactiveBle();
  Stream<List<DiscoveredDevice>> devicesStream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    devicesStream = scanForDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.blueAccent))),
      child: Scaffold(
        body: StreamBuilder<List<DiscoveredDevice>>(
          stream: devicesStream,
          builder: (BuildContext context,
              AsyncSnapshot<List<DiscoveredDevice>> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(15), //apply padding to all four sides
                child: Text('Waiting for data...'),
              );
            }

            if (snapshot.hasData) {
              final devices = snapshot.data!;
              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return Padding(
                      padding: const EdgeInsets.all(15),
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          elevation: 16,
                          shadowColor: Colors.blue,
                          child: ListTile(
                              title: Text((device.name == ""
                                  ? 'No name'
                                  : device.name)),
                              subtitle: Text(device.id),
                              trailing: const Icon(Icons.bluetooth_connected),
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  builder: (context) {
                                    return BleModalWidget(deviceId: device.id);
                                  },
                                );
                              })));
                },
              );
            }

            return const Padding(
              padding: EdgeInsets.all(15),
              child: Text('No Bluetooth Around'),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            devicesStream = scanForDevices();
            setState(() {});
            uniqueDevices = [];
          },
          child: const Icon(Icons.bluetooth),
        ),
      ),
    );
  }

  Stream<List<DiscoveredDevice>> scanForDevices() async* {
    try {
bool permGranted = true;
var status = await Permission.location.status;
if (status.isDenied) {
  permGranted = false;
  if (await Permission.location.request().isGranted) {
    permGranted = true;
  }
}

if (status.isDenied) {
  permGranted = false;
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.bluetoothScan,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect
  ].request();
  if (statuses[Permission.location]!.isGranted &&
      statuses[Permission.bluetoothScan]!.isGranted &&
      statuses[Permission.bluetoothAdvertise]!.isGranted &&
      statuses[Permission.bluetoothConnect]!.isGranted) {
    permGranted = true;
  } //check each permission status after.
}


      final controller = StreamController<DiscoveredDevice>();
      final scanSubscription = flutterReactiveBle.scanForDevices(
        withServices: [],
        scanMode: ScanMode.lowPower,
        requireLocationServicesEnabled: true,
      ).listen((device) {
        controller.add(device);
      });

      Timer(const Duration(seconds: 5), () {
        scanSubscription.cancel();
        controller.close();
      });

      yield* controller.stream.asyncExpand((device) async* {
        print(device.name);
        if (!uniqueDevices.any((d) => d.id == device.id)) {
          uniqueDevices.add(device);
          yield uniqueDevices;
        }
      });
    } catch (e) {
      print('Error: $e');
      // Handle any errors
    }
  }
}
