import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Client')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text("${message.role}: ${message.content}"),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final userInput = _controller.text.trim();
                    if (userInput.isEmpty) return;
                    setState(() {
                      _messages.add(Message(role: "user", content: userInput));
                    });
                    _controller.clear();
                    final aiReply = await ApiService.sendMessage(userInput);
                    setState(() {
                      _messages
                          .add(Message(role: "assistant", content: aiReply));
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
