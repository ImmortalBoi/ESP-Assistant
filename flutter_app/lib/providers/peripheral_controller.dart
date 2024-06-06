import 'package:flutter/material.dart';
import 'package:flutter_app/models/peripheral_model.dart';

class PeripheralProvider extends ChangeNotifier {
  final List<Peripheral> _peripherals = [];
  int activeButton = 0;

  List<Peripheral> get peripherals => _peripherals;

  void addPeripheral(Peripheral peripheral) {
    _peripherals.add(peripheral);
    notifyListeners();
  }

  void setActiveButton() {
    activeButton = activeButton == 0 ? 1 : 0;
    notifyListeners();
  }

  void removePeripheral(int index) {
    _peripherals.removeAt(index);
    notifyListeners();
  }

void updatePeripheralField(int index, String field, dynamic value) {
  print("updated");
  if (field == 'pin') {
    _peripherals[index].pin = int.tryParse(value) ?? _peripherals[index].pin; // Keep old value if parsing fails
  } else if (field == 'name') {
    _peripherals[index].name = value; // Directly assign string value
  } else if (field == 'type') {
    _peripherals[index].type = value; // Directly assign string value
  } else if (field == 'value') {
    _peripherals[index].value = int.tryParse(value) ?? _peripherals[index].value; // Keep old value if parsing fails
  }
  notifyListeners();
}
}
