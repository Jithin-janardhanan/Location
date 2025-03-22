// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:spot/user/authentication/auth.dart';
// import 'package:spot/user/authentication/login.dart';
// import 'package:spot/user/authentication/registration.dart';
// import 'package:spot/user/authentication/validation.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final _formKey = GlobalKey<FormState>(); // GlobalKey for the Form
//   final Validation _validations = Validation();
//   final _auth = Authentication();

//   // Instance of Validation class
//   final _emailcontroller = TextEditingController();
//   final _passwordcontroller = TextEditingController();
//   final _confirmpassword = TextEditingController();

//   bool _isObscured = true;
//   @override
//   void dispose() {
//     super.dispose();
//     _emailcontroller.dispose();
//     _passwordcontroller.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Spot',
//           style: TextStyle(color: Colors.amberAccent),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey, // Assign the GlobalKey to the Form
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Image(
//                       image: AssetImage('assets/sPOT.PNG'),
//                       height: 200,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       'Signup',
//                       style: TextStyle(
//                         fontSize: 35,
//                         color: const Color.fromARGB(255, 59, 121, 203),
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           children: [
//                             TextFormField(
//                               controller: _emailcontroller,
//                               validator: (value) => _validations.validateemail(
//                                   value ?? 'Enter valid email@.com'),
//                               keyboardType: TextInputType.emailAddress,
//                               decoration: InputDecoration(
//                                 labelText: 'Email',
//                                 hintText: 'Enter email',
//                                 prefixIcon: Icon(Icons.email),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             TextFormField(
//                               controller: _passwordcontroller,
//                               validator: (value) =>
//                                   _validations.validatePassword(value ?? ''),
//                               keyboardType: TextInputType.visiblePassword,
//                               decoration: InputDecoration(
//                                 labelText: 'Password',
//                                 hintText: 'Enter Password',
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 prefixIcon: const Icon(Icons.lock_outline),
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     _isObscured
//                                         ? Icons.visibility_off
//                                         : Icons.visibility,
//                                   ),
//                                   onPressed: () {
//                                     setState(() {
//                                       _isObscured = !_isObscured;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               obscureText: _isObscured,
//                             ),
//                             const SizedBox(height: 15),
//                             TextFormField(
//                               style: TextStyle(
//                                   color: const Color.fromARGB(255, 20, 17, 17)),
//                               controller: _confirmpassword,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 prefixIcon: Icon(Icons.lock),
//                                 labelText: 'Retype password',
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     ElevatedButton(
//                       onPressed: _signup,
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         minimumSize: Size(double.infinity, 50),
//                         backgroundColor: Colors.blue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text('Signup'),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text('Already have an account?'),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => LoginPage()));
//                       },
//                       child: const Text('Login'),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   _signup() async {
//     if (_formKey.currentState!.validate()) {
//       if (_confirmpassword.text != _passwordcontroller.text) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Passwords do not match')),
//         );
//         return;
//       }

//       final user = await _auth.createUserWithEmailAndPassword(
//           _emailcontroller.text, _passwordcontroller.text);

//       if (user != null) {
//         String userId = user.uid;

//         // Store user role in Firestore
//         await FirebaseFirestore.instance.collection('users').doc(userId).set({
//           'email': _emailcontroller.text,
//           'role': 'user', // Change this to 'vendor' if vendor is signing up
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Signup Successful!')),
//         );

//         Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => Registration(),
//             ));
//       }
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spot/user/authentication/auth.dart';
import 'package:spot/user/authentication/login.dart';
import 'package:spot/user/authentication/registration.dart';
import 'package:spot/user/authentication/validation.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final Validation _validations = Validation();
  final _auth = Authentication();
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _confirmpassword = TextEditingController();
  bool _isObscured = true;
  bool _isConfirmObscured = true;

  @override
  void dispose() {
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    _confirmpassword.dispose();
    super.dispose();
  }

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
                padding: EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/Adobe Express - file.png',
                      height: 200,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Sign up to get started!",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 20, 20, 20)
                            .withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 50),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: TextFormField(
                              controller: _emailcontroller,
                              validator: (value) =>
                                  _validations.validateemail(value ?? ''),
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 19, 17, 17)),
                                prefixIcon: Icon(Icons.email_outlined,
                                    color: Colors.black),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Password Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: TextFormField(
                              controller: _passwordcontroller,
                              validator: (value) =>
                                  _validations.validatePassword(value ?? ''),
                              obscureText: _isObscured,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.lock_outline,
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
                                contentPadding: EdgeInsets.all(20),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Confirm Password Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: TextFormField(
                              controller: _confirmpassword,
                              obscureText: _isConfirmObscured,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                hintStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: Colors.black),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmObscured
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => setState(() =>
                                      _isConfirmObscured = !_isConfirmObscured),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),

                          // Sign Up Button
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
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _signup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account ?   ",
                                style: TextStyle(
                                    color: const Color.fromARGB(255, 25, 24, 24)
                                        .withOpacity(0.7)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()),
                                  );
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.blue.shade400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_confirmpassword.text != _passwordcontroller.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      final user = await _auth.createUserWithEmailAndPassword(
          _emailcontroller.text, _passwordcontroller.text);

      if (user != null) {
        String userId = user.uid;

        // Store user role in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': _emailcontroller.text,
          'role': 'user',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup Successful!')),
        );

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Registration(),
            ));
      }
    }
  }
}
