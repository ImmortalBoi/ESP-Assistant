import 'package:flutter/material.dart';
import 'package:graduation_project/navigation_menu.dart';
import 'package:graduation_project/pages/home_page.dart';
import 'package:graduation_project/pages/periherals_custom_pages/custom_peripherals.dart';
import 'package:graduation_project/pages/peripherals_prompt_side_pages/all_peripherals_attached.dart';
import 'package:graduation_project/pages/settings_page.dart';
import 'package:graduation_project/pages/splash_page.dart';
import 'package:graduation_project/providers/api_user_credentials.dart';
import 'package:graduation_project/providers/backend_prompt.dart';
import 'package:graduation_project/providers/peripheral_controller.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationController>(
          create: (context) => NavigationController(),
        ),
        ChangeNotifierProvider<ApiProvider>(
          create: (context) => ApiProvider(),
        ),
        ChangeNotifierProvider<PeripheralProvider>(
          create: (context) => PeripheralProvider(),
        ),
        ChangeNotifierProvider<BackendService>(
          create: (context) => BackendService(),
        )
      ],
      child: (const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiProvider>(context);
    return MaterialApp(
      routes: {
        '/splash': (context) => const SplashPage(),
        '/home': (context) => HomePage(),
        '/NewPeripheral': (context) => NewPeripheral(),
        '/CustomPeripheral': (context) => const CustomPeripheral(),
        '/settings': (context) => const Settings(),
        '/myhomepage': (context) => const MyHomePage(),
      },
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: api.checkIfLoggedIn(context),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.data == true) {
              return const MyHomePage();
            } else {
              return const SplashPage();
            }
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: NavigationMenu(),
    );
  }
}
