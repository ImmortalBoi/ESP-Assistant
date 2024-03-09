import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/Model/peripheral_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // Import the http package

class ConfigController extends GetxController {
  final _formKey = GlobalKey<FormState>();
  Component selectedComponent =
      Component.led; // Initialize with a default value
  String _name = '';
  int _value = 0;
  List<String> _pin = [];
  Icon _icon = const Icon(Icons.lightbulb); // Placeholder icon

  // Getters for accessing the form key and form data
  GlobalKey<FormState> get formKey => _formKey;
  Map<String, dynamic> get configData => {
        'component': selectedComponent.toString().split('.').last,
        'name': _name,
        'value': _value,
        'pin': _pin.join(','),
        'icon': _icon
            .toString(), // Assuming you have a way to convert the icon to a string or remove it if not needed
      };

  // Methods to update form data
  void updateComponent(Component component) {
    selectedComponent = component;
    update();
  }

  void updateName(String name) {
    _name = name;
    update();
  }

  void updateValue(int value) {
    _value = value;
    update();
  }

  void updatePin(List<String> pin) {
    _pin = pin;
    update();
  }

  void updateIcon(Icon icon) {
    _icon = icon;
    update();
  }

  // Method to submit the form
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse(
              'http://192.168.196.196:8080/config'), // Replace with your actual endpoint
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(configData),
        );

        if (response.statusCode == 200) {
          // If the server returns a 200 OK response,
          // then parse the JSON.
          print('Response data: ${response.body}');
        } else {
          // If the server returns an unexpected response,
          // then throw an exception.
          throw Exception('Failed to send data');
        }
      } catch (e) {
        // If an error occurs, print the error message.
        print('Error: $e');
      }
    }
  }
}
