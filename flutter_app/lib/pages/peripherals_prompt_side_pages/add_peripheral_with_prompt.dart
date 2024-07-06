import 'package:flutter_app/models/peripheral_model.dart';
import 'package:flutter_app/pages/peripherals_prompt_side_pages/list_of_history_prompt_peripheral.dart';
import 'package:flutter_app/providers/backend_prompt.dart';
import 'package:flutter_app/providers/peripheral_provider.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/custom_text_field.dart';
import 'package:flutter_app/widgets/peripheral_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPeripheralPage extends StatefulWidget {
  const AddPeripheralPage({super.key});

  @override
  State<AddPeripheralPage> createState() => _AddPeripheralPageState();
}

class _AddPeripheralPageState extends State<AddPeripheralPage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController requestController = TextEditingController();
    final TextEditingController resultController = TextEditingController();
    final TextEditingController resultDataTypeController =
        TextEditingController();
    final periheralProvider = Provider.of<PeripheralProvider>(context);
    final backendProvider = Provider.of<BackendService>(context);
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ...periheralProvider.peripherals.asMap().entries.map((entry) {
            int index = entry.key;
            Peripheral peripheral = entry.value;
            return PeripheralWidget(
              peripheral: peripheral,
              onRemove: () => periheralProvider.removePeripheral(index),
              index: index,
              peripheralProvider: periheralProvider,
            );
          }),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: MyButton(
              color: const Color.fromARGB(31, 21, 73, 95),
              text: 'add peripheral',
              method: () => periheralProvider.addPeripheral(
                Peripheral(pin: 0, name: '', type: '', value: 0),
              ),
              height: 40,
              width: 40,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CustomTextField(
            hintText: 'enter prompt',
            method: (value) => {requestController.text = value},
            obscureText: false,
            controller: requestController,
          ),
          const SizedBox(
            height: 5,
          ),
          CustomTextField(
            hintText: 'enter result',
            obscureText: false,
            method: (value) => {resultController.text = value},
            controller: resultController,
          ),
          const SizedBox(
            height: 5,
          ),
          CustomTextField(
            hintText: 'enter result data type',
            obscureText: false,
            method: (value) => {resultDataTypeController.text = value},
            controller: resultDataTypeController,
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: MyButton(
              method: () async {
                String request = requestController.text;
                String result = resultController.text;
                String resultDataType = resultDataTypeController.text;
                print(result);

                await backendProvider.sendPeripheralData(
                    periheralProvider.peripherals,
                    request,
                    result,
                    resultDataType);

                requestController.clear();
                resultController.clear();
                resultDataTypeController.clear();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryPromptPage()),
                );
              },
              text: 'Submit',
            ),
          )
        ],
      ),
    );
  }
}
