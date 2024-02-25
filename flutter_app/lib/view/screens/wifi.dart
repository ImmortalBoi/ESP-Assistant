import 'package:flutter/material.dart';
import 'package:flutter_app/Controller/user_controller.dart';
import 'package:flutter_app/app_colors.dart';
import 'package:flutter_app/view/components/wifi/unselected_wifi.dart';
import 'package:flutter_app/view/screens/devices.dart';
import 'package:get/get.dart';
import 'package:flutter_app/Controller/wifi_controller.dart';
import 'dart:convert';

class wifi extends StatelessWidget {
  wifi({super.key});

  @override
  Widget build(BuildContext context) {
    final WifiController wifiController = Get.put(WifiController());
    final UserController userController = Get.put(UserController());
    wifiController.requestESPWifiList();
    print("Trying to connect");

    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() => Center(
            child: SizedBox(
                width: 400,
                height: 500,
                child: Column(children: [
                  const Align(
                    alignment:
                        Alignment.centerLeft, // Aligns the child to the left
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 20.0), // Adds padding to the left
                      child: Text(
                        'Wifi Pairing',
                        style: TextStyle(
                          color: Color(0xFF2F414F),
                          fontSize: 30,
                          fontFamily: 'IBM Plex Mono',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: wifiController.receivedDataList.length,
                      itemBuilder: (context, index) {
                        dynamic wifi = wifiController.receivedDataList[index];
                        return ListTile(
                          title: Text(wifi),
                          // subtitle: Text('BSSID: ${wifi.bssid}'),
                          // trailing: Text('Signal Level: ${wifi.level}'),
                        );
                      },
                    ),
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
                              builder: (context) => const Devices()),
                        );
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 390,
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF3894A3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Connect to Wifi',
                        style: TextStyle(
                          color: Color(0xFFF1F1EF),
                          fontSize: 15,
                          fontFamily: 'IBM Plex Mono',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ])))));
  }
}
