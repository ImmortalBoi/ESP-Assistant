import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/peripheral_model.dart';
import 'package:flutter_app/pages/peripherals_prompt_side_pages/basic_commands.dart';
import 'package:flutter_app/providers/peripheral_controller.dart';
import 'package:flutter_app/controllers/mqtt_controller.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HistoryPromptPage extends StatefulWidget {
  const HistoryPromptPage({super.key});

  @override
  State<HistoryPromptPage> createState() => _HistoryPromptPageState();
}

class _HistoryPromptPageState extends State<HistoryPromptPage> {
  List<String> userChecked = [];

  void handleCheckboxChange(String peripheralName, bool isChecked) {
    if (isChecked) {
      userChecked.add(peripheralName);
    } else {
      userChecked.remove(peripheralName);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    MqttController mqttService = MqttController(userProvider);

    Peripheral peripheral = Peripheral();

    final peripheralProvider = Provider.of<PeripheralProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Previously made Peripherals'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                child: peripheralProvider.peripherals.isEmpty
                    ? const Text("add some peripheral to the list ")
                    : ListView.builder(
                        itemCount: peripheralProvider.peripherals.length,
                        itemBuilder: (context, index) {
                          final peripheral =
                              peripheralProvider.peripherals[index];
                          return ListTile(
                            title: Text(peripheral.name!),
                            subtitle: Text(
                              'Type: ${peripheral.type}, Value: ${peripheral.value}, Pin: ${peripheral.pin}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BasicCommands(
                                          peripheral: peripheral,
                                          index: index)),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () async {
                  String? peripheralName;
                  int? value;

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Add Command'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              onChanged: (text) {
                                peripheralName = text;
                              },
                              decoration: const InputDecoration(
                                  labelText: 'command Name'),
                            ),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                    peripheralProvider.peripherals.length,
                                itemBuilder: (context, index) {
                                  final peripheral =
                                      peripheralProvider.peripherals[index];

                                  return CheckboxListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(peripheral.name!),
                                        SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: TextField(
                                            onChanged: (text) {
                                              int value =
                                                  int.tryParse(text) ?? 0;
                                              peripheral.value = value;
                                            },
                                            decoration: const InputDecoration(
                                              labelText: 'Value',
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ],
                                    ),
                                    value:
                                        userChecked.contains(peripheral.name!),
                                    onChanged: (value) {
                                      if (value!) {
                                        userChecked.add(peripheral
                                            .name!); // Add to checked list
                                      } else {
                                        userChecked.remove(peripheral
                                            .name!); // Remove from checked list
                                      }
                                      setState(() {}); // Rebuild the list
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Text('Add Command'),
              ),
              SelectedCommandsList(
                  userChecked: userChecked,
                  peripherals: peripheralProvider.peripherals),
              ElevatedButton(
                onPressed: () async {
                  for (peripheral in peripheralProvider.peripherals) {
                    String payload =
                        jsonEncode({peripheral.type: peripheral.value});
                    await mqttService.publishMessage(payload);
                  }
                },
                child: const Text('Execute Commands'),
              ),
            ],
          ),
        ));
  }
}

class SelectedCommandsList extends StatelessWidget {
  final List<String> userChecked;
  final List<Peripheral> peripherals;

  const SelectedCommandsList(
      {super.key, required this.userChecked, required this.peripherals});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: userChecked.isEmpty
          ? const Text('No commands selected')
          : ListView.builder(
              shrinkWrap: true, // Prevent excessive scrolling
              itemCount: userChecked.length,
              itemBuilder: (context, index) {
                final peripheralName = userChecked[index];
                final peripheral =
                    peripherals.firstWhere((p) => p.name == peripheralName);
                return ListTile(
                  title: Text('${peripheral.name}: ${peripheral.value}'),
                );
              },
            ),
    );
  }
}
