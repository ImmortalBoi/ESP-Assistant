import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/advanced_control_model.dart';
import 'package:flutter_app/models/peripheral_model.dart';
import 'package:flutter_app/providers/advanced_control_provider.dart';
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
  final Map<String, int> selectedPeripherals = {};

  @override
  Widget build(BuildContext context) {
    final peripheralProvider = Provider.of<PeripheralProvider>(context);
    final advancedControlProvider = Provider.of<AdvancedControlProvider>(
        context,
        listen: false); // Access the provider

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
            ...peripheralProvider.peripherals.map(
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
                            selectedPeripherals[peripheral.name!] =
                                int.parse(text);
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
                          selectedPeripherals[peripheral.name!] ?? 0;
                    } else {
                      selectedPeripherals.remove(peripheral.name!);
                    }
                  });
                },
              ),
            ),
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
              final newAdvancedControl = AdvancedControl(
                name: commandName!,
                selectedPeripherals: selectedPeripherals.entries
                    .map((entry) => Peripheral(
                          name: entry.key,
                          value: entry.value,
                          // Get other properties from the provider
                          pin: peripheralProvider.peripherals
                              .firstWhere((p) => p.name == entry.key)
                              .pin,
                          type: peripheralProvider.peripherals
                              .firstWhere((p) => p.name == entry.key)
                              .type,
                        ))
                    .toList(),
              );

              advancedControlProvider.addAdvancedControl(newAdvancedControl);
            }
            else{
              print('Error: Command name cannot be empty and at least one peripheral must be selected.');

            }
            Navigator.pop(context);
          },
          child: const Text('Create Command'),
        ),
      ],
    );
  }
}
