import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graduation_project/models/peripheral_model.dart';
import 'package:graduation_project/pages/peripherals_prompt_side_pages/basic_and_advanced_commands.dart';
import 'package:graduation_project/providers/peripheral_controller.dart';
import 'package:graduation_project/services/mqtt_service_with_aws.dart';
import 'package:provider/provider.dart';

class HistoryPromptPage extends StatefulWidget {
  const HistoryPromptPage({super.key});

  @override
  State<HistoryPromptPage> createState() => _HistoryPromptPageState();
}

class _HistoryPromptPageState extends State<HistoryPromptPage> {
  MqttService mqttService = MqttService();
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
                    ? Text("add some peripheral to the list ")
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
                              icon: Icon(Icons.edit),
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
                        title: Text('Add Command'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              onChanged: (text) {
                                peripheralName = text;
                              },
                              decoration:
                                  InputDecoration(labelText: 'command Name'),
                            ),
                            Container(
                              height: 150,
                              child: ListView.builder(
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
                child: Text('Add Command'),
              ),
              SelectedCommandsList(
                  userChecked: userChecked,
                  peripherals: peripheralProvider.peripherals),
              ElevatedButton(
                onPressed: () async {
                  for (peripheral in peripheralProvider.peripherals) {
                    String payload =
                        jsonEncode({peripheral.type: peripheral.value});
                    await mqttService.publishMessage('esp32/sub', payload);
                  }
                },
                child: Text('Execute Commands'),
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
      {required this.userChecked, required this.peripherals});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: userChecked.isEmpty
          ? Text('No commands selected')
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
