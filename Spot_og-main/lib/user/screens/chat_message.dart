class ChatMessage {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final String senderName;
  final String? imageUrl;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.senderName,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'senderName': senderName,
      'imageUrl': imageUrl,
    };
  }
}
