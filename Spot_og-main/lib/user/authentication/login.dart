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
            // Image.asset('assets/SplashScreen__1_-removebg-preview.png'),
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
                          onPressed: _login
                          //  () {
                          //   if (formkey.currentState!.validate()) {
                          //     // Perform signup logic here
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       const SnackBar(
                          //           content: Text("Login Successful")),
                          //     );

                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => HomePage()));
                          //   }
                          // },
                          ,
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
    // Trim input values to avoid issues with leading/trailing spaces
    String email = _emailcontroller.text.trim();
    String password = _passwordcontroller.text.trim();

    // Admin credentials check
    if (email == 'Admin@gmail.com' && password == 'Admin@1234') {
      // Navigate to admin home
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationadmin()),
      );
    }
    // Regular user login
    else if (formkey.currentState!.validate()) {
      try {
        final user = await _auth.signInWithEmailAndPassword(
          email,
          password,
        );

        if (user != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('LOGIN Successful!')),
          );

          // Navigate to user home
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BottomNavigation()),
          );
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    }
  }
}
