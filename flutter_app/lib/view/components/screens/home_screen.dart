import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomeScreen(),
    );
  }
}

class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      drawer: Drawer(
        child: ListTile(
          title: const Text('Drawer Item'),
          onTap: () {
            // Handle drawer item tap
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/add.svg', // Replace with the path to your SVG icon
                  width: 160,
                  height: 160,
                ),
                const SizedBox(height: 30),
                Container(
                  width: 279,
                  height: 60,
                  padding: const EdgeInsets.all(10),
                  decoration: ShapeDecoration(
                    color: Color(0xFFC7DAD4),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignOutside,
                        color: Color(0xFF3894A3),
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 259,
                        child: Opacity(
                          opacity: 0.80,
                          child: Text(
                            'connect device',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF2F414F),
                              fontSize: 20,
                              fontFamily: 'IBM Plex Mono',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              shape: const CircularNotchedRectangle(),
              child: Container(
                width: 460,
                height: 130,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Color(0xFF3894A3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              top: 680,
              right: 175,
              left: 175,
              child: Container(
                width: 80,
                height: 63,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Color(0xFFF1F1EF),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: Color(0xFFC7DAD4)),
                    borderRadius: BorderRadius.circular(140),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/icons/mic.svg', // Replace with the path to your SVG icon
                  width: 30,
                  height: 30,
                ),
              )),
        ],
      ),
    );
  }
}
