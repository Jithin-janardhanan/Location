import 'package:flutter/material.dart';
import 'package:spot/user/authentication/login.dart';

class Adminhome extends StatefulWidget {
  const Adminhome({super.key});

  @override
  State<Adminhome> createState() => _AdminhomeState();
}

class _AdminhomeState extends State<Adminhome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          style: TextStyle(color: Colors.amber),
          textAlign: TextAlign.center,
          'Spot_Admin',
        ),
        backgroundColor: const Color.fromARGB(255, 11, 10, 10),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              icon: Icon(Icons.logout_rounded))
        ],
      ),
    );
  }
}
