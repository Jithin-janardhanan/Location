import 'package:flutter/material.dart';
import 'package:spot/user/map.dart';
import 'package:spot/user/screens/user_Profile.dart';
import 'package:spot/user/screens/user_chat.dart';

// class BottomNavigation extends StatefulWidget {
//   const BottomNavigation({super.key});

//   @override
//   State<BottomNavigation> createState() => _BottomNavigationState();
// }

// class _BottomNavigationState extends State<BottomNavigation> {
//   int indexNum = 0;
//   List tabWidgets = [MapScreen(), UserShop(), UserProfile(), ChatListScreen()];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.grey[900],
//         unselectedItemColor: Colors.grey[400],
//         selectedItemColor: Colors.cyanAccent,
//         elevation: 10,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.map),
//             label: "Map",
//             backgroundColor: Color(0xFF282828),
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.store),
//             label: "Shop",
//             backgroundColor: Color(0xFF2F2F2F),
//           ),
//           // BottomNavigationBarItem(
//           //   icon: Icon(Icons.search),
//           //   label: "Search",
//           //   backgroundColor: Color(0xFF2F2F2F),
//           // ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: "Profile",
//             backgroundColor: Color(0xFF2F2F2F),
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat),
//             label: 'Chats',
//           ),
//         ],
//         selectedFontSize: 14,
//         currentIndex: indexNum,
//         onTap: (int index) {
//           setState(() {
//             indexNum = index;
//           });
//         },
//       ),
//       body: Center(child: tabWidgets.elementAt(indexNum)),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:spot/user/screens/user_shoplist.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with TickerProviderStateMixin {
  int indexNum = 0;
  List tabWidgets = [MapScreen(), UserShop(), UserProfile(), ChatListScreen()];
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    _controllers[0].forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for transparent navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            backgroundColor:
                const Color.fromARGB(255, 235, 229, 229)?.withOpacity(0.95),
            unselectedItemColor: const Color.fromARGB(255, 80, 78, 78),
            selectedItemColor: const Color.fromARGB(255, 143, 45, 10),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: List.generate(4, (index) {
              return BottomNavigationBarItem(
                icon: AnimatedBuilder(
                  animation: _controllers[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: Tween<double>(begin: 1.0, end: 1.2)
                          .animate(CurvedAnimation(
                            parent: _controllers[index],
                            curve: Curves.easeOutBack,
                          ))
                          .value,
                      child: child,
                    );
                  },
                  child: _buildIcon(index),
                ),
                label: _getLabel(index),
              );
            }),
            selectedFontSize: 14,
            unselectedFontSize: 12,
            currentIndex: indexNum,
            onTap: (int index) {
              setState(() {
                // Reset all controllers
                for (var controller in _controllers) {
                  controller.reset();
                }
                // Animate the selected icon
                _controllers[index].forward();
                indexNum = index;
              });
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(child: tabWidgets.elementAt(indexNum)),
          // Add a subtle gradient overlay at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(int index) {
    final icons = [
      Icons.map_rounded,
      Icons.store_rounded,
      Icons.person_rounded,
      Icons.chat_rounded,
    ];

    return Stack(
      children: [
        Icon(icons[index]),
        if (index == 3) // Notification badge for chat
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getLabel(int index) {
    final labels = ['Map', 'Shop', 'Profile', 'Chats'];
    return labels[index];
  }
}
