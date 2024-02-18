class User {
  late int user_id = 0;
  late String user_password = '';
  late String user_name = '';
  late String user_email = '';

  User(this.user_password,this.user_name);

  // Convert a User instance into a map.
  Map<String, dynamic> toJson() {
    return {
      'user_password': user_password,
      'user_name': user_name,
      'user_email': user_email,
    };
  }
}
