// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:spot/user/authentication/auth.dart';
// import 'package:http/http.dart' as http;

// class UserProfile extends StatefulWidget {
//   const UserProfile({super.key});

//   @override
//   State<UserProfile> createState() => _UserProfileState();
// }

// class _UserProfileState extends State<UserProfile> {
//   final _auth = Authentication();
//   final _firebaseAuth = FirebaseAuth.instance;
//   File? _image;
//   late TextEditingController _name;
//   late TextEditingController _phone;
//   late TextEditingController _email;
//   String? _imageUrl;

//   bool _isEditing = false;
//   bool _isSaving = false;

//   // final _location = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     _name = TextEditingController();
//     _phone = TextEditingController();
//     _email = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _name.dispose();
//     _phone.dispose();
//     _email.dispose();

//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   Future<String?> _uploadToCloudinary() async {
//     if (_image == null) return null;

//     try {
//       final url = Uri.parse('https://api.cloudinary.com/v1_1/datygsam7/upload');
//       final request = http.MultipartRequest('POST', url);

//       request.fields['upload_preset'] = 'SpotApplication';
//       request.files
//           .add(await http.MultipartFile.fromPath('file', _image!.path));

//       final response = await request.send();
//       if (response.statusCode == 200) {
//         final responseData = await response.stream.toBytes();
//         final responseString = String.fromCharCodes(responseData);
//         final jsonMap = jsonDecode(responseString);
//         return jsonMap['secure_url'] as String;
//       } else {
//         throw HttpException('Upload failed with status ${response.statusCode}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error uploading image: $e')),
//       );
//       return null;
//     }
//   }

//   Future<DocumentSnapshot> _getUserData() async {
//     final currentUser = _firebaseAuth.currentUser;
//     if (currentUser == null) {
//       throw Exception('No user is currently signed in.');
//     }
//     return FirebaseFirestore.instance
//         .collection('user_reg')
//         .doc(currentUser.uid)
//         .get();
//   }

//   Future<void> _updateUserData() async {
//     final currentUser = _firebaseAuth.currentUser;
//     if (currentUser == null) {
//       throw Exception('No user is currently signed in.');
//     }

//     if (_image != null) {
//       _imageUrl = await _uploadToCloudinary();
//       if (_imageUrl == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to upload image')));
//         return;
//       }
//     }

//     final data = {
//       'name': _name.text,
//       'number': _phone.text,
//       'Email': _email.text,
//       'image': _imageUrl ?? '',
//     };

//     await FirebaseFirestore.instance
//         .collection('user_reg')
//         .doc(currentUser.uid)
//         .set(data, SetOptions(merge: true));

//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Spot',
//             style: TextStyle(color: Colors.amber),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.black,
//           actions: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () async {
//                   if (_isEditing) {
//                     setState(() {
//                       _isSaving = true;
//                     });
//                     await _updateUserData();
//                     setState(() {
//                       _isSaving = false;
//                       _isEditing = false;
//                     });
//                   } else {
//                     setState(() {
//                       _isEditing = true;
//                     });
//                   }
//                 },
//                 child: Text(_isEditing ? 'Save' : 'Edit'),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SizedBox(
//                   child:
//                       ElevatedButton(onPressed: () {}, child: Text('Logout'))),
//             )
//           ],
//         ),
//         body: _isSaving
//             ? const Center(child: CircularProgressIndicator())
//             : FutureBuilder<DocumentSnapshot>(
//                 future: _getUserData(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError) {
//                     return const Center(
//                         child: Text('Error fetching user data.'));
//                   }
//                   if (!snapshot.hasData || !snapshot.data!.exists) {
//                     return const Center(child: Text('User data not found.'));
//                   }

//                   final user = snapshot.data!.data() as Map<String, dynamic>;

//                   if (!_isEditing) {
//                     _name.text = user['name'] ?? '';
//                     _phone.text = user['number'] ?? '';
//                     _email.text = user['occupation'] ?? '';

//                     _imageUrl = user['image'] ?? '';
//                   }
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SingleChildScrollView(
//                       child: Form(
//                         child: Column(children: [
//                           Stack(
//                             children: [
//                               CircleAvatar(
//                                 radius: 50,
//                                 backgroundImage: _image != null
//                                     ? FileImage(_image!)
//                                     : (_imageUrl != null &&
//                                             _imageUrl!.isNotEmpty
//                                         ? NetworkImage(_imageUrl!)
//                                         : null) as ImageProvider?,
//                                 child: _imageUrl == null && _image == null
//                                     ? const Icon(Icons.person, size: 50)
//                                     : null,
//                               ),
//                               if (_isEditing)
//                                 Positioned(
//                                   bottom: 0,
//                                   right: 0,
//                                   child: IconButton(
//                                     icon: const Icon(Icons.edit,
//                                         color: Colors.blue),
//                                     onPressed: _pickImage,
//                                   ),
//                                 ),

//                               Padding(
//                                 padding: const EdgeInsets.all(20.0),
//                                 child: TextFormField(
//                                   controller: _name,
//                                   decoration: InputDecoration(
//                                       labelText: 'Name',
//                                       prefixIcon: Icon(Icons.person),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       )),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(20.0),
//                                 child: TextFormField(
//                                   controller: _phone,
//                                   decoration: InputDecoration(
//                                       labelText: 'Number',
//                                       prefixIcon: Icon(Icons.phone),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       )),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(20.0),
//                                 child: TextFormField(
//                                   controller: _email,
//                                   decoration: InputDecoration(
//                                       labelText: 'Email',
//                                       prefixIcon: Icon(Icons.mail),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       )),
//                                 ),
//                               ),

//                             ],
//                           ),
//                         ]),
//                       ),
//                     ),
//                   );
//                 },
//               ));
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:spot/user/authentication/login.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _firebaseAuth = FirebaseAuth.instance;
  File? _image;
  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _email;
  String? _imageUrl;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _phone = TextEditingController();
    _email = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadToCloudinary() async {
    if (_image == null) return null;

    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/datygsam7/upload');
      final request = http.MultipartRequest('POST', url);

      request.fields['upload_preset'] = 'SpotApplication';
      request.files
          .add(await http.MultipartFile.fromPath('file', _image!.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'] as String;
      } else {
        throw HttpException('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  Future<DocumentSnapshot> _getUserData() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently signed in.');
    }
    return FirebaseFirestore.instance
        .collection('user_reg')
        .doc(currentUser.uid)
        .get();
  }

  Future<void> _updateUserData() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently signed in.');
    }

    if (_image != null) {
      _imageUrl = await _uploadToCloudinary();
      if (_imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')));
        return;
      }
    }

    final data = {
      'name': _name.text,
      'phone': _phone.text,
      'email': _email.text,
      'image': _imageUrl ?? '',
    };

    await FirebaseFirestore.instance
        .collection('user_reg')
        .doc(currentUser.uid)
        .set(data, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Spot',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing ? Colors.green : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (_isEditing) {
                  setState(() {
                    _isSaving = true;
                  });
                  await _updateUserData();
                  setState(() {
                    _isSaving = false;
                    _isEditing = false;
                  });
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
              child: Text(_isEditing ? 'Save' : 'Edit'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _firebaseAuth.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<DocumentSnapshot>(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching user data.'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User data not found.'));
                }

                final user = snapshot.data!.data() as Map<String, dynamic>;

                if (!_isEditing) {
                  _name.text = user['name'] ?? '';
                  _phone.text = user['phone'] ?? '';
                  _email.text = user['email'] ?? '';
                  _imageUrl = user['image'] ?? '';
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : (_imageUrl != null && _imageUrl!.isNotEmpty
                                      ? NetworkImage(_imageUrl!)
                                      : null) as ImageProvider?,
                              child: _imageUrl == null && _image == null
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 10,
                                child: InkWell(
                                  onTap: _pickImage,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blue,
                                    child: const Icon(Icons.edit,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _name,
                                  enabled: _isEditing,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    prefixIcon: const Icon(Icons.person,
                                        color: Colors.black),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _phone,
                                  enabled: _isEditing,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: 'Number',
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    prefixIcon: const Icon(Icons.phone,
                                        color: Colors.black),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _email,
                                  enabled: _isEditing,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    prefixIcon: const Icon(Icons.mail,
                                        color: Colors.black),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
