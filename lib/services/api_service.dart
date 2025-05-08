import 'dart:convert';
import 'package:http/http.dart' as http;
import 'setting_service.dart';
import '../services/setting_system.dart';
import '../models/message.dart';

enum AIEngine {
  chatgpt_4omini,
  chatgpt_4o,
  chatgpt_35turbo,
  gemini,
  claude35,
  claude37,
}

class ApiService {
  static AIEngine currentEngine = AIEngine.chatgpt_4omini;

  static const String openAIUrl = 'https://api.openai.com/v1/chat/completions';
  static const String geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';
  static const String claudeUrl = 'https://api.anthropic.com/v1/messages';
  static const String llamaUrl =
      'https://api.llama.com/compat/v1/chat/completions';

  static const String NAME_chatgpt_4omini = 'ChatGPT o4-mini';
  static const String NAME_chatgpt_4o = 'ChatGPT o4';
  static const String NAME_chatgpt_35turbo = 'ChatGPT 3.5-turbo';
  static const String NAME_gemini = 'Gemini 1.5 Pro';
  static const String NAME_claude35 = 'Claude 3.5 Haiku';
  static const String NAME_claude37 = 'Claude 3.7 Sonnet';

  static const String STR_chatgpt_4omini = 'chatgpt_4omini ';
  static const String STR_chatgpt_4o = 'chatgpt_4o';
  static const String STR_chatgpt_35turbo = 'chatgpt_35turbo';
  static const String STR_gemini = 'gemini';
  static const String STR_claude35 = 'claude35';
  static const String STR_claude37 = 'claude37';
  static int msgSendLength = 0;
  static int msgReceivedLength = 0;
  static String getModelName(AIEngine engine) {
    switch (engine) {
      case AIEngine.chatgpt_4omini:
        return NAME_chatgpt_4omini;
      case AIEngine.chatgpt_4o:
        return NAME_chatgpt_4o;
      case AIEngine.chatgpt_35turbo:
        return NAME_chatgpt_35turbo;
      case AIEngine.gemini:
        return NAME_gemini;
      case AIEngine.claude35:
        return NAME_claude35;
      case AIEngine.claude37:
        return NAME_claude37;
    }
  }

  static String getModelStr(AIEngine engine) {
    switch (engine) {
      case AIEngine.chatgpt_4omini:
        return STR_chatgpt_4omini;
      case AIEngine.chatgpt_4o:
        return STR_chatgpt_4o;
      case AIEngine.chatgpt_35turbo:
        return STR_chatgpt_35turbo;
      case AIEngine.gemini:
        return STR_gemini;
      case AIEngine.claude35:
        return STR_claude35;
      case AIEngine.claude37:
        return STR_claude37;
    }
  }

  static Future<String> sendMessage(String userInput) async {
    if (currentEngine == AIEngine.chatgpt_4omini) {
      return _sendToChatGPT_4omini(userInput);
    } else if (currentEngine == AIEngine.chatgpt_4o) {
      return _sendToChatGPT_4o(userInput);
    } else if (currentEngine == AIEngine.chatgpt_35turbo) {
      return _sendToChatGPT_35turbo(userInput);
    } else if (currentEngine == AIEngine.gemini) {
      return _sendToGemini(userInput);
    } else if (currentEngine == AIEngine.claude35) {
      return _sendToClaude('claude-3-5-haiku-20241022', userInput);
    } else if (currentEngine == AIEngine.claude37) {
      return _sendToClaude('claude-3-7-sonnet-20250219', userInput);
    } else {
      return 'This model does not support history yet.';
    }
  }

  static Future<String> sendMessageWithHistory(List<Message> messages) async {
    if (currentEngine == AIEngine.chatgpt_4omini) {
      return _sendToChatGPTWithHistory("gpt-4o-mini", messages);
    } else if (currentEngine == AIEngine.chatgpt_4o) {
      return _sendToChatGPTWithHistory("gpt-4o", messages);
    } else if (currentEngine == AIEngine.chatgpt_35turbo) {
      return _sendToChatGPTWithHistory("gpt-3.5-turbo", messages);
    } else if (currentEngine == AIEngine.gemini) {
      return _sendToGeminiWithHistory(messages);
    } else if (currentEngine == AIEngine.claude35) {
      return _sendToClaudeWithHistory('claude-3-5-haiku-20241022', messages);
    } else if (currentEngine == AIEngine.claude37) {
      return _sendToClaudeWithHistory('claude-3-7-sonnet-20250219', messages);
    } else {
      return 'This model does not support history yet.';
    }
  }

  static Future<String> sendMessageWeb(String userInput) async {
    if (currentEngine == AIEngine.claude35) {
      return _sendToClaudeWeb('claude-3-5-haiku-20241022', userInput);
    } else if (currentEngine == AIEngine.claude37) {
      return _sendToClaudeWeb('claude-3-7-sonnet-20250219', userInput);
    } else {
      return 'This model does not support history yet.';
    }
  }

  static Future<String> sendMessageWithHistoryWeb(
      List<Message> messages) async {
    if (currentEngine == AIEngine.claude35) {
      return _sendToClaudeWithHistoryWeb('claude-3-5-haiku-20241022', messages);
    } else if (currentEngine == AIEngine.claude37) {
      return _sendToClaudeWithHistoryWeb(
          'claude-3-7-sonnet-20250219', messages);
    } else {
      return 'This model does not support history yet.';
    }
  }

  static Future<String> _sendToChatGPTWithHistory(
      String model, List<Message> messages) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    try {
      String systemPrompt = await SystemService.loadSystem();
      final apiKey = await SettingService.loadApiKey(currentEngine);

      final chatMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
      ];
      final sendJson = jsonEncode({
        "model": model,
        "messages": chatMessages,
        "temperature": 0.7,
      });
      msgSendLength = sendJson.length;

      final response = await http.post(
        Uri.parse(openAIUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        final reply = data['choices'][0]['message']['content'];
        return reply.trim();
      } else {
        print('ChatGPT API error: ${response.body}');
        return 'Sorry, ChatGPT did not respond.';
      }
    } catch (e) {
      print('ChatGPT API error: $e');
      return 'ChatGPT Error occurred.';
    }
  }

  static Future<String> _sendToGeminiWithHistory(List<Message> messages) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    try {
      final apiKey = await SettingService.loadApiKey(AIEngine.gemini);
      final systemPrompt = await SystemService.loadSystem();

      final userHistory = [
        {"text": systemPrompt},
        ...messages.map((m) => {"text": "${m.role}: ${m.content}"})
      ];

      final sendJson = jsonEncode({
        "contents": [
          {
            "parts": userHistory,
          }
        ]
      });
      msgSendLength = sendJson.length;
      final response = await http.post(
        Uri.parse('$geminiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        msgReceivedLength = response.body.length;
        final reply = data['candidates'][0]['content']['parts'][0]['text'];
        return reply.trim();
      } else {
        print('Gemini API error: ${response.body}');
        return 'Sorry, Gemini did not respond.';
      }
    } catch (e) {
      print('Gemini API error: $e');
      return 'Gemini Error occurred.';
    }
  }

  static Future<String> _sendToClaudeWithHistory(
      String model, List<Message> messages) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    try {
      final apiKey =
          await SettingService.loadApiKey(AIEngine.claude35); // or claude37
      final systemPrompt = await SystemService.loadSystem();

      final chatMessages = [
        {'role': 'user', 'content': systemPrompt},
        ...messages.map((m) => {"role": m.role, "content": m.content}).toList(),
      ];

      final sendJson = jsonEncode({
        'model': model,
        'messages': chatMessages,
        'max_tokens': 1000,
        'temperature': 0.7,
      });
      msgSendLength = sendJson.length;

      final response = await http.post(
        Uri.parse('$claudeUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        final content = json['content'];
        if (content is List && content.isNotEmpty) {
          return content.first['text'] ?? '(no response)';
        }
        return '(empty response)';
      } else {
        print('Claude API error: ${response.body}');
        return '[Error ${response.statusCode}]: ${response.body}';
      }
    } catch (e) {
      print('Claude API error: $e');
      return 'Claude Error occurred.';
    }
  }

  static Future<String> _sendToClaudeWithHistoryWeb(
      String model, List<Message> messages) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    try {
      final apiKey = await SettingService.loadApiKey(currentEngine);
      final systemPrompt = await SystemService.loadSystem();

      final chatMessages = [
        {'role': 'user', 'content': systemPrompt},
        ...messages.map((m) => {"role": m.role, "content": m.content}).toList(),
      ];

      final sendJson = jsonEncode({
        'model': model,
        'messages': chatMessages,
        'max_tokens': 1000,
        'temperature': 0.7,
        "tools": [
          {
            "type": "web_search_20250305",
            "name": "web_search",
            "max_uses": 5,
          }
        ]
      });
      msgSendLength = sendJson.length;

      final response = await http.post(
        Uri.parse('$claudeUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;

        // Handle the new response structurenew response structure
        if (json.containsKey('content') && json['content'] is List) {
          final contentList = json['content'] as List;
          final StringBuilder responseText = StringBuilder();

          for (var item in contentList) {
            if (item['type'] == 'text') {
              responseText.write(item['text']);

              // Handle citations if presentif present
              if (item.containsKey('citations') && item['citations'] is List) {
                // Optional: Format citations as you prefer
                // This example appends footnote-style references
                final citations = item['citations'] as List;
                if (citations.isNotEmpty) {
                  responseText.write(' [');
                  for (int i = 0; i < citations.length; i++) {
                    if (i > 0) responseText.write(', ');
                    final citation = citations[i];
                    if (citation.containsKey('url') &&
                        citation.containsKey('title')) {
                      responseText.write('${citation['title']}');
                    }
                  }
                  responseText.write(']');
                }
              }
              responseText.write('\n');
            } else if (item['type'] == 'web_search_tool_result') {
              // Optionally include information about the search
              responseText.write('\n[Web search performed]\n');
            } else if (item['type'] == 'server_tool_use' &&
                item['name'] == 'web_search') {
              // Optionally include the search query
              responseText
                  .write('\n[Searching for: ${item['input']['query']}]\n');
            }
          }

          return responseText.toString().trim();
        }
        return '(empty or invalid response structure)';
      } else {
        print('Claude API error: ${response.body}');
        return '[Error ${response.statusCode}]: ${response.body}';
      }
    } catch (e) {
      print('Claude API error: $e');
      return 'Claude Error occurred.';
    }
  }

  static Future<String> _sendToChatGPT_4omini(String userInput) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    final model = "gpt-4o-mini";
    try {
      String systemPrompt = await SystemService.loadSystem();
      final apiKey = await SettingService.loadApiKey(AIEngine.chatgpt_4omini);

      final sendJson = jsonEncode({
        "model": model,
        "messages": [
          {'role': 'system', 'content': systemPrompt},
          {"role": "user", "content": userInput}
        ],
        "temperature": 0.7,
      });
      msgSendLength = sendJson.length;
      final response = await http.post(
        Uri.parse(openAIUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        final reply = data['choices'][0]['message']['content'];
        return reply.trim();
      } else {
        print('ChatGPT API error: ${response.body}');
        return 'Sorry, ChatGPT did not respond.';
      }
    } catch (e) {
      print('ChatGPT API error: $e');
      return 'ChatGPT Error occurred.';
    }
  }

  static Future<String> _sendToChatGPT_4o(String userInput) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    final model = "gpt-4o";
    try {
      String systemPrompt = await SystemService.loadSystem();
      final apiKey = await SettingService.loadApiKey(AIEngine.chatgpt_4o);

      final sendJson = jsonEncode({
        "model": model,
        "messages": [
          {'role': 'system', 'content': systemPrompt},
          {"role": "user", "content": userInput}
        ],
        "temperature": 0.7,
      });
      msgSendLength = sendJson.length;
      final response = await http.post(
        Uri.parse(openAIUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        final reply = data['choices'][0]['message']['content'];
        return reply.trim();
      } else {
        print('ChatGPT API error: ${response.body}');
        return 'Sorry, ChatGPT did not respond.';
      }
    } catch (e) {
      print('ChatGPT API error: $e');
      return 'ChatGPT Error occurred.';
    }
  }

  static Future<String> _sendToChatGPT_35turbo(String userInput) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    final model = "gpt-3.5-turbo";
    try {
      String systemPrompt = await SystemService.loadSystem();
      final apiKey = await SettingService.loadApiKey(AIEngine.chatgpt_35turbo);

      final sendJson = jsonEncode({
        "model": model,
        "messages": [
          {'role': 'system', 'content': systemPrompt},
          {"role": "user", "content": userInput}
        ],
        "temperature": 0.7,
      });
      msgSendLength = sendJson.length;
      final response = await http.post(
        Uri.parse(openAIUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        final reply = data['choices'][0]['message']['content'];
        return reply.trim();
      } else {
        print('ChatGPT API error: ${response.body}');
        return 'Sorry, ChatGPT did not respond.';
      }
    } catch (e) {
      print('ChatGPT API error: $e');
      return 'ChatGPT Error occurred.';
    }
  }

  static Future<String> _sendToGemini(String userInput) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    try {
      String systemPrompt = await SystemService.loadSystem();
      final apiKey = await SettingService.loadApiKey(AIEngine.gemini);

      final sendJson = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": systemPrompt},
              {"text": userInput}
            ]
          }
        ]
      });
      msgSendLength = sendJson.length;
      final response = await http.post(
        Uri.parse('$geminiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        msgReceivedLength = response.body.length;
        final reply = data['candidates'][0]['content']['parts'][0]['text'];
        return reply.trim();
      } else {
        print('Gemini API error: ${response.body}');
        return 'Sorry, Gemini did not respond.';
      }
    } catch (e) {
      print('Gemini API error: $e');
      return 'Gemini Error occurred.';
    }
  }

  static Future<String> _sendToClaude(String model, String userInput) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    try {
      String systemPrompt = await SystemService.loadSystem();
      final apiKey = await SettingService.loadApiKey(AIEngine.claude35);

      final sendJson = jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': systemPrompt},
          {'role': 'user', 'content': userInput}
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      });
      msgSendLength = sendJson.length;
      final response = await http.post(
        Uri.parse('$claudeUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        final content = json['content'];
        if (content is List && content.isNotEmpty) {
          return content.first['text'] ?? '(no response)';
        }
        return '(empty response)';
      } else {
        return '[Error ${response.statusCode}]: ${response.body}';
      }
    } catch (e) {
      print('Claude API error: $e');
      return 'Claude Error occurred.';
    }
  }

  static Future<String> _sendToClaudeWeb(String model, String userInput) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    try {
      String systemPrompt = await SystemService.loadSystem();
      final apiKey = await SettingService.loadApiKey(AIEngine.claude35);

      final sendJson = jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': systemPrompt},
          {'role': 'user', 'content': userInput}
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
        "tools": [
          {
            "type": "web_search_20250305",
            "name": "web_search",
            "max_uses": 5,
          }
        ],
      });
      msgSendLength = sendJson.length;
      final response = await http.post(
        Uri.parse('$claudeUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;

        // Handle the new response structurenew response structure
        if (json.containsKey('content') && json['content'] is List) {
          final contentList = json['content'] as List;
          final StringBuilder responseText = StringBuilder();

          for (var item in contentList) {
            if (item['type'] == 'text') {
              responseText.write(item['text']);

              // Handle citations if presentif present
              if (item.containsKey('citations') && item['citations'] is List) {
                // Optional: Format citations as you prefer
                // This example appends footnote-style references
                final citations = item['citations'] as List;
                if (citations.isNotEmpty) {
                  responseText.write(' [');
                  for (int i = 0; i < citations.length; i++) {
                    if (i > 0) responseText.write(', ');
                    final citation = citations[i];
                    if (citation.containsKey('url') &&
                        citation.containsKey('title')) {
                      responseText.write('${citation['title']}');
                    }
                  }
                  responseText.write(']');
                }
              }
              responseText.write('\n');
            } else if (item['type'] == 'web_search_tool_result') {
              // Optionally include information about the search
              responseText.write('\n[Web search performed]\n');
            } else if (item['type'] == 'server_tool_use' &&
                item['name'] == 'web_search') {
              // Optionally include the search query
              responseText
                  .write('\n[Searching for: ${item['input']['query']}]\n');
            }
          }

          return responseText.toString().trim();
        }
        return '(empty or invalid response structure)';
      } else {
        print('Claude API error: ${response.body}');
        return '[Error ${response.statusCode}]: ${response.body}';
      }
    } catch (e) {
      print('Claude API error: $e');
      return 'Claude Error occurred.';
    }
  }

  static Future<String> _sendToLlama32(String userInput) async {
    try {
      const model = 'llama3.2-3b';
      final apiKey = 'xxxxx';

      final response = await http.post(
        Uri.parse(llamaUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "Llama-4-Maverick-17B-128E-Instruct-FP8",
          "messages": [
            {"role": "user", "content": "Which planet do humans live on?"}
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final choices = json['choices'];
        if (choices is List && choices.isNotEmpty) {
          final content = choices.first['message']['content'];
          return content ?? '(no response)';
        }
        return '(empty response)';
      } else {
        return '[Error ${response.statusCode}]: ${response.body}';
      }
    } catch (e) {
      print('Claude API error: $e');
      return 'Claude Error occurred.';
    }
  }
}

class StringBuilder {
  final StringBuffer _buffer = StringBuffer();

  void write(String? text) {
    if (text != null) {
      _buffer.write(text);
    }
  }

  void writeln(String? text) {
    if (text != null) {
      _buffer.writeln(text);
    }
  }

  @override
  String toString() {
    return _buffer.toString();
  }

  void clear() {
    _buffer.clear();
  }
}
