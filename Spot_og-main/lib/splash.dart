// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:spot/user/authentication/login.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => LoginPage()));
//     });
//   }

//   @override
//   void dispose() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SizedBox(
//       width: double.infinity,
//       height: double.infinity,
//       child: Image.asset(
//         'assets/splass.jpeg',
//         fit: BoxFit.cover,
//       ),
//     ));
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spot/superadmin/navigationadmin.dart';
import 'package:spot/user/authentication/login.dart';
import 'package:spot/user/bottomnavigation/bottom.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Delay and check login state
    Future.delayed(const Duration(seconds: 3), checkUserLogin);
  }

  void checkUserLogin() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, navigate to HomePage
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BottomNavigation()));
    } else {
      // User is not logged in, navigate to LoginPage
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/splass.jpeg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
