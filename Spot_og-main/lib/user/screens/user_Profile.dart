import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:spot/user/authentication/login.dart';
import 'package:url_launcher/url_launcher.dart';

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
          'Profile',
          style: TextStyle(
            fontSize: 24,
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isEditing
                ? IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      setState(() => _isSaving = true);
                      await _updateUserData();
                      setState(() {
                        _isSaving = false;
                        _isEditing = false;
                      });
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    _firebaseAuth.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isSaving
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            )
          : FutureBuilder<DocumentSnapshot>(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error fetching data',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_off,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No profile data found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  );
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
                        Hero(
                          tag: 'profile-image',
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 75,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _image != null
                                      ? FileImage(_image!)
                                      : (_imageUrl != null &&
                                              _imageUrl!.isNotEmpty
                                          ? NetworkImage(_imageUrl!)
                                          : null) as ImageProvider?,
                                  child: _imageUrl == null && _image == null
                                      ? const Icon(Icons.person,
                                          size: 75, color: Colors.grey)
                                      : null,
                                ),
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Material(
                                    elevation: 4,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      onTap: _pickImage,
                                      customBorder: const CircleBorder(),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.amber,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt,
                                            color: Colors.white, size: 24),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _name,
                                  label: 'Full Name',
                                  icon: Icons.person,
                                  enabled: _isEditing,
                                ),
                                const SizedBox(height: 24),
                                _buildTextField(
                                  controller: _phone,
                                  label: 'Phone Number',
                                  icon: Icons.phone,
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 24),
                                _buildTextField(
                                  controller: _email,
                                  label: 'Email Address',
                                  icon: Icons.email,
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          icon: const Icon(Icons.privacy_tip_outlined),
                          label: const Text('Privacy Policy'),
                          onPressed: () {
                            launchUrl(Uri.parse(
                                "https://www.freeprivacypolicy.com/live/f2379df2-bc9a-444b-9b35-a71f2d885496"));
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                const Color.fromARGB(255, 138, 34, 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: enabled ? Colors.grey[50] : Colors.grey[100],
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: TextStyle(
          color: enabled ? Colors.black87 : Colors.black54,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled ? Colors.amber : Colors.grey,
            fontSize: 14,
          ),
          prefixIcon:
              Icon(icon, color: enabled ? Colors.amber : Colors.grey, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: enabled ? Colors.amber : Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: enabled ? Colors.amber : Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.amber,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
        ),
      ),
    );
  }
}
