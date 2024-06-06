import 'package:flutter/material.dart';
import 'package:flutter_app/models/peripheral_model.dart';
import 'package:flutter_app/providers/peripheral_controller.dart';
import 'package:flutter_app/widgets/custom_text_field.dart';

class PeripheralWidget extends StatelessWidget {
  final PeripheralProvider peripheralProvider;
  final Peripheral peripheral;
  final VoidCallback onRemove;
  final int index;

  const PeripheralWidget({
    super.key,
    required this.peripheral,
    required this.onRemove,
    required this.index,
    required this.peripheralProvider
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(38.0),
      child: Card(
        color: Colors.grey[50],
        child: Column(
          children: [
            const SizedBox(
              height: 12,
            ),
            CustomTextField(
              hintText: 'Pin Number',
              obscureText: false,
              keyboardType: TextInputType.number,
              method: (value) {
                peripheralProvider
                    .updatePeripheralField(index, 'pin', value);
              },
            ),
            const SizedBox(
              height: 3,
            ),
            CustomTextField(
              hintText: 'Peripheral Name',
              obscureText: false,
              keyboardType: TextInputType.number,
              method: (value) {
                peripheralProvider
                    .updatePeripheralField(index, 'name', value);
              },
            ),
            const SizedBox(
              height: 3,
            ),
            CustomTextField(
              hintText: 'Perihpheral Type',
              obscureText: false,
              keyboardType: TextInputType.number,
              method: (value) {
                peripheralProvider
                    .updatePeripheralField(index, 'type', value);
              },
            ),
            const SizedBox(
              height: 3,
            ),
            CustomTextField(
              initialValue: peripheral.value.toString(),
              hintText: 'value',
              obscureText: false,
              keyboardType: TextInputType.number,
              method: (value) {
                peripheralProvider
                    .updatePeripheralField(index, 'value', value);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
