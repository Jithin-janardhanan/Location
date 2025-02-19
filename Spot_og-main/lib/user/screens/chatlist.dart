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
// Helper function to format time
    String _formatTime(DateTime time) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(time.year, time.month, time.day);

      if (messageDate == today) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else if (messageDate == yesterday) {
        return 'Yesterday';
      } else {
        return '${time.day}/${time.month}/${time.year}';
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.amber),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            );
          }

          final chatRooms = snapshot.data!.docs;

          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with vendors',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
              final userDetails =
                  chatRoom['participantDetails'] as Map<String, dynamic>;
              final otherParticipantId = (chatRoom['participants'] as List)
                  .firstWhere((id) => id != currentUserId);
              final otherParticipant = userDetails[otherParticipantId];
              final lastMessageTime = chatRoom['lastMessageTime'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      chatRoom['lastMessageTime'].millisecondsSinceEpoch)
                  : null;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      final vendorData = {
                        'vendorId': otherParticipantId,
                        'name': otherParticipant['name'],
                        'email': otherParticipant['email'],
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(vendorData: vendorData),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.amber,
                                  child: Text(
                                    otherParticipant['name'][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Online status indicator could be added here
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      otherParticipant['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (lastMessageTime != null)
                                      Text(
                                        _formatTime(lastMessageTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  chatRoom['lastMessage'] ?? 'No messages yet',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
