import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/Controller/mqtt_controller.dart';
import 'package:flutter_app/Model/peripheral_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PeripheralsController extends GetxController {
  final peripherals = <Peripheral>[].obs;

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

  Future<http.Response> sendCommand(
      List<Peripheral> peripherals, String transcript) {
    print("Sending");
    String jsonPeripherals =
        jsonEncode(peripherals.map((p) => p.toJson()).toList());
    String jsonString = jsonEncode(transcript);
    return http.post(
      Uri.parse('https://esp32-voice-assistant.onrender.com/command'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'Peripherals': jsonDecode(jsonPeripherals),
        'Transcript': jsonString,
      }),
    );
  }
}
