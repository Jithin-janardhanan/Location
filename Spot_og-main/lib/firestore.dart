// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   Stream<QuerySnapshot> getChatRooms(String userId) {
//     return _db
//         .collection('chats')
//         .where('participants', arrayContains: userId)
//         .snapshots();
//   }

//   Stream<QuerySnapshot> getMessages(String chatId) {
//     return _db
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('timestamp')
//         .snapshots();
//   }

//   Future<void> sendMessage(String chatId, Map<String, dynamic> message) {
//     return _db
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add(message);
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
