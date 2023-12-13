import 'package:http/http.dart' as http;
import 'dart:convert';
import 'peripherals_controller.dart';

Future<http.Response> sendCommand(
    List<Peripheral> peripherals, String transcript) {
      print("Sending");
  String jsonPeripherals =
      jsonEncode(peripherals.map((p) => p.toJson()).toList());
  String jsonString = jsonEncode(transcript);
  return http.post(
    Uri.parse('https://esp32-voice-assistant.onrender.com/command'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'Peripherals': jsonDecode(jsonPeripherals),
      'Transcript': jsonString,
    }),
  );
}
