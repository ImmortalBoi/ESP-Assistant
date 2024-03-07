import 'package:flutter/material.dart';
import 'package:flutter_app/Controller/user_controller.dart';
import '../../colors/app_colors.dart';
import 'package:flutter_app/view/screens/sign_up.dart';
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Sign In",
                    style: TextStyle(
                      color: Color(0xFF2F414F),
                      fontSize: 30,
                      fontFamily: 'IBM Plex Mono',
                      fontWeight: FontWeight.w700,
                    )),
                SizedBox(height: 30), // Spacing
                Container(
                  alignment: AlignmentDirectional.center,
                  width: 390,
                  height: 50,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 2, color: Color(0xFFC7DAD4)),
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
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: 20), // Spacing
                Container(
                  alignment: AlignmentDirectional.center,
                  width: 390,
                  height: 50,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 2, color: Color(0xFFC7DAD4)),
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
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: 20), // Spacing
                const Text("forget password?",
                    style: TextStyle(
                      color: Color(0xFF2F414F),
                      fontSize: 15,
                      fontFamily: 'IBM Plex Mono',
                      fontWeight: FontWeight.w700,
                    )),
                SizedBox(height: 20), // Spacing
                GestureDetector(
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
                      if (value.statusCode == 401) {
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
                        MaterialPageRoute(builder: (context) => WifiScreen()),
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
                      ),
                    ),
                  ),
                ),
                if (errorVisibility)
                  Text(
                    errorText,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 168, 16, 16),
                      fontSize: 15,
                      fontFamily: 'IBM Plex Mono',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                SizedBox(height: 20), // Spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don’t have account? ',
                      style: TextStyle(
                        color: Color(0xFF2F414F),
                        fontSize: 15,
                        fontFamily: 'IBM Plex Mono',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
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
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
