import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Model/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserController extends GetxController {
  final user = User('','').obs; 
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailController = TextEditingController();

  Future<http.Response> signUp(User user){
    return http.post(
      Uri.parse('https://esp32-voice-assistant.onrender.com/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
  }

  Future<http.Response> checkAuth(User user){
    return http.post(
      Uri.parse('https://esp32-voice-assistant.onrender.com/session'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
  }
}