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
    Uri.parse('http://192.168.1.7:5000/command'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'Peripherals': jsonDecode(jsonPeripherals),
      'Transcript': jsonString,
    }),
  );
}
