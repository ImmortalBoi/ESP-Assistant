import 'package:flutter/material.dart';
import 'package:flutter_app/view/screens/wifi.dart';
import '../components/wifi/unselected_wifi.dart';
import '../../Controller/wifi_controller.dart';
import 'package:get/get.dart';

class WiFiListItem extends StatefulWidget {
  final dynamic wifi;

  const WiFiListItem({Key? key, required this.wifi}) : super(key: key);

  @override
  _WiFiListItemState createState() => _WiFiListItemState();
}

class _WiFiListItemState extends State<WiFiListItem> {
  bool _isPressed = false;
  final WifiController wifiController = Get.put(WifiController());

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? password;
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            onChanged: (value) {
              password = value; // Store the password
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Connect'),
              onPressed: () {
                wifiController.connectESPWifi(widget.wifi, password!);
                // Here you can handle the connection logic with the entered password
                // For example, you might want to call a function that attempts to connect to the WiFi network
                print('Connecting with password: $password');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () {
        _showPasswordDialog(context);
      },
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: _isPressed ? Colors.grey.withOpacity(0.5) : Colors.transparent,
        child: ListTile(
          title: UnselectedWifi(widget.wifi),
          // Add other properties as needed
        ),
      ),
    );
  }
}
