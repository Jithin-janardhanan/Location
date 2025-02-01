// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:spot/user/authentication/login.dart';

// class UserListPage extends StatefulWidget {
//   @override
//   _UserListPageState createState() => _UserListPageState();
// }

// class _UserListPageState extends State<UserListPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'User List',
//           style: TextStyle(color: Colors.yellow),
//         ),
//         backgroundColor: Colors.black,
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection('user_reg').snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No users found'));
//           }
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var doc = snapshot.data!.docs[index];
//               var data = doc.data() as Map<String, dynamic>;
//               return Card(
//                 margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                 color: Colors.cyanAccent,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         data['name'] ?? 'No Name',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.deepPurple,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         data['email'] ?? 'No Email',
//                         style: TextStyle(color: Colors.blueAccent),
//                       ),
//                       Text(
//                         data['phone'] ?? 'No Phone',
//                         style: TextStyle(color: Colors.green),
//                       ),
//                       SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Blocked:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Switch(
//                             value: data['blocked'] ?? false,
//                             onChanged: (bool value) {
//                               FirebaseFirestore.instance
//                                   .collection('user_reg')
//                                   .doc(doc.id)
//                                   .update({'blocked': value});
//                             },
//                             activeColor: Colors.red,
//                             inactiveThumbColor: Colors.blue,
//                             inactiveTrackColor: Colors.blueGrey,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },y
//       ),
//     );
//   }
// }

// Future<void> checkUserAccess(BuildContext context) async {
//   User? user = FirebaseAuth.instance.currentUser;
//   if (user != null) {
//     DocumentSnapshot userDoc = await FirebaseFirestore.instance
//         .collection('user_reg')
//         .doc(user.uid)
//         .get();
//     if (userDoc.exists && (userDoc['blocked'] ?? false)) {
//       await FirebaseAuth.instance.signOut();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginPage()),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text('Your account has been blocked. Contact support.')),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spot/user/authentication/login.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Navigate to login screen and remove all previous routes
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('user_reg').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              bool isBlocked = data['blocked'] ?? false;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                color: isBlocked ? Colors.red.shade100 : Colors.white,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  title: Text(
                    data['name'] ?? 'No Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['email'] ?? 'No Email',
                          style: TextStyle(color: Colors.black54)),
                      Text(data['phone'] ?? 'No Phone',
                          style: TextStyle(color: Colors.black54)),
                      if (isBlocked)
                        Text(
                          'Blocked',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  trailing: Switch(
                    activeColor: Colors.red,
                    value: isBlocked,
                    onChanged: (bool value) {
                      FirebaseFirestore.instance
                          .collection('user_reg')
                          .doc(doc.id)
                          .update({'blocked': value});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> checkUserAccess(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user_reg')
        .doc(user.uid)
        .get();
    if (userDoc.exists && (userDoc['blocked'] ?? false)) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your account has been blocked. Contact support.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
