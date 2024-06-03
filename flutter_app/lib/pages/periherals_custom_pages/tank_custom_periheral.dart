import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/mqtt_controller.dart';
import 'package:get/get.dart';

class MyTankPage extends StatefulWidget {
  const MyTankPage({super.key});

  @override
  State<MyTankPage> createState() => _MyTankPageState();
}

class _MyTankPageState extends State<MyTankPage> {
  bool _isActiveUpdate = false;
  bool _isActivePump = false;
  bool _isActiveLED = false;

  final MqttController mqttService = Get.put(MqttController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 70,
          ),
          SwitchListTile(
            title: Text('Update '),
            value: _isActiveUpdate,
            onChanged: (bool value) {
              setState(() {
                _isActiveUpdate = value;
              });
              publishUpdates();
            },
          ),
          SwitchListTile(
            title: const Text('Switch Pump Value '),
            value: _isActivePump,
            onChanged: (bool value) {
              setState(() {
                _isActivePump = value;
              });
              publishPumpValue(_isActivePump);
            },
          ),
          SwitchListTile(
            title: const Text('Switch LED Value'),
            value: _isActiveLED,
            onChanged: (bool value) {
              setState(() {
                _isActiveLED = value;
              });
              publishLEDValue(_isActiveLED);
            },
          ),
          ElevatedButton(
              onPressed: () => mqttService.publishMessage('{"active": 1}'),
              child: Text("active")),
          Obx(() => SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount:
                      mqttService.messages.length.clamp(0, 5), // Limit to 5
                  reverse: true, // Show the newest message first
                  itemBuilder: (context, index) {
                    return Text(mqttService.messages[index]);
                  },
                ),
              )),
          // Center(
          //   child: Text(mqttService.messages.last),
          // ),
        ],
      ),
    );
  }

  Future<void> publishUpdates() async {
    String payload = jsonEncode({"update": 2});
    await mqttService.publishMessage(payload);
    print('Published update: 1');
  }

  Future<void> publishPumpValue(bool val) async {
    int realVal = val ? 1 : 0;
    String payload =
        jsonEncode({"pin": 14, "value": realVal, "type": "PUMP_PIN"});
    await mqttService.publishMessage(payload);
    print('Published Pump Update');
  }

  Future<void> publishLEDValue(bool val) async {
    int realVal = val ? 1 : 0;
    String payload =
        jsonEncode({"pin": 19, "value": realVal, "type": "LED_PIN"});
    await mqttService.publishMessage(payload);
    print('Published LED update');
  }
}
