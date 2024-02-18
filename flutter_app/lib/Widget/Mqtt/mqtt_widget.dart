import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:flutter_app/Controller/mqtt_controller.dart';
import 'package:flutter_app/Controller/microphone_controller.dart';
import 'package:flutter_app/Controller/peripherals_controller.dart';
import 'package:flutter_app/Model/peripheral_model.dart';

class MqttWidget extends StatelessWidget {
  const MqttWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final peripheralsController = Get.put(PeripheralsController());
    final micController = Get.put(FlutterSoundController());

    return Scaffold(
        appBar: AppBar(
          title: const Text('Received Info'),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    Component? _component;
                    final _nameController = TextEditingController();
                    final _valueController = TextEditingController();
                    final _pinController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Add Peripheral'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            DropdownButton<Component>(
                              value: _component,
                              hint: Text("Select a component"),
                              items:
                                  Component.values.map((Component component) {
                                return DropdownMenuItem<Component>(
                                  value: component,
                                  child: Text(
                                      component.toString().split('.').last),
                                );
                              }).toList(),
                              onChanged: (Component? newValue) {
                                _component = newValue;
                              },
                            ),
                            TextField(
                              controller: _nameController,
                              decoration:
                                  const InputDecoration(hintText: 'Name'),
                            ),
                            TextField(
                              controller: _valueController,
                              decoration:
                                  const InputDecoration(hintText: 'Value'),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: _pinController,
                              decoration:
                                  const InputDecoration(hintText: 'Pin'),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Add'),
                          onPressed: () {
                            peripheralsController.createPeripheral(
                              _component!,
                              _nameController.text,
                              int.parse(_valueController.text),
                              _pinController.text
                                  .split(',')
                                  .map((pin) => pin.trim())
                                  .toList(),
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Obx(
          () => ListView.builder(
            itemCount: peripheralsController.peripherals.length,
            itemBuilder: (context, index) {
              final peripheral =
                  peripheralsController.peripherals.toList()[index];
              return ListTile(
                // Customize the ListTile to display the peripheral's information
                title: Text(peripheral.name),
                subtitle: Text(
                    'Value: ${peripheral.value}\nPin: ${peripheral.pin.join(', ')}'),
                leading: peripheral.icon,
              );
            },
          ),
        ),
        floatingActionButton: GestureDetector(
          onLongPressStart: (details) {
            micController.startRecording('audioFile');
          },
          onLongPressEnd: (details) {
            micController.stopRecording().then((value) => peripheralsController.sendCommand(
                peripheralsController.peripherals.toList(),
                micController.transcript.value));
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Obx(
                  () => AlertDialog(
                    title: const Text('Recording Result'),
                    content: micController.transcript.value.isEmpty
                        ? const CircularProgressIndicator()
                        : Text(micController.transcript.value),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        onPressed: micController.isPlaying
                            ? micController.stopPlaying
                            : micController.startPlaying,
                        child: Text(
                            micController.isPlaying ? 'Stop Playback' : 'Play'),
                      )
                    ],
                  ),
                );
              },
            );
          },
          child: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.mic),
          ),
        ));
  }
}
