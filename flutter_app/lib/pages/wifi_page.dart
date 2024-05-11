import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/controllers/wifi_controller.dart';

class WifiScreen extends StatelessWidget {
  const WifiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WifiController wifiController = Get.put(WifiController());
    wifiController.requestESPWifiList();


    return Scaffold(
        appBar: AppBar(
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
        body: Obx(() {
          if (wifiController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else {
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

  const WiFiListItem({super.key, required this.wifi});

  @override
  WiFiListItemState createState() => WiFiListItemState();
}

class WiFiListItemState extends State<WiFiListItem> {
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
        setState(() {});
      },
      onTapUp: (details) {
        setState(() {});
      },
      onTapCancel: () {
        setState(() {});
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
          leading: const Icon(
            Icons.wifi,
          ),
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
