import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/peripheral_model.dart';
import 'package:flutter_app/providers/peripheral_provider.dart';
import 'package:flutter_app/controllers/mqtt_controller.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class BasicCommands extends StatefulWidget {
  final Peripheral? peripheral;
  final int? index;

  const BasicCommands({super.key, this.peripheral, this.index});

  @override
  State<BasicCommands> createState() => _BasicCommandsState();
}

class _BasicCommandsState extends State<BasicCommands> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    MqttController mqttService = MqttController(userProvider);
    bool isActive = false;

    void publishActiveState() async {
      String payload = jsonEncode({"active": isActive ? 1 : 0});
      await mqttService.publishMessage(payload);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          SwitchListTile(
            title: const Text('Active'),
            value: isActive,
            onChanged: (bool value) {
              setState(() {
                isActive = value;
              });
              publishActiveState();
            },
          ),
          TextFormField(
            initialValue: widget.peripheral!.pin.toString(),
            decoration: const InputDecoration(labelText: 'Pin'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              Provider.of<PeripheralProvider>(context, listen: false)
                  .updatePeripheralField(
                      widget.index!, 'pin', int.tryParse(value) ?? 0);
            },
          ),
          TextFormField(
            initialValue: widget.peripheral!.value.toString(),
            decoration: const InputDecoration(labelText: 'Value'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              Provider.of<PeripheralProvider>(context, listen: false)
                  .updatePeripheralField(
                      widget.index!, 'value', int.tryParse(value) ?? 0);
            },
          ),
          ElevatedButton(
            onPressed: () async {
              String peripheralDataJson =
                  serializePeripheralDataToJson(widget.peripheral!);

              await mqttService.publishMessage(peripheralDataJson);
            },
            child: const Text('Update Peripheral'),
          ),
        ]),
      ),
    );
  }

  String serializePeripheralDataToJson(Peripheral peripheral) {
    Map<String, dynamic> peripheralMap = peripheral.toMap();

    String peripheralJson = jsonEncode(peripheralMap);

    return peripheralJson;
  }
}
