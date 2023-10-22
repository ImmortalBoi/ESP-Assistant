import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/Controller/mqtt_controller.dart';

class PeripheralsController extends GetxController {
  final peripherals = <Peripheral>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  void createPeripheral(
      Component component, String name, int value, List<String> pin) {
    Icon icon;
    String topic;
    switch (component) {
      case Component.led:
        icon = const Icon(Icons.lightbulb);
        topic = "emqx/esp32/LED";
        break;
      case Component.temperature:
        icon = const Icon(Icons.thermostat);
        topic = "emqx/esp32/TEMPERATURE";
        break;
      case Component.potentiometer:
        icon = const Icon(Icons.speed);
        topic = "emqx/esp32/POTENTIOMETER";
        break;
      case Component.servo:
        icon = const Icon(Icons.model_training);
        topic = "emqx/esp32/SERVO";
        break;
      default:
        icon = const Icon(Icons.device_unknown);
        topic = "emqx/esp32/p";
    }
    var mqttController = Get.put(MqttController(topic));
    var mqttMessages = mqttController.messages;
    ever(mqttMessages, (_) {
      var mqttCommand = mqttMessages.last.split('-');
      mqttCommand.removeWhere((element) => element == '');
      for (final peripheral in peripherals) {
        for (final pin in peripheral.pin) {
          if (pin == mqttCommand[0]) {
            peripheral.value = int.parse(mqttCommand[1]);
          }
        }
      }
      peripherals.refresh(); // Add this line
    });
    peripherals
        .add(Peripheral(component, name, value, pin, icon, mqttController));
  }
}

enum Component { led, servo, potentiometer, temperature }

class Peripheral {
  late Component component;
  late String name;
  late int value;
  late List<String> pin;
  late Icon icon;
  late MqttController mqttController;
  Peripheral(this.component, this.name, this.value, this.pin, this.icon,
      this.mqttController);
  Map<String, dynamic> toJson() => {
        'component': component
            .name, // Assuming Component class also has a toJson() method
        'name': name,
        'value': value,
        'pin': pin,
      };
}
