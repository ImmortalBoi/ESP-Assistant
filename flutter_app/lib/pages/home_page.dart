import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/pages/chat_with_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/pages/wifi_page.dart';
import 'package:flutter_app/widgets/custom_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 244, 241, 241),
          child: SizedBox(
            height: 40,
            width: 40,
            child: Image.asset('assets/comment.png'),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
            );
          },
        ),
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
