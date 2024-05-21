import 'package:flutter/material.dart';
import 'package:flutter_app/Controller/mqtt_controller.dart';
import 'package:flutter_app/Model/peripheral_model.dart';

class SelectDeviceScreen extends StatefulWidget {
  const SelectDeviceScreen({Key? key}) : super(key: key);

  @override
  _SelectDeviceScreenState createState() => _SelectDeviceScreenState();
}

class _SelectDeviceScreenState extends State<SelectDeviceScreen> {
  List<Peripheral> peripherals = [];

  @override
  void initState() {
    super.initState();
    peripherals = [
      Peripheral(Component.led, 'LED 1', 0, ['GPIO1'], Icon(Icons.lightbulb),
          UnusedMqttController('led')),
      Peripheral(Component.servo, 'Servo 1', 0, ['GPIO2'],
          Icon(Icons.rotate_right), UnusedMqttController('servo')),
      Peripheral(Component.temperature, 'Temperature Sensor 1', 0, ['GPIO3'],
          Icon(Icons.thermostat), UnusedMqttController('temperature')),
      // Add more peripherals as needed
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Device'),
      ),
      body: ListView.builder(
        itemCount: peripherals.length,
        itemBuilder: (context, index) {
          final peripheral = peripherals[index];
          return ListTile(
            leading: Icon(Icons.device_unknown),
            title: Text(peripheral.name),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => _buildControlDialog(peripheral),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildControlDialog(Peripheral peripheral) {
    return AlertDialog(
      title: Text(peripheral.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (peripheral.component == Component.led)
            SwitchListTile(
              title: Text('LED'),
              value: peripheral.value == 1,
              onChanged: (value) {
                setState(() {
                  peripheral.value = value ? 1 : 0;
                  // Here, you would typically send the updated state to your backend
                  // For example:
                  // peripheral.mqttController.sendData(peripheral.toJson());
                });
              },
            ),
          if (peripheral.component == Component.servo)
            Slider(
              value: peripheral.value.toDouble(),
              min: 0,
              max: 360,
              divisions: 360,
              label: peripheral.value.toString(),
              onChanged: (double value) {
                setState(() {
                  peripheral.value = value.round();
                  // Here, you would typically send the updated state to your backend
                  // For example:
                  // peripheral.mqttController.sendData(peripheral.toJson());
                });
              },
            ),
          if (peripheral.component == Component.temperature)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Here, you would typically request the temperature reading from your backend
                    // For example:
                    // peripheral.mqttController.requestTemperature();
                  },
                  child: Text('Get Temperature'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'Temperature'),
                  // You would typically update this field with the temperature reading
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}
