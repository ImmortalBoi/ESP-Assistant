import 'package:flutter/material.dart';

class MyNavBar extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyNavBar({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  State<MyNavBar> createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  List<IconData> navIcons = [
    Icons.home,
    Icons.add,
    Icons.dashboard_customize,
    Icons.settings,
  ];
  int selectedIndex = 0;
  List<String> navTexts = [
    'Home',
    'New Device ',
    'custom',
    'Settings',
  ];
  List<String> navRoutes = [
    '/home',
    '/NewPeripheral',
    '/CustomPeripheral',
    '/settings'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(left: 32, right: 32, bottom: 20),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 251, 251, 251),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: navIcons.map((icon) {
          int index = navIcons.indexOf(icon);
          bool isSelected = selectedIndex == index;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.navigatorKey.currentState!
                    .pushReplacementNamed(navRoutes[index]);
              },
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                      top: 15,
                      left: 22,
                      right: 22,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? const Color(0xff1F5460)
                          : Colors.grey[500],
                    ),
                  ),
                  Text(
                    navTexts[index],
                    style: TextStyle(
                        color: isSelected
                            ? const Color(0xff1F5460)
                            : Colors.grey[500],
                        fontSize: 11),
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
