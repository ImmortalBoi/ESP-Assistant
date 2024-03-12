import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import 'package:flutter_app/Controller/wifi_controller.dart';
import 'package:get/get.dart';

class WifiScreen extends StatelessWidget {
  const WifiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WifiController wifiController = Get.put(WifiController());

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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                wifiController.requestESPWifiList();
              },
            ),
          ],
        ),
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          if (wifiController.isLoading.value) {
            // Show loading indicator when isLoading is true
            return const Center(
                child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ));
          } else {
            // Show the list of WiFi networks when isLoading is false
            return SingleChildScrollView(
              child: Center(
                child: Column(children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: wifiController.receivedDataList.length,
                    itemBuilder: (context, index) {
                      dynamic wifi = wifiController.receivedDataList[index];
                      return WiFiListItem(wifi: wifi);
                    },
                  ),
                ]),
              ),
            );
          }
        }));
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
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: const Icon(Icons.wifi, color: AppColors.primaryColor),
          title: Text(
            widget.wifi,
            style: const TextStyle(
              fontFamily: 'IBM Plex Mono',
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
