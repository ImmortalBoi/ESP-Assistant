import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as location;
import 'dart:async';

class ConnectConfigWidget extends StatefulWidget {
  const ConnectConfigWidget({super.key});

  @override
  State<ConnectConfigWidget> createState() => _ConnectConfigWidgetState();
}

class _ConnectConfigWidgetState extends State<ConnectConfigWidget> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Scanner'),
      ),
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
                            title: Text(
                                (device.name == "" ? 'No name' : device.name)),
                            subtitle: Text(device.id),
                            trailing: const Icon(Icons.bluetooth_connected),
                            onTap: () {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  var connectionValue = "";
                                  flutterReactiveBle.connectToDevice(
                                    id: device.id,
                                    // servicesWithCharacteristicsToDiscover: {serviceId: [char1, char2]},
                                    connectionTimeout: const Duration(seconds: 2),
                                  ).listen((connectionState) {
                                    if (connectionState.connectionState == DeviceConnectionState.connected){
                                      connectionValue = "Connected";
                                    }
                                    else{
                                      connectionValue = "Unknown";
                                    }
                                    // Handle connection state updates
                                  }, onError: (Object error) {
                                    // Handle a possible error
                                  });

                                  return Container(
                                    height: 200,
                                    color: Colors.amber,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(connectionValue),

                                          ElevatedButton(
                                            child:
                                                const Text('Close BottomSheet'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
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
    );
  }

  Stream<List<DiscoveredDevice>> scanForDevices() async* {
    try {
      final locationPermissionStatus =
          await location.Location().hasPermission();
      if (locationPermissionStatus == location.PermissionStatus.denied) {
        final permissionStatus = await location.Location().requestPermission();
        if (permissionStatus != location.PermissionStatus.granted) {
          throw Exception('Location permission not granted');
        }
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
