import 'package:flutter/material.dart';
import 'package:flutter_app/Controller/user_controller.dart';
import 'package:flutter_app/app_colors.dart';
import 'package:flutter_app/view/components/screens/sign_in.dart';
import 'package:get/get.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());

    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: Container(
            width: 400,
            height: 500,
            child: Stack(
              children: [
                const Positioned(
                  left: 19,
                  child: Text("sign in",
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
                      decoration: InputDecoration(
                        hintText: 'email or username',
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
                Positioned(
                  top: 400,
                  child: Container(
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
                                    builder: (context) => const SignIn()),
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