import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spot/user/authentication/login.dart';

class AdminUserManagement extends StatefulWidget {
  @override
  _AdminUserManagementState createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void toggleBlockStatus(String userId, String currentStatus) async {
    String newStatus = currentStatus == "active" ? "blocked" : "active";
    await _firestore.collection('user_reg').doc(userId).update({
      'status': newStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User $newStatus successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            'Spot User',
            style: TextStyle(color: Colors.amber),
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ));
                },
                child: Icon(Icons.logout))
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('user_reg').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var users = snapshot.data!.docs;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                String userId = user.id;
                String name = user['name'];
                String email = user['email'];
                String status = user['status'];
                String imageUrl = user['image'];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? Icon(Icons.person, size: 40, color: Colors.grey)
                          : null,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(email),
                    trailing: ElevatedButton(
                      onPressed: () => toggleBlockStatus(userId, status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            status == "active" ? Colors.red : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        status == "active" ? "Block" : "Unblock",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
