import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final color;
  final text;
  final method;
  final child;
  final double? width;
  final double? height;

  const MyButton(
      {super.key,
      this.color,
      this.text,
      this.method,
      this.child,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    double buttonWidth = width ?? 320;
    double buttonHeight = height ?? 60;

    return GestureDetector(
      onTap: method,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.size.width * 0.09),
        child: Material(
          borderRadius: BorderRadius.circular(100),
          elevation: 5.0,
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
            ),
            child: child ??
                Center(
                    child: Text(
                  text,
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff10405A),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
