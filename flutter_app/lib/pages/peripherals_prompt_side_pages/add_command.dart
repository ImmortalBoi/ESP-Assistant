import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/providers/peripheral_controller.dart';
import 'package:flutter_app/controllers/mqtt_controller.dart';
import 'package:provider/provider.dart';

class AddCommandButton extends StatelessWidget {
  final MqttController mqttService;

  const AddCommandButton({super.key, required this.mqttService});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddCommandDialog(mqttService: mqttService);
          },
        );
      },
      child: const Text('Add Command'),
    );
  }
}

class AddCommandDialog extends StatefulWidget {
  final MqttController mqttService;

  const AddCommandDialog({super.key, required this.mqttService});

  @override
  State<AddCommandDialog> createState() => _AddCommandDialogState();
}

class _AddCommandDialogState extends State<AddCommandDialog> {
  String? commandName;
  final Map<String, List<int>> selectedPeripherals = {};

  @override
  Widget build(BuildContext context) {
    final peripheralProvider = Provider.of<PeripheralProvider>(context);

    return AlertDialog(
      title: const Text('Add Command'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Command Name:'),
            TextField(
              onChanged: (text) {
                commandName = text;
              },
            ),
            const SizedBox(height: 16),
            const Text('Select Peripherals and Values:'),
            ...peripheralProvider.peripherals
                .map(
                  (peripheral) => CheckboxListTile(
                    title: Row(
                      children: [
                        Text(peripheral.name!),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (text) {
                              setState(() {
                                // Split the input by comma and convert to integers
                                final values = text
                                    .split(',')
                                    .map((v) => int.tryParse(v.trim()) ?? 0)
                                    .toList();
                                selectedPeripherals[peripheral.name!] = values;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Values (comma-separated)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    value: selectedPeripherals.containsKey(peripheral.name),
                    onChanged: (value) {
                      setState(() {
                        // print(selectedPeripherals.keys);
                        if (value!) {
                          // Initialize with an empty list or the current value
                          selectedPeripherals[peripheral.name!] =
                              selectedPeripherals[peripheral.name!] ?? [];
                        } else {
                          selectedPeripherals.remove(peripheral.name!);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (commandName != null && selectedPeripherals.isNotEmpty) {
              // Here, you can access the selected peripherals and their values:
              for (var entry in selectedPeripherals.entries) {
                String peripheralName = entry.key;
                List<int> values = entry.value;

                // Access the peripheral from the provider
                final peripheral = peripheralProvider.peripherals
                    .firstWhere((p) => p.name == peripheralName);

                // Process the list of values (e.g., send each value as a separate MQTT message)
                for (int value in values) {
                  peripheral.value = value; // Update the peripheral's value
                  String payload = jsonEncode({peripheral.type: value});
                  await widget.mqttService.publishMessage(payload);
                }
              }
            }
            Navigator.pop(context);
          },
          child: const Text('Execute'),
        ),
      ],
    );
  }
}
