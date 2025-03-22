import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spot/superadmin/navigationadmin.dart';

import 'package:spot/user/authentication/Signup.dart';
import 'package:spot/user/authentication/auth.dart';
import 'package:spot/user/bottomnavigation/Bottom.dart';

import 'package:spot/user/authentication/validation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  final Validation validation = Validation();
  final _auth = Authentication();
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 245, 250),
      body: Stack(
        children: [
          // Background Design
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade500],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade500, Colors.orange.shade400],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(
                  // Center the entire content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // Stretch children to full width
                    children: [
                      // Logo section
                      Center(
                        child: Image.asset(
                          'assets/Adobe Express - file.png',
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Header section
                      const Text(
                        "Let's Sign You In",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center, // Center the header text
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Welcome back, you've been missed!",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center, // Center the welcome text
                      ),

                      const SizedBox(height: 48),

                      // Form section
                      Form(
                        key: formkey,
                        child: Column(
                          children: [
                            // Email field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black),
                              ),
                              child: TextFormField(
                                controller: _emailcontroller,
                                validator: (value) =>
                                    validation.validateemail(value ?? ''),
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: TextStyle(color: Colors.black),
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: Colors.black),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Password field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black),
                              ),
                              child: TextFormField(
                                controller: _passwordcontroller,
                                validator: (value) =>
                                    validation.validatePassword(value ?? ''),
                                obscureText: _isObscured,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle:
                                      const TextStyle(color: Colors.black),
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: Colors.black),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscured
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.black,
                                    ),
                                    onPressed: () => setState(
                                        () => _isObscured = !_isObscured),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Sign In button
                            Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.purple.shade500
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Sign Up section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.7)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupPage()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.blue.shade400,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 200), // Reduced from 200 for better spacing
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _login() async {
    String email = _emailcontroller.text.trim();
    String password = _passwordcontroller.text.trim();

    // Admin login check
    if (email == 'Admin@gmail.com' && password == 'Admin@1234') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationadmin()),
      );
      return;
    }

    if (formkey.currentState!.validate()) {
      try {
        final user = await _auth.signInWithEmailAndPassword(email, password);

        if (user != null) {
          String userId = user.uid;

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection(
                  'user_reg') // Make sure this is the correct collection name
              .doc(userId)
              .get();

          // Debugging: Print document data
          print("User Document Data: ${userDoc.data()}");

          if (userDoc.exists) {
            Map<String, dynamic>? userData =
                userDoc.data() as Map<String, dynamic>?;

            if (userData == null || !userData.containsKey('role')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: User role is missing!')),
              );
              return;
            }

            String role = userData['role'] ?? 'unknown';
            String status = userData['status'] ?? 'inactive';

            print("User Role: $role");
            print("User Status: $status");

            if (status == 'blocked') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Your account has been blocked by the admin.')),
              );
              return;
            }

            if (role == 'user') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User Login Successful!')),
              );
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => BottomNavigation()),
                  (route) => false);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Access Denied: Unrecognized role!')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User data not found in Firestore!')),
            );
          }
        }
      } catch (e) {
        print("Error: $e"); // Debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    }
  }
}
