import 'package:flutter/material.dart';
import 'package:flutter_app/Controller/user_controller.dart';
import 'package:flutter_app/app_colors.dart';
import 'package:flutter_app/view/screens/sign_up.dart';
// import 'package:flutter_app/old_main.dart';
import 'package:flutter_app/view/screens/wifi.dart';
import 'package:get/get.dart';
import 'dart:convert';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  double opacity = 1;
  bool errorVisibility = false;
  String errorText = "";

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());

    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: SizedBox(
            width: 400,
            height: 500,
            child: Stack(
              children: [
                const Positioned(
                  left: 19,
                  child: Text("Sign In",
                      style: TextStyle(
                        color: Color(0xFF2F414F),
                        fontSize: 30,
                        fontFamily: 'IBM Plex Mono',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      )),
                ),
                Positioned(
                  top: 90,
                  left: 20,
                  right: 20,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    width: 390,
                    height: 50,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 2, color: Color(0xFFC7DAD4)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: TextFormField(
                      controller: userController.usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.30000001192092896),
                          fontSize: 15,
                          fontFamily: 'IBM Plex Mono',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  left: 20,
                  right: 20,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    width: 390,
                    height: 50,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 2, color: Color(0xFFC7DAD4)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: TextFormField(
                      controller: userController.passwordController,
                      decoration: InputDecoration(
                        hintText: 'password',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.30000001192092896),
                          fontSize: 15,
                          fontFamily: 'IBM Plex Mono',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                const Positioned(
                  top: 230,
                  right: 30,
                  child: Text("forget password?",
                      style: TextStyle(
                        color: Color(0xFF2F414F),
                        fontSize: 15,
                        fontFamily: 'IBM Plex Mono',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      )),
                ),
                Positioned(
                  top: 300,
                  right: 40,
                  left: 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        opacity = 0.5;
                      });
                      userController.user.update((val) {
                        val?.user_name = userController.usernameController.text;
                        val?.user_password =
                            userController.passwordController.text;
                      });
                      userController
                          .checkAuth(userController.user.value)
                          .then((value) {
                        print(value.statusCode);
                        if(value.statusCode == 401){
                          setState(() {
                            errorText = "Invalid info";
                            errorVisibility = true;
                          });
                          return;
                        }
                        Map<String, dynamic> body = jsonDecode(value.body);
                        userController.user.update((val) {
                          val?.user_id = body['user_id'];
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => wifi()),
                        );
                        return;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 390,
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF3894A3).withOpacity(opacity),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Sign in',
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
                Visibility(
                  visible: errorVisibility,
                    child: Positioned(
                  top: 350,
                  child: SizedBox(
                    width: 300,
                    height: 20,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 70,
                          top: 0,
                          child: Text(
                            errorText,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 168, 16, 16),
                              fontSize: 15,
                              fontFamily: 'IBM Plex Mono',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                Positioned(
                  top: 400,
                  child: SizedBox(
                    width: 300,
                    height: 20,
                    child: Stack(
                      children: [
                        const Positioned(
                          left: 70,
                          top: 0,
                          child: Text(
                            'Don’t have account? ',
                            style: TextStyle(
                              color: Color(0xFF2F414F),
                              fontSize: 15,
                              fontFamily: 'IBM Plex Mono',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 230,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to the sign-up screen here
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUp()),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF2F414F),
                                fontSize: 15,
                                fontFamily: 'IBM Plex Mono',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
