import 'package:flutter/material.dart';
import 'package:flutter_app/Controller/mqtt_controller.dart';
import 'package:flutter_app/Model/peripheral_model.dart';
import '../../colors/app_colors.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  _ConfigurationScreenState createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  Component _selectedComponent =
      Component.led; // Initialize with a default value
  String _name = '';
  int _value = 0;
  List<String> _pin = [];
  Icon _icon = const Icon(Icons.lightbulb); // Placeholder icon
  MqttController _mqttController =
      MqttController('led'); // Initialize MqttController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Configuration'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<Component>(
                value: _selectedComponent,
                onChanged: (Component? newValue) {
                  setState(() {
                    _selectedComponent = newValue!;
                  });
                },
                items: Component.values.map((Component component) {
                  return DropdownMenuItem<Component>(
                    value: component,
                    child: Text(component.toString().split('.').last),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Component Type'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  _name = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Value'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _value = int.parse(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Pin'),
                onChanged: (value) {
                  _pin = value.split(',').map((pin) => pin.trim()).toList();
                },
              ),
              const SizedBox(
                height: 20,
              ),
              // Assuming you have a way to select an icon
              // For simplicity, I'm skipping this part
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm();
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: AppColors.accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    final peripheral = Peripheral(
      _selectedComponent,
      _name,
      _value,
      _pin,
      _icon, // You need to handle icon selection
      _mqttController,
    );

    // Send data to backend
    _mqttController.sendData(peripheral.toJson());
  }
}
