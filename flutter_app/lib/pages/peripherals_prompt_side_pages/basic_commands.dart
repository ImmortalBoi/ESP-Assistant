import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/peripheral_model.dart';
import 'package:flutter_app/providers/peripheral_controller.dart';
import 'package:flutter_app/services/mqtt_service_with_aws.dart';
import 'package:provider/provider.dart';

class BasicCommands extends StatefulWidget {
  final Peripheral? peripheral;
  final int? index;

  const BasicCommands({super.key, this.peripheral, this.index});

  @override
  State<BasicCommands> createState() => _BasicCommandsState();
}

class _BasicCommandsState extends State<BasicCommands> {
  MqttService mqttService = MqttService();
  bool _isActive = false;

  void _publishActiveState() async {
    String payload = jsonEncode({"active": _isActive ? 1 : 0});
    await mqttService.publishMessage('esp32/sub', payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          SwitchListTile(
            title: Text('Active'),
            value: _isActive,
            onChanged: (bool value) {
              setState(() {
                _isActive = value;
              });
              _publishActiveState();
            },
          ),
          TextFormField(
            initialValue: widget.peripheral!.pin.toString(),
            decoration: InputDecoration(labelText: 'Pin'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              Provider.of<PeripheralProvider>(context, listen: false)
                  .updatePeripheralField(
                      widget.index!, 'pin', int.tryParse(value) ?? 0);
            },
          ),
          TextFormField(
            initialValue: widget.peripheral!.value.toString(),
            decoration: InputDecoration(labelText: 'Value'),
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

              MqttService mqttService = MqttService();

              await mqttService.publishMessage('esp32/sub', peripheralDataJson);
            },
            child: Text('Update Peripheral'),
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
