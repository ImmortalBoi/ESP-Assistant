import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/controllers/mqtt_controller.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/pages/peripherals_prompt_side_pages/add_peripheral_with_prompt.dart';
import 'package:flutter_app/pages/peripherals_prompt_side_pages/list_of_history_prompt_peripheral.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class NewPeripheral extends StatelessWidget {
  const NewPeripheral({super.key});

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
              const SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: MyButton(
                  method: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PreviousPeripherals()),
                    );
                  },
                  text: 'previous peripherals',
                  color: const Color.fromARGB(255, 208, 221, 232),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                child: Text(
                  'Add new attached peripheral with a prompt..',
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
                      MaterialPageRoute(
                          builder: (context) => const AddPeripheralPage()),
                    );
                  },
                  text: 'add peripheral',
                  color: const Color.fromARGB(255, 208, 221, 232),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                child: Text(
                  'edit or control preconfigured peripheral',
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
                      MaterialPageRoute(
                          builder: (context) => const HistoryPromptPage()),
                    );
                  },
                  text: 'edit peripheral',
                  color: const Color.fromARGB(255, 208, 221, 232),
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

class PreviousPeripherals extends StatelessWidget {
  const PreviousPeripherals({super.key});

  @override
  Widget build(BuildContext context) {
    final backendProvider = Provider.of<UserProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final MqttController mqttService = Get.put(MqttController(userProvider));
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: backendProvider.configLength - 4,
          itemBuilder: (context, index) {
            return ListTile(
                title: Text('Item ${index}'),
                onTap: () => mqttService
                    .publishMessage(jsonEncode({"update": index + 3})));
          },
        ),
      ),
    );
  }
}
