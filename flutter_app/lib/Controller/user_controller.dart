import 'package:get/get.dart';
import 'package:flutter_app/Model/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserController extends GetxController {
  final user = User('','').obs; 

  Future<http.Response> checkAuth(User user){
    return http.post(
      Uri.parse('https://esp32-voice-assistant.onrender.com/command'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user),
    );
  }
}