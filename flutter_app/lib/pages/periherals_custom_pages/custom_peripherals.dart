import 'package:flutter/material.dart';
import 'package:flutter_app/pages/periherals_custom_pages/custom_car_peripheral.dart';
import 'package:flutter_app/pages/periherals_custom_pages/tank_custom_periheral.dart';
import 'package:flutter_app/pages/periherals_custom_pages/weather_custom_periheral.dart';
import 'package:flutter_app/widgets/custom_card_peripheral.dart';

class CustomPeripheral extends StatelessWidget {
  const CustomPeripheral({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 70,
          ),
          Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: CustomCard(
                  method: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyCar()),
                    );
                  },
                  text: 'Custom car\nperipheral',
                  imagePath: 'assets/car.png')),
          const SizedBox(
            height: 30,
          ),
          Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: CustomCard(
                  method: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyWeatherPage()),
                    );
                  },
                  text: 'Custom weather\nperipheral',
                  imagePath: 'assets/hot.png')),
          const SizedBox(
            height: 30,
          ),
          Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: CustomCard(
                  method: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyTankPage()),
                    );
                  },
                  text: 'Custom tank\nperipheral',
                  imagePath: 'assets/tank.png')),
        ],
      ),
    );
  }
}
