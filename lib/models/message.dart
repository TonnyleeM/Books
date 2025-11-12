class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    DateTime timestamp;
    try {
      final timestampData = map['timestamp'];
      if (timestampData != null) {
        if (timestampData.runtimeType.toString().contains('Timestamp')) {
          timestamp = timestampData.toDate();
        } else if (timestampData is int) {
          timestamp = DateTime.fromMillisecondsSinceEpoch(timestampData);
        } else {
          timestamp = DateTime.now();
        }
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      timestamp = DateTime.now();
    }
    
    return Message(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: timestamp,
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}