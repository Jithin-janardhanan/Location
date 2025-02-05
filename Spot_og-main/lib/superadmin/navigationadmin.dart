import 'package:flutter/material.dart';
import 'package:spot/superadmin/screens/adminhome.dart';
import 'package:spot/superadmin/screens/adminvendor.dart';
import 'package:spot/superadmin/screens/charity.dart';
import 'package:spot/superadmin/screens/graphscreen.dart';

class BottomNavigationadmin extends StatefulWidget {
  const BottomNavigationadmin({super.key});

  @override
  State<BottomNavigationadmin> createState() => _BottomNavigationadminState();
}

class _BottomNavigationadminState extends State<BottomNavigationadmin> {
  int indexNum = 0;
  List tabWidgets = [
    AdminUserManagement(),
    Adminvendor(),
    CharityMemberList(),
    ShopAnalyticsBarChart()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(
        child: BottomNavigationBar(
            backgroundColor: Colors.white,
            unselectedItemColor: const Color.fromARGB(255, 197, 157, 12),
            selectedItemColor: const Color.fromARGB(255, 246, 242, 241),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "user",
                  backgroundColor: Color.fromARGB(255, 16, 15, 15)),
              BottomNavigationBarItem(
                  icon: Icon(Icons.business),
                  label: "Vendor",
                  backgroundColor: Color.fromARGB(255, 20, 3, 3)),
              BottomNavigationBarItem(
                  icon: Icon(Icons.money),
                  label: "charity",
                  backgroundColor: Color.fromARGB(255, 27, 15, 15)),
              BottomNavigationBarItem(
                  icon: Icon(Icons.auto_graph_rounded),
                  label: "graph",
                  backgroundColor: Color.fromARGB(255, 16, 5, 5)),
            ],
            selectedFontSize: 25,
            currentIndex: indexNum,
            onTap: (int index) {
              setState(() {
                indexNum = index;
              });
            }),
      ),
      body: Center(child: tabWidgets.elementAt(indexNum)),
    );
  }
}
