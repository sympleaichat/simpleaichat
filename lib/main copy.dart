import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Chat Client',
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('api_key');
    });
    if (_apiKey == null) {
      _promptForApiKey();
    }
  }

  Future<void> _promptForApiKey() async {
    final keyController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter API Key'),
        content: TextField(controller: keyController),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('api_key', keyController.text.trim());
              setState(() {
                _apiKey = keyController.text.trim();
              });
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    //await _sendMessageOpenAI();
    await _sendMessageGemini();
  }

  Future<void> _sendMessageGemini() async {
    final userInput = _controller.text.trim();
    if (userInput.isEmpty || _apiKey == null) return;

    setState(() {
      _messages.add({'role': 'user', 'content': userInput});
      _controller.clear();
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "role": "user", // v1では"role"も必要
              "parts": [
                {"text": userInput}
              ]
            }
          ]
        }),
      );
      print("response.statusCode " + response.statusCode.toString());
      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);
        final candidates = data['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'];
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'];
            // return text;

            setState(() {
              _messages.add({'role': 'assistant', 'content': text});
            });
            return;
          }
        }
        throw Exception('Unexpected response structure: $data');
      } else {
        throw Exception('Gemini API Error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Error: $e'});
      });
    }
  }

  Future<void> _sendMessageOpenAI() async {
    final userInput = _controller.text.trim();
    if (userInput.isEmpty || _apiKey == null) return;

    setState(() {
      _messages.add({'role': 'user', 'content': userInput});
      _controller.clear();
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": _messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiReply = data['choices'][0]['message']['content'];
        setState(() {
          _messages.add({'role': 'assistant', 'content': aiReply});
        });
      } else {
        setState(() {
          _messages
              .add({'role': 'assistant', 'content': 'Error: ${response.body}'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Error: $e'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Chat Client'),
        actions: [
          IconButton(
            icon: Icon(Icons.vpn_key),
            onPressed: _promptForApiKey,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return ListTile(
                  title: Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(message['content'] ?? ''),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Type a message'),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
