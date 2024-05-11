import 'package:flutter/material.dart';
import 'package:flutter_app/models/peripheral_model.dart';

class PeripheralProvider with ChangeNotifier {
  final List<Peripheral> _peripherals = [];
  int ativeButton = 0;

  List<Peripheral> get peripherals => _peripherals;

  void addPeripheral(Peripheral peripheral) {
    _peripherals.add(peripheral);
    notifyListeners();
  }

  void setActiveButton() {
    ativeButton = ativeButton == 0 ? 1 : 0;
    notifyListeners();
  }

  void removePeripheral(int index) {
    _peripherals.removeAt(index);
    notifyListeners();
  }

  void updatePeripheralField(int index, String field, dynamic value) {
    if (field == 'pin') {
      _peripherals[index].pin = value;
    } else if (field == 'name') {
      _peripherals[index].name = value;
    } else if (field == 'type') {
      _peripherals[index].type = value;
    } else if (field == 'value') {
      _peripherals[index].value = value;
    }
    notifyListeners();
  }
}
