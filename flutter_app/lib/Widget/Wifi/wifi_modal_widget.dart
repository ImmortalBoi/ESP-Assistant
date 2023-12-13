import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/Controller/wifi_connect_controller.dart';

class WifiConnectModalWidget extends StatelessWidget {
  const WifiConnectModalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final WifiConnectController controller = Get.put(WifiConnectController());

    return 
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: controller.textController,
              decoration: const InputDecoration(
                labelText: 'Enter Password',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.writeCharacteristic(controller.textController.text);
              },
              child: const Text('Write to Characteristic'),
            ),
          ],
        ),
      );
  }
}
