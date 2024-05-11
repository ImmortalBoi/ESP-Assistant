import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/services/mqtt_service_with_aws.dart';

class MyWeatherPage extends StatefulWidget {
  const MyWeatherPage({super.key});

  @override
  State<MyWeatherPage> createState() => _MyWeatherPageState();
}

class _MyWeatherPageState extends State<MyWeatherPage> {
  bool _isActive = false;
  MqttService mqttService = MqttService();

  @override
  Widget build(BuildContext context) {
    MqttService mqttService = MqttService();

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 70,
          ),
          SwitchListTile(
            title: Text('update '),
            value: _isActive,
            onChanged: (bool value) {
              setState(() {
                _isActive = value;
              });
              publishUpdates();
            },
          ),
          ElevatedButton(
              onPressed: () =>
                  mqttService.publishMessage('esp32/sub', '{"active":1}'),
              child: Text("activ1")),
          // Center(
          //   child: Text(mqttService.messages.last),
          // ),
        ],
      ),
    );
  }

  Future<void> publishUpdates() async {
    String payload = jsonEncode({"update": 1});
    await mqttService.publishMessage('esp32/sub', payload);
    print('Published update: 1');

    const duration = Duration(seconds: 2);
    await Future.delayed(duration);

    // payload = jsonEncode({"update": 2});
    // await mqttService.publishMessage('esp32/sub', payload);
    print('Published update: 2');
  }
}
