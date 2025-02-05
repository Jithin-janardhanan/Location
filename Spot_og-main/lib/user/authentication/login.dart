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
      appBar: AppBar(
        title: Text(
          'Spot',
          style: TextStyle(color: Colors.amberAccent),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/sPOT.PNG'),
              height: 200,
            ),
            Text(
              'Welcome Back to spot',
              style: TextStyle(
                fontSize: 35,
                color: const Color.fromARGB(255, 61, 130, 219),
                fontWeight: FontWeight.w100,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Form(
                key: formkey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextFormField(
                        controller: _emailcontroller,
                        validator: (value) =>
                            validation.validateemail(value ?? ''),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: TextFormField(
                          controller: _passwordcontroller,
                          validator: (value) =>
                              validation.validatePassword(value ?? ''),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                          ),
                          obscureText: _isObscured,
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: MaterialButton(
                          minWidth: double.maxFinite,
                          onPressed: _login,
                          color: Colors.blue,
                          textColor: const Color.fromARGB(255, 254, 254, 254),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('login')),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("don't have an account ?"),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupPage()));
                            },
                            child: Text('SIGNUP'))
                      ],
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  _login() async {
    String email = _emailcontroller.text.trim();
    String password = _passwordcontroller.text.trim();

    // Admin login check
    if (email == 'Admin@gmail.com' && password == 'Admin@1234') {
      Navigator.push(
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BottomNavigation()),
              );
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
