import 'package:flutter/material.dart';
import 'package:flutter_app/models/advanced_control_model.dart';

class AdvancedControlProvider extends ChangeNotifier {
  final List<AdvancedControl> _advancedControls = [];

  List<AdvancedControl> get advancedControls => _advancedControls;

  void addAdvancedControl(AdvancedControl control) {
    _advancedControls.add(control);
    notifyListeners();
  }
}