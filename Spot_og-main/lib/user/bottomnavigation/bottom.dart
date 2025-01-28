import 'package:flutter/material.dart';
import 'package:spot/user/map.dart';
import 'package:spot/user/screens/home.dart';

import 'package:spot/user/screens/user_Profile.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int indexNum = 0;
  List tabWidgets = [MapScreen(), UserProfile(), HomePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.red,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
                backgroundColor: Color.fromARGB(255, 186, 17, 17)),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
                backgroundColor: Color.fromARGB(255, 116, 25, 25)),
            BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
                backgroundColor: Color.fromARGB(255, 116, 25, 25)),
          ],
          selectedFontSize: 25,
          currentIndex: indexNum,
          onTap: (int index) {
            setState(() {
              indexNum = index;
            });
          }),
      body: Center(child: tabWidgets.elementAt(indexNum)),
    );
  }
}
