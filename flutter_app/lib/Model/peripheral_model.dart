import 'package:flutter_app/Controller/mqtt_controller.dart';
import 'package:flutter/material.dart';

enum Component { led, servo, potentiometer, temperature }

class Peripheral {
  late Component component;
  late String name;
  late int value;
  late List<String> pin;
  late Icon icon;
  late UnusedMqttController mqttController;
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
