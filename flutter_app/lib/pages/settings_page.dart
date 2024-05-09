import 'package:flutter/material.dart';
import 'package:graduation_project/providers/api_user_credentials.dart';
import 'package:graduation_project/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiProvider>(context);

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
