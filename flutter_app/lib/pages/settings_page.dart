import 'package:flutter/material.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Center(
        child: MyButton(
          method: () async {
            await api.logOut(context);
          },
          text: 'logout',
          color: const Color.fromARGB(255, 181, 163, 161),
        ),
      ),
    );
  }
}
