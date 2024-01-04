import 'package:flutter/material.dart';
import 'package:flutter_app/Controller/user_controller.dart';
import 'package:flutter_app/app_colors.dart';
import 'package:flutter_app/old_main.dart';
import 'package:get/get.dart';
import 'dart:convert';

class wifi extends StatelessWidget {
  const wifi({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());

    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
            child: Container(
                width: 400,
                height: 500,
                child: Stack(children: [
                  const Positioned(
                    left: 19,
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
                  Positioned(
                      top: 90,
                      left: 20,
                      right: 20,
                      child: Container(
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
                                    side: const BorderSide(
                                        width: 2, color: Color(0xFFC7DAD4)),
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
                                    Icons
                                        .wifi, // Replace 'YOUR_ICON' with the actual icon you want
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Adjust the spacing between the icon and text
                                  Text(
                                    'No Wifi',
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
                      )),
                  Positioned(
                      top: 150,
                      left: 20,
                      right: 20,
                      child: Container(
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
                                    side: const BorderSide(
                                        width: 2, color: Color(0xFFC7DAD4)),
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
                                    Icons
                                        .wifi, // Replace 'YOUR_ICON' with the actual icon you want
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Adjust the spacing between the icon and text
                                  Text(
                                    ' Wifi-name',
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
                      )),
                  Positioned(
                      top: 210,
                      left: 20,
                      right: 20,
                      child: Container(
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
                                    side: const BorderSide(
                                        width: 2, color: Color(0xFFC7DAD4)),
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
                                    Icons
                                        .wifi, // Replace 'YOUR_ICON' with the actual icon you want
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Adjust the spacing between the icon and text
                                  Text(
                                    'selected wifi',
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
                      )),
                  Positioned(
                    top: 300,
                    right: 40,
                    left: 40,
                    child: GestureDetector(
                      onTap: () {
                        userController.user.update((val) {
                          val?.user_name =
                              userController.usernameController.text;
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
                                builder: (context) => const OldMain()),
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
                  ),
                ]))));
  }
}
