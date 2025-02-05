// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:spot/user/screens/user_chat.dart';

// class ChatListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Chats'),
//         backgroundColor: Colors.black,
//         titleTextStyle: const TextStyle(
//           color: Colors.amber,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('chat_rooms')
//             .where('participants', arrayContains: currentUserId)
//             .orderBy('lastMessageTime', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final chatRooms = snapshot.data!.docs;

//           if (chatRooms.isEmpty) {
//             return const Center(child: Text('No chats yet'));
//           }

//           return ListView.builder(
//             itemCount: chatRooms.length,
//             itemBuilder: (context, index) {
//               final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
//               final userDetails =
//                   chatRoom['userDetails'] as Map<String, dynamic>;

//               // Get the other participant's details
//               final otherParticipantId = (chatRoom['participants'] as List)
//                   .firstWhere((id) => id != currentUserId);
//               final otherParticipant = userDetails[otherParticipantId];

//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.amber,
//                   child: Text(
//                     otherParticipant['name'][0].toUpperCase(),
//                     style: const TextStyle(color: Colors.black),
//                   ),
//                 ),
//                 title: Text(otherParticipant['name']),
//                 subtitle: Text(
//                   chatRoom['lastMessage'] ?? 'No messages yet',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 trailing: Text(
//                   DateTime.fromMillisecondsSinceEpoch(
//                     chatRoom['lastMessageTime'].millisecondsSinceEpoch,
//                   ).toString().substring(11, 16),
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ChatScreen(
//                         vendorId: otherParticipantId,
//                         vendorName: otherParticipant['name'],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
