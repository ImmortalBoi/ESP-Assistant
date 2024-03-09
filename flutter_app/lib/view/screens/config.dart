import 'package:flutter/material.dart';
import 'package:flutter_app/Controller/config_controller.dart';
import 'package:flutter_app/Model/peripheral_model.dart';
import 'package:get/get.dart';
import '../../colors/app_colors.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigController configController = Get.put(ConfigController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Configuration'),
      ),
      body: Form(
        key: configController.formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<Component>(
                value: configController.selectedComponent,
                onChanged: (Component? newValue) {
                  configController.updateComponent(newValue!);
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
                  configController.updateName(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Value'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  configController.updateValue(int.parse(value));
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Pin'),
                onChanged: (value) {
                  configController.updatePin(
                      value.split(',').map((pin) => pin.trim()).toList());
                },
              ),
              const SizedBox(
                height: 20,
              ),
              // Assuming you have a way to select an icon
              // For simplicity, I'm skipping this part
              ElevatedButton(
                onPressed: () {
                  configController.submitForm();
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
}
