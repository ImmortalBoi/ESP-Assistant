import 'package:flutter/material.dart';
import 'package:flutter_app/Controller/user_controller.dart';
import 'package:flutter_app/view/screens/select_device.dart';
import '../../colors/app_colors.dart';
import 'package:flutter_app/Controller/wifi_controller.dart';
import 'dart:convert';
import 'package:get/get.dart';

class wifi extends StatelessWidget {
  wifi({super.key});

  @override
  Widget build(BuildContext context) {
    final WifiController wifiController = Get.put(WifiController());
    final UserController userController = Get.put(UserController());
    wifiController.requestESPWifiList();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: const Text("Wifi Pairing",
              style: TextStyle(
                color: Color(0xFF2F414F),
                fontSize: 20,
                fontFamily: 'IBM Plex Mono',
                fontWeight: FontWeight.w700,
              )),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() => SingleChildScrollView(
              child: Center(
                child: Column(children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: wifiController.receivedDataList.length,
                    itemBuilder: (context, index) {
                      dynamic wifi = wifiController.receivedDataList[index];
                      return WiFiListItem(wifi: wifi);
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      userController.user.update((val) {
                        val?.user_name = userController.usernameController.text;
                        val?.user_password =
                            userController.passwordController.text;
                      });
                      userController
                          .checkAuth(userController.user.value)
                          .then((value) {
                        print(value.body);
                        Map<String, dynamic> body = jsonDecode(value.body);
                        userController.user.update((val) {
                          val?.user_id = body['user_id'];
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectDeviceScreen()),
                        );
                      });
                    },
                  ),
                ]),
              ),
            )));
  }
}

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
              password = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Connect'),
              onPressed: () {
                wifiController.connectESPWifi(widget.wifi, password!);
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
          title: Text(widget.wifi.ssid), // Assuming wifi has an ssid property
          // Add other properties as needed
        ),
      ),
    );
  }
}

class SelectedWifi extends StatelessWidget {
  const SelectedWifi(this.name, {super.key});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: SizedBox(
        width: 390,
        height: 50,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 360,
                height: 50,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2, color: Color(0xFFC7DAD4)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 0,
              right: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.wifi,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                      fontSize: 15,
                      fontFamily: 'IBM Plex Mono',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UnselectedWifi extends StatelessWidget {
  const UnselectedWifi(this.name, {super.key});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 1.0, bottom: 1.0),
      child: SizedBox(
        width: 390,
        height: 50,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 360,
                height: 50,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2, color: Color(0xFFC7DAD4)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 0,
              right: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.wifi,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                      fontSize: 15,
                      fontFamily: 'IBM Plex Mono',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
