class Message {
  final String messageId;
  final String role;
  final String content;

  Message({
    required this.messageId,
    required this.role,
    required this.content,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'role': role,
      'content': content,
    };
  }

  // Create an object from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'],
      role: json['role'],
      content: json['content'],
    );
  }
}
