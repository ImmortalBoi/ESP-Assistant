import 'dart:convert';

class Peripheral {
  int? pin;
  String? name;
  String? type;
  int? value;

  Peripheral({this.pin, this.name, this.type, this.value});

  Map<String, dynamic> toMap() {
    return {
      'pin': pin,
      'name': name,
      'type': type,
      'value': value,
    };
  }

  factory Peripheral.fromMap(Map<String, dynamic> map) {
    return Peripheral(
      pin: map['pin'],
      name: map['name'],
      type: map['type'],
      value: map['value'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Peripheral.fromJson(String source) =>
      Peripheral.fromMap(json.decode(source));
}
