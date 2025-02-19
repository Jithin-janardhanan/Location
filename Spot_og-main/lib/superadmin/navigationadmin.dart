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

  final List<Widget> tabWidgets = [
    AdminUserManagement(),
    Adminvendor(),
    CharityMemberList(),
    ShopAnalyticsBarChart()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Center(
          key: ValueKey<int>(indexNum),
          child: tabWidgets[indexNum],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: NavigationBar(
                height: 65,
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.amber.withOpacity(0.2),
                selectedIndex: indexNum,
                onDestinationSelected: (int index) {
                  setState(() {
                    indexNum = index;
                  });
                },
                destinations: [
                  _buildNavDestination(
                    icon: Icons.people_alt_outlined,
                    selectedIcon: Icons.people_alt_rounded,
                    label: 'Users',
                    index: 0,
                  ),
                  _buildNavDestination(
                    icon: Icons.store_outlined,
                    selectedIcon: Icons.store_rounded,
                    label: 'Vendors',
                    index: 1,
                  ),
                  _buildNavDestination(
                    icon: Icons.volunteer_activism_outlined,
                    selectedIcon: Icons.volunteer_activism_rounded,
                    label: 'Charity',
                    index: 2,
                  ),
                  _buildNavDestination(
                    icon: Icons.analytics_outlined,
                    selectedIcon: Icons.analytics_rounded,
                    label: 'Analytics',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = indexNum == index;
    return NavigationDestination(
      icon: Icon(
        icon,
        color: isSelected ? Colors.amber : Colors.amber.withOpacity(0.7),
      ),
      selectedIcon: Icon(
        selectedIcon,
        color: Colors.amber,
      ),
      label: label,
      tooltip: label,
    );
  }
}

// Optional: Add this theme data to your MaterialApp for consistent styling
ThemeData _buildTheme() {
  return ThemeData(
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            color: Colors.amber,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          );
        }
        return TextStyle(
          color: Colors.amber.withOpacity(0.7),
          fontSize: 12,
        );
      }),
    ),
  );
}
