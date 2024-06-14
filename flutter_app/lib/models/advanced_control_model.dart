import "dart:convert";

import "package:flutter_app/controllers/mqtt_controller.dart";
import "package:flutter_app/models/peripheral_model.dart";

class AdvancedControl {
  final String name;
  final List<Peripheral> selectedPeripherals;

  AdvancedControl({required this.name, required this.selectedPeripherals});

  void updateData(String peripheralName, int newValue) {
    final peripheral = selectedPeripherals.firstWhere(
          (p) => p.name == peripheralName,
      orElse: () => throw Exception('Peripheral not found'),
    );
    peripheral.value = newValue;
  }

  Future<void> executeCommand(MqttController mqttService) async {
    for (var peripheral in selectedPeripherals) {
      String payload = jsonEncode(peripheral.toMap());
      await mqttService.publishMessage(payload);
    }
  }
}