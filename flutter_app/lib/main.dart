import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location/location.dart' as location;
import 'dart:async';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(key: Key('home')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DiscoveredDevice> uniqueDevices = [];
  final flutterReactiveBle = FlutterReactiveBle();
  Stream<List<DiscoveredDevice>> devicesStream = Stream.empty();

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
        builder: (BuildContext context, AsyncSnapshot<List<DiscoveredDevice>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Waiting for data...');
          }

          if (snapshot.hasData) {
            final devices = snapshot.data!;
            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.id),
                  // Add any other information you want to display
                );
              },
            );
          }

          return Text('No data');
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
    final locationPermissionStatus = await location.Location().hasPermission();
    if (locationPermissionStatus == location.PermissionStatus.denied) {
      final permissionStatus = await location.Location().requestPermission();
      if (permissionStatus != location.PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }
    }

    final scanStream = flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowPower,
      requireLocationServicesEnabled: true,
    );

    final timer = Timer(Duration(seconds: 5), () {
      scanStream.cancel();
    });

    yield* scanStream.asyncExpand((device) async* {
      print(device.name);
      if (!uniqueDevices.any((d) => d.id == device.id)) {
        uniqueDevices.add(device);
        yield uniqueDevices;
      }
    }).takeUntil(timer);

  } catch (e) {
    print('Error: $e');
    // Handle any errors
  }
}






}
