import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home_page.dart';
import 'package:flutter_app/pages/periherals_custom_pages/custom_peripherals.dart';
import 'package:flutter_app/pages/peripherals_prompt_side_pages/all_peripherals_attached.dart';
import 'package:flutter_app/pages/settings_page.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationController>(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white24,
        surfaceTintColor: const Color.fromARGB(255, 148, 164, 169),
        indicatorColor: const Color.fromARGB(255, 151, 192, 205),
        height: 80,
        elevation: 50,
        selectedIndex: navProvider.selectedIndex,
        onDestinationSelected: (index) {
          navProvider.selectedIndex = index;
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.add), label: "New Device"),
          NavigationDestination(
              icon: Icon(Icons.dashboard_customize), label: "Custom"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      body: navProvider.screens[navProvider.selectedIndex],
    );
  }
}

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  final screens = [
    const HomePage(),
    const NewPeripheral(),
    const CustomPeripheral(),
    const Settings()
  ];
  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners(); // Notify listeners about the change
  }
}
