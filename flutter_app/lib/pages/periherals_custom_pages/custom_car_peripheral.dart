import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/mqtt_controller.dart';
import 'package:get/get.dart';

class MyCar extends StatefulWidget {
  const MyCar({super.key});

  @override
  State<MyCar> createState() => _MyCarState();
}

class _MyCarState extends State<MyCar> {
  bool _isActive = false;
  final MqttController mqttService = Get.put(MqttController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SwitchListTile(
            title: const Text('Switch Version '),
            value: _isActive,
            onChanged: (bool value) {
              setState(() {
                _isActive = value;
              });
              publishUpdates();
            },
          ),
          arrowDirection(Icons.arrow_upward, () async {
            await mqttService
                .publishMessage('{"pin":27, "type":"IN_PIN", "value":0}');
            await mqttService
                .publishMessage('{"pin":26, "type":"IN_PIN", "value":1}');
            await mqttService
                .publishMessage('{"pin":25, "type":"IN_PIN", "value":1}');
            await mqttService
                .publishMessage('{"pin":33, "type":"IN_PIN", "value":0}');
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              arrowDirection(Icons.arrow_left, () {
                mqttService
                    .publishMessage('{"pin":27, "type":"IN_PIN", "value":1}');
                mqttService
                    .publishMessage('{"pin":26, "type":"IN_PIN", "value":0}');
                mqttService
                    .publishMessage('{"pin":25, "type":"IN_PIN", "value":0}');
                mqttService
                    .publishMessage('{"pin":33, "type":"IN_PIN", "value":1}');
              }),
              const SizedBox(
                width: 50,
              ),
              arrowDirection(Icons.arrow_right, () {
                mqttService
                    .publishMessage('{"pin":27, "type":"IN_PIN", "value":0}');
                mqttService
                    .publishMessage('{"pin":26, "type":"IN_PIN", "value":1}');
                mqttService
                    .publishMessage('{"pin":25, "type":"IN_PIN", "value":0}');
                mqttService
                    .publishMessage('{"pin":33, "type":"IN_PIN", "value":0}');
              }),
            ],
          ),
          arrowDirection(
            Icons.arrow_downward,
            () {
              mqttService
                  .publishMessage('{"pin":27, "type":"IN_PIN", "value":0}');
              mqttService
                  .publishMessage('{"pin":26, "type":"IN_PIN", "value":0}');
              mqttService
                  .publishMessage('{"pin":25, "type":"IN_PIN", "value":1}');
              mqttService
                  .publishMessage('{"pin":33, "type":"IN_PIN", "value":0}');
            },
          ),
          const SizedBox(
            height: 130,
          ),
          arrowDirection(Icons.stop_circle_sharp, () {
            mqttService
                .publishMessage('{"pin":27, "type":"IN_PIN", "value":0}');
            mqttService
                .publishMessage('{"pin":26, "type":"IN_PIN", "value":0}');
            mqttService
                .publishMessage('{"pin":25, "type":"IN_PIN", "value":0}');
            mqttService
                .publishMessage('{"pin":33, "type":"IN_PIN", "value":0}');
          })
        ],
      ),
    );
  }

  Widget arrowDirection(icon, method) {
    return GestureDetector(
      onTap: () async {
        method();
      },
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(
              color: const Color.fromARGB(255, 75, 79, 85), width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(child: Icon(icon)),
      ),
    );
  }

  Future<void> publishUpdates() async {
    String payload = jsonEncode({"update": 0});
    await mqttService.publishMessage(payload);
    print('Published update: 0');

    // const duration = Duration(seconds: 2);
    // await Future.delayed(duration);

    // payload = jsonEncode({"update": 1});
    // await mqttService.publishMessage( payload);
    // print('Published update: 1');
  }
}
