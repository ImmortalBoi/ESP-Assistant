class UserData {
  String name;
  String password;
  Cert mobileCert;
  Cert espCert;

  UserData({
    required this.name,
    required this.password,
    required this.mobileCert,
    required this.espCert,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        name: json["Name"],
        password: json["Password"],
        mobileCert: Cert.fromJson(json["Mobile_cert"]),
        espCert: Cert.fromJson(json["ESP_cert"]),
      );
}

class Cert {
  String thingName;
  String pubTopic;
  String subTopic;
  String id;
  String awsCertCrt;
  String awsCertPrivate;

  Cert({
    required this.thingName,
    required this.pubTopic,
    required this.subTopic,
    required this.id,
    required this.awsCertCrt,
    required this.awsCertPrivate,
  });

  factory Cert.fromJson(Map<String, dynamic> json) => Cert(
        thingName: json["Thing_name"],
        pubTopic: json["Pub_topic"],
        subTopic: json["Sub_topic"],
        id: json["ID"],
        awsCertCrt: json["AWS_CERT_CRT"],
        awsCertPrivate: json["AWS_CERT_PRIVATE"],
      );

  Map<String, dynamic> toJson() => {
        "Thing_name": thingName,
        "Pub_topic": pubTopic,
        "Sub_topic": subTopic,
        "ID": id,
        "AWS_CERT_CRT": awsCertCrt,
        "AWS_CERT_PRIVATE": awsCertPrivate,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
