import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/pages/peripherals_prompt_side_pages/add_peripheral_with_prompt.dart';
import 'package:flutter_app/pages/peripherals_prompt_side_pages/list_of_history_prompt_peripheral.dart';
import 'package:flutter_app/widgets/custom_button.dart';

class NewPeripheral extends StatelessWidget {
  NewPeripheral({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Peripherals Attached',
                  style: GoogleFonts.dosis(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: const Color(0xff1F5460)),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                child: Text(
                  'Add new attached peripheral with a prompt..',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 42, 63, 80),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: MyButton(
                  method: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddPeripheralPage()),
                    );
                  },
                  text: 'add peripheral',
                  color: Color.fromARGB(255, 208, 221, 232),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                child: Text(
                  'edit or control preconfigured peripheral',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 42, 63, 80),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: MyButton(
                  method: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistoryPromptPage()),
                    );
                  },
                  text: 'edit peripheral',
                  color: Color.fromARGB(255, 208, 221, 232),
                ),
              )
            ],
          ),

          //add perphireal gdida b prommpt

          //history of old peripherals>>>> control when pressed
        ],
      ),
    );
  }
}
