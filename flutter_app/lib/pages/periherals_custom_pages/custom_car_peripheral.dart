import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graduation_project/services/mqtt_service_with_aws.dart';

class MyCar extends StatefulWidget {
  const MyCar({super.key});

  @override
  State<MyCar> createState() => _MyCarState();
}

class _MyCarState extends State<MyCar> {
  bool _isActive = false;
  MqttService mqttService = MqttService();

  @override
  Widget build(BuildContext context) {
    MqttService mqttService = MqttService();
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SwitchListTile(
            title: Text('Active '),
            value: _isActive,
            onChanged: (bool value) {
              setState(() {
                _isActive = value;
              });
              publishUpdates();
            },
          ),
          arrowDirection(
              Icons.arrow_upward,
              () => mqttService.publishMessage(
                  'esp32/sub', '{"active":1, "type":"motor_forward"}')),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              arrowDirection(
                  Icons.arrow_left,
                  () => mqttService.publishMessage(
                      'esp32/sub', '{"active":1, "type":"motor_left"}')),
              const SizedBox(
                width: 50,
              ),
              arrowDirection(
                  Icons.arrow_right,
                  () => mqttService.publishMessage(
                      'esp32/sub', '{"active":1, "type":"motor_right"}')),
            ],
          ),
          arrowDirection(
            Icons.arrow_downward,
            () => mqttService.publishMessage(
                'esp32/sub', '{"active":1, "type":"motor_backward"}'),
          ),
          SizedBox(
            height: 130,
          )
        ],
      ),
    );
  }

  Widget arrowDirection(icon, method) {
    return GestureDetector(
      onLongPressStart: (details) async {
        await method();
      },
      onLongPressEnd: (details) async {
        // Assuming you have a method to stop the car, similar to the method used for moving the car
        await mqttService.publishMessage(
            'esp32/sub', '{"active":1, "type":"motor_stop"}');
      },
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(color: Color.fromARGB(255, 75, 79, 85), width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(child: Icon(icon)),
      ),
    );
  }

  Future<void> publishUpdates() async {
    String payload = jsonEncode({"update": 0});
    await mqttService.publishMessage('esp32/sub', payload);
    print('Published update: 0');

    // const duration = Duration(seconds: 2);
    // await Future.delayed(duration);

    // payload = jsonEncode({"update": 1});
    // await mqttService.publishMessage('esp32/sub', payload);
    // print('Published update: 1');
  }
}
