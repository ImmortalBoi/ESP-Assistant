import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/Controller/mqtt_controller.dart';

class MqttWidget extends StatelessWidget {
  const MqttWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mqttController = Get.put(MqttController());

    return Scaffold(
      appBar: AppBar(
          title: const Text('Received Info'),
          backgroundColor: Colors.blue,
        ),
      body: Obx(
        () => ListView.builder(
          itemCount: mqttController.messages.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(mqttController.messages[index]),
            );
          },
        ),
      ),
    );
  }
}
