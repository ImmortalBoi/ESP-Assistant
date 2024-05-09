import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider extends ChangeNotifier {
  late SharedPreferences prefs;
  setStringShared(String name, String password) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("name", name);
    prefs.setString("password", password);
  }

/////////////for signing up
  Future<dynamic> createNewUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    final String apiUrl =
        'http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:8080/v2/user';
    final Map<String, String> body = {"Name": email, "Password": password};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print("created user");
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error $e');
    }
  }

//////////for signing in
  Future<dynamic> checkUserExists(
      BuildContext context, String email, String password) async {
    final String apiUrl =
        "http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:8080/v2/session/$email/$password";

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    try {
      if (response.statusCode == 200) {
        print("user exists");
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacementNamed(context, '/myhomepage');
      } else {
        print('user not found');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Account Not Found'),
              content:
                  Text('The account does not exist. Please sign up first.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("$e");
    }
  }

  Future<void> logOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    Navigator.pushReplacementNamed(
      context,
      '/splash',
    );
  }

  Future<bool> checkIfLoggedIn(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<dynamic> returnAwsCert(
      BuildContext context, String email, String password) async {
    final String apiUrl =
        "http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:8080/v2/session/$email/$password";

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      try {
        final jsonData = response.body; // Get the response body (JSON string)
        final espCert = jsonDecode(jsonData)["Mobile_cert"]
            ["AWS_CERT_CRT"]; // Decode the JSON
        print(espCert);
      } on FormatException catch (e) {
        print('Error decoding JSON: $e'); // Handle decoding error
      }
    } else {
      print('Error: ${response.statusCode}'); // Print error status code
    }
  }

///////
  Future<dynamic> returnThing(
      BuildContext context, String email, String password) async {
    final String apiUrl =
        "http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:8080/v2/session/$email/$password";

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      try {
        final jsonData = response.body; // Get the response body (JSON string)
        final espCert = jsonDecode(jsonData)["Thing_name"]; // Decode the JSON
        print(espCert);
      } on FormatException catch (e) {
        print('Error decoding JSON: $e'); // Handle decoding error
      }
    } else {
      print('Error: ${response.statusCode}'); // Print error status code
    }
  }

////////////

  Future<String?> returnSub(
      BuildContext context, String email, String password) async {
    final String apiUrl =
        "http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:8080/v2/session/$email/$password";

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      try {
        final jsonData = response.body; // Get the response body (JSON string)
        final sub =
            jsonDecode(jsonData)["Mobile_cert"]["Sub_topic"]; // Decode the JSON
        return sub;
      } on FormatException catch (e) {
        print('Error decoding JSON: $e'); // Handle decoding error
      }
    } else {
      print('Error: ${response.statusCode}'); // Print error status code
    }
  }
}
