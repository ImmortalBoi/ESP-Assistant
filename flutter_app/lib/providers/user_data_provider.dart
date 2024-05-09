import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graduation_project/models/user_data_model.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  UserData? _userData;

  UserData? get userData => _userData;
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        "http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:8080/v2/session/test/test"));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      print(data['Name']);
      _userData = UserData.fromJson(data);
      print(userData!.name);
      notifyListeners();
    } else {
      throw Exception('Failed to load data');
    }
  }
}
