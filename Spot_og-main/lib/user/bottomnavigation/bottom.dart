// import 'package:flutter/material.dart';
// import 'package:spot/user/map.dart';
// import 'package:spot/user/screens/home.dart';
// import 'package:spot/user/screens/user_Profile.dart';
// import 'package:spot/user/user_shop.dart';

// class BottomNavigation extends StatefulWidget {
//   const BottomNavigation({super.key});

//   @override
//   State<BottomNavigation> createState() => _BottomNavigationState();
// }

// class _BottomNavigationState extends State<BottomNavigation> {
//   int indexNum = 0;
//   List tabWidgets = [MapScreen(), usershop(), HomePage(), UserProfile()];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: BottomNavigationBar(
//           backgroundColor: Colors.black,
//           unselectedItemColor: Colors.white,
//           selectedItemColor: Colors.red,
//           items: const [
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.home),
//                 label: "Home",
//                 backgroundColor: Color.fromARGB(255, 186, 17, 17)),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.shop),
//                 label: "Shop",
//                 backgroundColor: Color.fromARGB(255, 116, 25, 25)),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.search),
//                 label: "Search",
//                 backgroundColor: Color.fromARGB(255, 116, 25, 25)),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.person),
//                 label: "Profile",
//                 backgroundColor: Color.fromARGB(255, 116, 25, 25)),
//           ],
//           selectedFontSize: 25,
//           currentIndex: indexNum,
//           onTap: (int index) {
//             setState(() {
//               indexNum = index;
//             });
//           }),
//       body: Center(child: tabWidgets.elementAt(indexNum)),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:spot/user/map.dart';
import 'package:spot/user/screens/home.dart';
import 'package:spot/user/screens/user_Profile.dart';
import 'package:spot/user/user_shop.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int indexNum = 0;
  List tabWidgets = [
    MapScreen(),
    NearestShopsPage(),
    HomePage(),
    UserProfile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        unselectedItemColor: Colors.grey[400],
        selectedItemColor: Colors.cyanAccent,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
            backgroundColor: Color(0xFF282828),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Shop",
            backgroundColor: Color(0xFF2F2F2F),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
            backgroundColor: Color(0xFF2F2F2F),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
            backgroundColor: Color(0xFF2F2F2F),
          ),
        ],
        selectedFontSize: 14,
        currentIndex: indexNum,
        onTap: (int index) {
          setState(() {
            indexNum = index;
          });
        },
      ),
      body: Center(child: tabWidgets.elementAt(indexNum)),
    );
  }
}
