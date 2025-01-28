// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:spot/splash.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: FirebaseOptions(
//       apiKey: "AIzaSyDPiE3DhwyO5tu0ecW7LRr4zik8mYAnzoY",
//       appId: "1:1078670204041:android:df408abed26c3c115aba58",
//       messagingSenderId: "1078670204041",
//       projectId: " spot-cfbd3",
//     ),
//   );
//   runApp(const Login());
// }

// class Login extends StatelessWidget {
//   const Login({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Spot',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: SplashScreen(),
//     );
//   }
// }
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:spot/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  try {
    await dotenv.load(fileName: ".env"); // Load environment variables
  } catch (e) {
    throw Exception('Error loading .env file: $e'); // Print error if any
  }
  MapboxOptions.setAccessToken(
      "sk.eyJ1Ijoiaml0aGluamFuYXJkaGFuYW4iLCJhIjoiY202OTBhYmdlMDc1ZTJqcGg2NmpicHFiMyJ9.QIMsY2JjujmvtXsSiAMDjA");
  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? "Missing API Key",
      appId: dotenv.env['FIREBASE_APP_ID'] ?? "Missing App ID",
      messagingSenderId:
          dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? "Missing Sender ID",
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? "Missing Project ID",
    ),
  );

  runApp(const Login());
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
