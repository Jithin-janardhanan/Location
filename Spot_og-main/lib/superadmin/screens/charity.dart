import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CharityMemberList extends StatefulWidget {
  @override
  _CharityMemberListState createState() => _CharityMemberListState();
}

class _CharityMemberListState extends State<CharityMemberList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charity Members', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('charity_reg').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No charity members found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: data['image'] != null
                        ? NetworkImage(data['image'])
                        : null,
                    child: data['image'] == null
                        ? Icon(Icons.person, color: Colors.black)
                        : null,
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
                      Text(
                          data['number'] != null
                              ? data['number'].toString()
                              : 'No Phone',
                          style: TextStyle(color: Colors.black54)),
                      Text(data['category'] ?? 'No Category',
                          style: TextStyle(color: Colors.black54)),
                    ],
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
