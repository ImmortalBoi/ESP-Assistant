import 'package:flutter/material.dart';
import 'package:flutter_app/Widget/Wifi/wifi_connect_widget.dart';

class BluetoothWifiWrapperWidget extends StatelessWidget {
  const BluetoothWifiWrapperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ESP Pair'),
          backgroundColor: Colors.blue,
        ),
        body: const WrapperWidget(),
      ),
    );
  }
}

class WrapperWidget extends StatelessWidget {
  const WrapperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: WifiConnectWidget()),
      ],
    );
  }
}
