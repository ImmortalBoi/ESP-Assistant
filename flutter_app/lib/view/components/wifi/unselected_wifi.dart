import 'package:flutter/material.dart';

class UnselectedWifi extends StatelessWidget {
  const UnselectedWifi(this.name, {super.key});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 10.0, bottom: 10.0), // Adds padding to the left
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
                    Icons
                        .wifi, // Replace 'YOUR_ICON' with the actual icon you want
                    color: Colors.black.withOpacity(0.3),
                  ),
                  const SizedBox(
                      width:
                          10), // Adjust the spacing between the icon and text
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
