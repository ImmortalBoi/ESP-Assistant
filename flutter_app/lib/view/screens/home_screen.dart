import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import the package for SVG support
import 'package:flutter_app/colors/app_colors.dart';
import 'package:flutter_app/view/screens/config.dart';
import 'package:flutter_app/view/screens/select_device.dart';
import './wifi.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text("Home Page",
            style: TextStyle(
              color: Color(0xFF2F414F),
              fontSize: 20,
              fontFamily: 'IBM Plex Mono',
              fontWeight: FontWeight.w700,
            )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu), // Burger menu icon
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: AppColors.backgroundColor, // Match the body's color
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  // Update the state of the app
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  // Update the state of the app
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(45, 50, 45, 60),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // Add the custom SVG icon and rich text at the top center of the page
                    Center(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/chip.svg', // Replace with the path to your SVG file
                            width: 50.0, // Set the width of the SVG logo
                            height: 50.0, // Set the height of the SVG logo
                          ),
                          SizedBox(width: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'ESP ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    height: 0,
                                  ),
                                ),
                                TextSpan(
                                  text: 'SMARTASSISTANT',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w300,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildContainer(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WifiScreen()),
                        );
                      },
                      color: Colors.blue,
                      text: 'Select ESP32 WiFi',
                    ),
                    const SizedBox(height: 20),
                    _buildContainer(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ConfigurationScreen()),
                        );
                      },
                      color: Colors.green,
                      text: 'Apply Settings',
                    ),
                    const SizedBox(height: 20),
                    _buildContainer(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectDeviceScreen()),
                        );
                      },
                      color: Colors.red,
                      text: 'Select Device ',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Add a footer section at the end of the page
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              '© 2024 Our IoT App. All rights reserved.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(
      {required VoidCallback onTap,
      required Color color,
      required String text}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: 230,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(1.0),
          border: Border.all(color: AppColors.accentColor, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2F414F),
                    fontSize: 20,
                    fontFamily: 'IBM Plex Mono',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
