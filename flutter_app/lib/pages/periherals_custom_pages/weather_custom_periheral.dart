import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/mqtt_controller.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MyWeatherPage extends StatefulWidget {
  const MyWeatherPage({super.key});

  @override
  State<MyWeatherPage> createState() => _MyWeatherPageState();
}

class _MyWeatherPageState extends State<MyWeatherPage> {
  bool _isActiveUpdate = false;
  bool _isActiveFan = false;
  bool _isActiveLED = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final MqttController mqttService = Get.put(MqttController(userProvider));

    Future<void> publishUpdates() async {
      String payload = jsonEncode({"update": 1});
      await mqttService.publishMessage(payload);
      print('Published update: 1');
    }

    Future<void> publishFanValue(bool val) async {
      int realVal = val ? 1 : 0;
      String payload =
          jsonEncode({"pin": 5, "value": realVal, "type": "FAN_PIN"});
      await mqttService.publishMessage(payload);
      print('Published Fan Update');
    }

    Future<void> publishLEDValue(bool val) async {
      int realVal = val ? 1 : 0;
      String payload =
          jsonEncode({"pin": 19, "value": realVal, "type": "LED_PIN"});
      await mqttService.publishMessage(payload);
      print('Published LED update');
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
              title: const Text('Switch Fan Value '),
              value: _isActiveFan,
              onChanged: (bool value) {
                setState(() {
                  _isActiveFan = value;
                });
                publishFanValue(_isActiveFan);
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
                  height: 600,
                  child: ListView.builder(
                    itemCount:
                        mqttService.messages.length.clamp(0, 5), // Limit to 5
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
      ),
    );
  }
}
