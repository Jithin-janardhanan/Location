import 'package:flutter/material.dart';
import 'package:spot/superadmin/screens/adminhome.dart';
import 'package:spot/superadmin/screens/adminvendor.dart';

class BottomNavigationadmin extends StatefulWidget {
  const BottomNavigationadmin({super.key});

  @override
  State<BottomNavigationadmin> createState() => _BottomNavigationadminState();
}

class _BottomNavigationadminState extends State<BottomNavigationadmin> {
  int indexNum = 0;
  List tabWidgets = [Adminhome(), Adminvendor()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.red,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "user",
                backgroundColor: Color.fromARGB(255, 186, 17, 17)),
            BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: "Vendor",
                backgroundColor: Color.fromARGB(255, 116, 25, 25)),
            BottomNavigationBarItem(
                icon: Icon(Icons.money),
                label: "charity",
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
