import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/mqtt_controller.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MyTankPage extends StatefulWidget {
  const MyTankPage({super.key});

  @override
  State<MyTankPage> createState() => _MyTankPageState();
}

class _MyTankPageState extends State<MyTankPage> {
  bool _isActiveUpdate = false;
  bool _isActivePump = false;
  int _isActive = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final MqttController mqttService = Get.put(MqttController(userProvider));

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

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 70,
          ),
          SwitchListTile(
            title: const Text('Update '),
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
          ElevatedButton(
              onPressed: () {
                mqttService.publishMessage('{"active": $_isActive}');
                if (_isActive == 0) {
                  _isActive = 1;
                } else {
                  _isActive = 0;
                }
              },
              child: const Text("active")),
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
}
