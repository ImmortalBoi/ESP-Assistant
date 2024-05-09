import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/pages/wifi_page.dart';
import 'package:graduation_project/widgets/custom_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Welcome to ESP Smart Assistant 👋.',
            style: GoogleFonts.dosis(
                fontWeight: FontWeight.w700,
                fontSize: 30,
                color: const Color(0xff1F5460)),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
          child: Text(
            'choose one network to connect your ESP to WiFi',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color.fromARGB(255, 42, 63, 80),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: MyButton(
            method: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WifiScreen()),
              );
            },
            text: 'Connect',
            color: const Color.fromARGB(255, 208, 221, 232),
          ),
        )
      ],
    ));
  }
}
