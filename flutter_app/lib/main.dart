import 'package:flutter/material.dart';
import 'package:flutter_app/navigation_menu.dart';
import 'package:flutter_app/pages/home_page.dart';
import 'package:flutter_app/pages/periherals_custom_pages/custom_peripherals.dart';
import 'package:flutter_app/pages/peripherals_prompt_side_pages/all_peripherals_attached.dart';
import 'package:flutter_app/pages/settings_page.dart';
import 'package:flutter_app/pages/splash_page.dart';
import 'package:flutter_app/providers/advanced_control_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/providers/backend_prompt.dart';
import 'package:flutter_app/providers/peripheral_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NavigationController(),
        ),
        ChangeNotifierProvider(
          create: (context) => PeripheralProvider(),
        ),
        ChangeNotifierProxyProvider<PeripheralProvider, UserProvider>(
          create: (context) => UserProvider(
              Provider.of<PeripheralProvider>(context, listen: false)),
          update: (context, peripheralProvider, userProvider) {
            if (userProvider == null) {
              return UserProvider(peripheralProvider);
            }
            userProvider.peripheralProvider = peripheralProvider;
            return userProvider;
          },
        ),
        ChangeNotifierProxyProvider<UserProvider, BackendService>(
          create: (context) =>
              BackendService(Provider.of<UserProvider>(context, listen: false)),
          update: (context, userProvider, backendService) {
            if (backendService == null) {
              return BackendService(userProvider);
            }
            backendService.userProvider = userProvider;
            return backendService;
          },
        ),
        ChangeNotifierProvider(create: (_) => AdvancedControlProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<UserProvider>(context);
    return MaterialApp(
      routes: {
        '/splash': (context) => const SplashPage(),
        '/home': (context) => const HomePage(),
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
    return Scaffold(
      bottomNavigationBar: const NavigationMenu(),
    );
  }
}
