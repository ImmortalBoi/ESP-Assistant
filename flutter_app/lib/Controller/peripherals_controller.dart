import 'package:get/get.dart';
import 'package:flutter_app/Controller/mqtt_controller.dart';

class PeripheralsController extends GetxController {
  final peripherals = <Peripheral>[].obs;
  final mqttMessages = Get.put(MqttController()).messages;

  @override
  void onInit() {
    super.onInit();
    ever(mqttMessages, (_) {
      var mqttCommand = mqttMessages.last.split('-');
      for (final peripheral in peripherals) {
        for (final pin in peripheral.pin) {
          if (pin == mqttCommand[0]) {
            peripheral.value = mqttCommand[1] as int;
          }
        }
      }
    });
  }

  void createPeripheral(
      Component component, String name, int value, List<String> pin) {
    peripherals.add(Peripheral(component, name, value, pin));
  }
}

enum Component { led, servo, potentiometer }

class Peripheral {
  late Component component;
  late String name;
  late int value;
  late List<String> pin;
  Peripheral(this.component, this.name, this.value, this.pin);
  Map<String, dynamic> toJson() => {
    'component': component.name, // Assuming Component class also has a toJson() method
    'name': name,
    'value': value,
    'pin': pin,
  };
}
