// import 'dart:convert';
// import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// import 'package:http/http.dart' as http;
import 'package:spot/user/authentication/login.dart';

class Adminvendor extends StatefulWidget {
  Adminvendor({super.key});

  @override
  State<Adminvendor> createState() => _AdminvendorState();
}

class _AdminvendorState extends State<Adminvendor> {
//   File? _image;

  /// Picks an image from the gallery
  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }
  // }

  /// Uploads the image to Cloudinary and returns the URL

  // Future<String?> _uploadToCloudinary() async {
  //   if (_image == null) return null;

  //   try {
  //     final url = Uri.parse('https://api.cloudinary.com/v1_1/datygsam7/upload');
  //     final request = http.MultipartRequest('POST', url);

  //     request.fields['upload_preset'] = 'SpotApplication';
  //     request.files
  //         .add(await http.MultipartFile.fromPath('file', _image!.path));

  //     final response = await request.send();
  //     if (response.statusCode == 200) {
  //       final responseData = await response.stream.toBytes();
  //       final responseString = String.fromCharCodes(responseData);
  //       final jsonMap = jsonDecode(responseString);
  //       return jsonMap['secure_url'] as String;
  //     } else {
  //       throw HttpException('Upload failed with status ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error uploading image: $e')),
  //     );
  //     return null;
  //   }
  // }

  /// Uploads the image to Cloudinary and saves the URL to Firestore
  // Future<void> _uploadAndSaveToFirestore(String vendorId) async {
  //   final imageUrl = await _uploadToCloudinary();
  //   if (imageUrl != null) {
  //     await FirebaseFirestore.instance
  //         .collection('vendor_reg')
  //         .doc(vendorId)
  //         .update({'image': imageUrl});
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Image uploaded and saved successfully!')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final CollectionReference vendorreg =
        FirebaseFirestore.instance.collection('vendor_reg');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Vendor List',
          style: TextStyle(color: Colors.amber),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: Colors.amber,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            child: Icon(Icons.logout, color: Colors.black),
          )
        ],
      ),
      body: StreamBuilder(
        stream: vendorreg.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No vendors found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot vendorDoc = snapshot.data!.docs[index];
              final String vendorName = vendorDoc['name'] ?? 'No Name';
              final String imageUrl = vendorDoc['image'] ?? '';
              final String vendorphone = vendorDoc['phone'] ?? '';

              return Container(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6.0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? Icon(Icons.person, size: 40, color: Colors.grey)
                          : null,
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendorName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            vendorphone,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
