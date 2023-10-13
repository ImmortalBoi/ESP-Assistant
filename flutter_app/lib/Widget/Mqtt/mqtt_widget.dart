import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/Controller/mqtt_controller.dart';
import 'package:flutter_app/Controller/microphone_controller.dart';

class MqttWidget extends StatelessWidget {
  const MqttWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mqttController = Get.put(MqttController());
    final micController = Get.put(FlutterSoundController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Info'),
        backgroundColor: Colors.blue,
      ),
      body: Column(children: [
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemCount: mqttController.messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(mqttController.messages[index]),
                );
              },
            ),
          ),
        ),
        Obx(() => Text(micController.transcript.value))
        ,
        Obx(() => ElevatedButton(
              onPressed: micController.isRecording
                  ? micController.stopRecording
                  : () => micController.startRecording('audioFile'),
              child: Text(micController.isRecording ? 'Stop' : 'Record'),
            )),
        Obx(() => ElevatedButton(
              onPressed: micController.isPlaying
                  ? micController.stopPlaying
                  : micController.startPlaying,
              child: Text(micController.isPlaying ? 'Stop Playback' : 'Play'),
            )),
      ]),
    );
  }
}
