import 'package:flutter/material.dart';
import 'package:flutter_app/pages/peripherals_prompt_side_pages/add_command.dart';
import 'package:flutter_app/pages/peripherals_prompt_side_pages/basic_commands.dart';
import 'package:flutter_app/providers/advanced_control_provider.dart';
import 'package:flutter_app/providers/peripheral_provider.dart';
import 'package:flutter_app/controllers/mqtt_controller.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class HistoryPromptPage extends StatefulWidget {
  const HistoryPromptPage({super.key});

  @override
  State<HistoryPromptPage> createState() => _HistoryPromptPageState();
}

class _HistoryPromptPageState extends State<HistoryPromptPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final MqttController mqttService = Get.put(MqttController(userProvider));
    final advancedControlProvider =
        Provider.of<AdvancedControlProvider>(context);

    Provider.of<PeripheralProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previously made Peripherals'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PeripheralList(),
            const Divider(),
            AddCommandButton(mqttService: mqttService),
            for (var control in advancedControlProvider.advancedControls)
              ElevatedButton(
                onPressed: () async {
                  await control.executeCommand(mqttService);
                },
                child: Text(control.name),
              ),
          ],
        ),
      ),
    );
  }
}

class PeripheralList extends StatelessWidget {
  const PeripheralList({super.key});

  @override
  Widget build(BuildContext context) {
    final peripheralProvider = Provider.of<PeripheralProvider>(context);
    return SizedBox(
      height: 200,
      child: peripheralProvider.peripherals.isEmpty
          ? const Center(child: Text("Add some peripherals to the list"))
          : ListView.builder(
              itemCount: peripheralProvider.peripherals.length,
              itemBuilder: (context, index) {
                final peripheral = peripheralProvider.peripherals[index];
                return ListTile(
                  title: Text(peripheral.name!),
                  subtitle: Text(
                    'Type: ${peripheral.type}, Value: ${peripheral.value}, Pin: ${peripheral.pin}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BasicCommands(
                            peripheral: peripheral,
                            index: index,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
