import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> vendorData;

  const ChatScreen({Key? key, required this.vendorData}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? currentUserId;
  String? currentUserEmail;
  String? currentUserName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        currentUserId = user.uid;

        // Fetch user details
        final userDoc = await FirebaseFirestore.instance
            .collection('user_reg')
            .doc(currentUserId)
            .get();

        if (userDoc.exists && mounted) {
          setState(() {
            currentUserName = userDoc.data()?['name'] as String? ?? 'User';
            currentUserEmail = userDoc.data()?['email'] as String? ?? '';
            isLoading = false;
          });
        } else if (mounted) {
          setState(() {
            currentUserName = 'User';
            currentUserEmail = '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error initializing user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        currentUserId == null ||
        currentUserEmail == null) {
      return;
    }

    try {
      final vendorId = widget.vendorData['vendorId'] as String?;
      final vendorEmail = widget.vendorData['email'] as String?;

      if (vendorId == null ||
          vendorId.isEmpty ||
          vendorEmail == null ||
          vendorEmail.isEmpty) {
        throw Exception('Invalid vendor data');
      }

      // Create chat room ID using emails to ensure consistency
      final List<String> roomParticipants = [currentUserEmail!, vendorEmail]
        ..sort();
      final String chatRoomId = roomParticipants.join('_');

      // First, check if participantDetails are valid
      final participantDetails = {
        currentUserId!: {
          'name': currentUserName ?? 'User',
          'email': currentUserEmail,
          'role': 'user'
        },
        vendorId: {
          'name': widget.vendorData['name'] ?? 'Vendor',
          'email': vendorEmail,
          'role': 'vendor'
        }
      };

      // Create message document
      final messageData = {
        'senderId': currentUserId,
        'senderName': currentUserName,
        'receiverId': vendorId, // Using vendorId instead of empty string
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Batch write to ensure both operations succeed or fail together
      final batch = FirebaseFirestore.instance.batch();

      // Add message
      final messageRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc();
      batch.set(messageRef, messageData);

      // Update chat room
      final chatRoomRef =
          FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);
      batch.set(
          chatRoomRef,
          {
            'lastMessage': _messageController.text.trim(),
            'lastMessageTime': FieldValue.serverTimestamp(),
            'participants': [currentUserId, vendorId],
            'participantDetails': participantDetails,
          },
          SetOptions(merge: true));

      // Commit the batch
      await batch.commit();

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Get the chat room ID
    final vendorEmail = widget.vendorData['email'] as String? ?? '';
    final List<String> roomParticipants = [currentUserEmail ?? '', vendorEmail]
      ..sort();
    final String chatRoomId = roomParticipants.join('_');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vendorData['name'] as String? ?? 'Chat',
          style: const TextStyle(color: Colors.amber),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = messageData['senderId'] == currentUserId;
                    final message = messageData['message'] as String? ?? '';
                    final timestamp = messageData['timestamp'] as Timestamp?;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.amber : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message,
                                  style: TextStyle(
                                    color: isMe ? Colors.black : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timestamp != null
                                      ? _formatTimestamp(timestamp)
                                      : '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isMe ? Colors.black54 : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.amber,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final String hours = dateTime.hour.toString().padLeft(2, '0');
    final String minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.purple.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0, // Optional: Removes AppBar shadow for a cleaner look
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatRooms = snapshot.data!.docs;

          if (chatRooms.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
              final userDetails =
                  chatRoom['participantDetails'] as Map<String, dynamic>;

              // Get the other participant's details
              final otherParticipantId = (chatRoom['participants'] as List)
                  .firstWhere((id) => id != currentUserId);
              final otherParticipant = userDetails[otherParticipantId];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Text(
                    otherParticipant['name'][0].toUpperCase(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                title: Text(otherParticipant['name']),
                subtitle: Text(
                  chatRoom['lastMessage'] ?? 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  chatRoom['lastMessageTime'] != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                          chatRoom['lastMessageTime'].millisecondsSinceEpoch,
                        ).toString().substring(11, 16)
                      : '',
                ),
                onTap: () {
                  final vendorData = {
                    'vendorId': otherParticipantId,
                    'name': otherParticipant['name'],
                    'email': otherParticipant['email'],
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(vendorData: vendorData),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
