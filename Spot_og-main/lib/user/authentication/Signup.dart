import 'package:flutter/material.dart';

import 'package:spot/user/authentication/auth.dart';
import 'package:spot/user/authentication/login.dart';
import 'package:spot/user/authentication/registration.dart';
import 'package:spot/validation.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for the Form
  final Validation _validations = Validation();
  final _auth = Authentication();

  // Instance of Validation class
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _confirmpassword = TextEditingController();

  bool _isObscured = true;
  @override
  void dispose() {
    super.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
  }

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
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Assign the GlobalKey to the Form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Signup',
                  style: TextStyle(
                      fontSize: 35,
                      color: const Color.fromARGB(255, 59, 121, 203),
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextFormField(
                    controller: _emailcontroller,
                    validator: (value) => _validations.validateemail(
                        value ?? 'Enter valid email@.com'), // Email validation
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextFormField(
                    controller: _passwordcontroller,
                    validator: (value) => _validations
                        .validatePassword(value ?? ''), // Password validation

                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter Password',
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                    ),
                    obscureText: _isObscured,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextFormField(
                    style:
                        TextStyle(color: const Color.fromARGB(255, 20, 17, 17)),
                    controller: _confirmpassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Retype password',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: MaterialButton(
                    minWidth: double.maxFinite,
                    onPressed: _signup,
                    color: Colors.blue,
                    textColor: const Color.fromARGB(255, 254, 254, 254),
                    child: const Text('Signup'),
                  ),
                ),
                const Text('Already have an account?'),
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: const Text('Login'))
              ],
            ),
          ),
        ),
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
        // Form is valid
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
