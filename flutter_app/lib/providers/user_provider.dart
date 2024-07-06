import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/user_data_model.dart';
import 'package:flutter_app/providers/peripheral_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  PeripheralProvider peripheralProvider; // Declare a private reference
  dynamic configLength; //

  // Constructor
  UserProvider(this.peripheralProvider); // Inject PeripheralProvider
  late SharedPreferences prefs;

  Future<void> setUser(UserData user) async {
    prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    prefs.setString("user", userJson);
  }

  Future<UserData?> getUser() async {
    prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString("user");
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserData.fromJson(userMap);
    }
    return null;
  }

  Future<void> removeUser() async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
  }

  Future<void> createNewUser(
      BuildContext context, String email, String password) async {
    const String apiUrl =
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
        // Assuming we get the full user data including certs from the response
        Map<String, dynamic> responseData = jsonDecode(response.body);
        responseData["isLoggedIn"] = true;
        UserData user = UserData.fromJson(responseData);
        await setUser(user);
        peripheralProvider = responseData["Config_gen"].last()["Peripherals"];
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error $e');
    }
  }

  Future<void> checkUserExists(
      BuildContext context, String email, String password) async {
    final String apiUrl =
        "http://ec2-3-147-6-28.us-east-2.compute.amazonaws.com:8080/v2/session/$email/$password";
    print(apiUrl);

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    try {
      if (response.statusCode == 200) {
        print("user exists");
        Map<String, dynamic> responseData = jsonDecode(response.body);
        responseData["isLoggedIn"] = true;
        UserData user = UserData.fromJson(responseData);
        await setUser(user);
        print("user exists");

        if (responseData["Config_gen"] != null &&
            responseData["Config_gen"].isNotEmpty) {
          var lastConfig = responseData["Config_gen"].last;
          if (lastConfig != null && lastConfig["Peripherals"] != null) {
            var peripherals = lastConfig["Peripherals"] as List<dynamic>?;
            peripheralProvider.setPeripherals(peripherals);
          }
        }
        configLength = responseData["Config_gen"].length;

        Navigator.pushReplacementNamed(context, '/myhomepage');
      } else {
        print('user not found');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Account Not Found'),
              content: const Text(
                  'The account does not exist. Please sign up first.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
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
      print("Error: $e");
    }
  }

  Future<void> logOut(BuildContext context) async {
    await removeUser();
    Navigator.pushReplacementNamed(
      context,
      '/splash',
    );
  }

  Future<bool> checkIfLoggedIn(BuildContext context) async {
    UserData? user = await getUser();
    return user != null;
  }
}
