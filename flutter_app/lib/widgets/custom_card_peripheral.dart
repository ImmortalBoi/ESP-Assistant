import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCard extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback method;
  const CustomCard(
      {super.key,
      required this.text,
      required this.imagePath,
      required this.method});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: method,
      child: Material(
        borderRadius: BorderRadius.circular(30),
        elevation: 5,
        child: Container(
          height: 120,
          width: 335,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 58, 57, 57).withAlpha(20),
                blurRadius: 100,
              ),
            ],
            border:
                Border.all(width: 3, color: const Color.fromARGB(179, 150, 144, 144)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.oswald(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: const Color.fromARGB(255, 79, 76, 99)),
                ),
                const SizedBox(width: 30),
                Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SizedBox(
                        height: 80, width: 55, child: Image.asset(imagePath)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
