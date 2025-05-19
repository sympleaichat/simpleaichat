import 'dart:convert';
import 'package:http/http.dart' as http;
import 'setting_service.dart';
import '../services/setting_system.dart';
import '../models/message.dart';
import '../utils/logger.dart';

enum AIEngine {
  chatgpt_41,
  chatgpt_4omini,
  chatgpt_4o,
  chatgpt_35turbo,
  chatgpt_4turbo,
  gpt4,
  chatgpt_davinci002,
  gemini,
  claude35,
  claude37,
  grok_3,
  grok_3mini,
}

class ApiService {
  static AIEngine currentEngine = AIEngine.chatgpt_4omini;

  static const String openAIUrl = 'https://api.openai.com/v1/chat/completions';
  static const String openAIUrlLegacy = 'https://api.openai.com/v1/completions';
  static const String geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';
  static const String claudeUrl = 'https://api.anthropic.com/v1/messages';
  static const String grokUrl = 'https://api.x.ai/v1/messages';
  static const String llamaUrl =
      'https://api.llama.com/compat/v1/chat/completions';

  static const String NAME_chatgpt_41 = 'ChatGPT 4.1';
  static const String NAME_chatgpt_4omini = 'ChatGPT o4-mini';
  static const String NAME_chatgpt_4o = 'ChatGPT o4';
  static const String NAME_chatgpt_35turbo = 'ChatGPT 3.5-turbo';
  static const String NAME_chatgpt_4turbo = 'ChatGPT 4-turbo';
  static const String NAME_chatgpt_4 = 'ChatGPT 4';
  static const String NAME_chatgpt_davinci002 = 'ChatGPT davinci002';
  static const String NAME_gemini = 'Gemini 1.5 Pro';
  static const String NAME_claude35 = 'Claude 3.5 Haiku';
  static const String NAME_claude37 = 'Claude 3.7 Sonnet';
  static const String NAME_grok_3 = 'Grok 3';
  static const String NAME_grok_3mini = 'Grok 3 Mini';

  static const String STR_chatgpt_41 = 'chatgpt_41';
  static const String STR_chatgpt_4omini = 'chatgpt_4omini';
  static const String STR_chatgpt_4o = 'chatgpt_4o';
  static const String STR_chatgpt_35turbo = 'chatgpt_35turbo';
  static const String STR_chatgpt_4turbo = 'chatgpt_4turbo';
  static const String STR_chatgpt_4 = 'chatgpt_4';
  static const String STR_chatgpt_davinci002 = 'chatgpt_davinci002';
  static const String STR_gemini = 'gemini';
  static const String STR_claude35 = 'claude35';
  static const String STR_claude37 = 'claude37';
  static const String STR_grok3 = 'grok3';
  static const String STR_grok3mini = 'grok3mini';

  static int msgSendLength = 0;
  static int msgReceivedLength = 0;
  static String msgModel = '';
  static String getModelName(AIEngine engine) {
    switch (engine) {
      case AIEngine.chatgpt_41:
        return NAME_chatgpt_41;
      case AIEngine.chatgpt_4omini:
        return NAME_chatgpt_4omini;
      case AIEngine.chatgpt_4o:
        return NAME_chatgpt_4o;
      case AIEngine.chatgpt_35turbo:
        return NAME_chatgpt_35turbo;
      case AIEngine.chatgpt_4turbo:
        return NAME_chatgpt_4turbo;
      case AIEngine.gpt4:
        return NAME_chatgpt_4;
      case AIEngine.chatgpt_davinci002:
        return NAME_chatgpt_davinci002;
      case AIEngine.gemini:
        return NAME_gemini;
      case AIEngine.claude35:
        return NAME_claude35;
      case AIEngine.claude37:
        return NAME_claude37;
      case AIEngine.grok_3:
        return NAME_grok_3;
      case AIEngine.grok_3mini:
        return NAME_grok_3mini;
    }
  }

  static String getModelStr(AIEngine engine) {
    switch (engine) {
      case AIEngine.chatgpt_41:
        return STR_chatgpt_41;
      case AIEngine.chatgpt_4omini:
        return STR_chatgpt_4omini;
      case AIEngine.chatgpt_4o:
        return STR_chatgpt_4o;
      case AIEngine.chatgpt_35turbo:
        return STR_chatgpt_35turbo;
      case AIEngine.chatgpt_4turbo:
        return STR_chatgpt_4turbo;
      case AIEngine.gpt4:
        return STR_chatgpt_4;
      case AIEngine.chatgpt_davinci002:
        return STR_chatgpt_davinci002;
      case AIEngine.gemini:
        return STR_gemini;
      case AIEngine.claude35:
        return STR_claude35;
      case AIEngine.claude37:
        return STR_claude37;
      case AIEngine.grok_3:
        return STR_grok3;
      case AIEngine.grok_3mini:
        return STR_grok3mini;
    }
  }

  static Future<String> sendMessage(String userInput, AIEngine model) async {
    final apiKey = await SettingService.loadApiKey(model);
    if (model == AIEngine.chatgpt_41) {
      return _sendToChatGPT("gpt-4.1", userInput, apiKey);
    } else if (model == AIEngine.chatgpt_4omini) {
      return _sendToChatGPT("gpt-4o", userInput, apiKey);
    } else if (model == AIEngine.chatgpt_4o) {
      return _sendToChatGPT("gpt-4o-mini", userInput, apiKey);
    } else if (model == AIEngine.chatgpt_35turbo) {
      return _sendToChatGPT("gpt-3.5-turbo", userInput, apiKey);
    } else if (model == AIEngine.chatgpt_4turbo) {
      return _sendToChatGPT("gpt-4-turbo", userInput, apiKey);
    } else if (model == AIEngine.gpt4) {
      return _sendToChatGPT("gpt-4", userInput, apiKey);
    } else if (model == AIEngine.chatgpt_davinci002) {
      return _sendToChatGPTLegacy("davinci-002", userInput, apiKey);
    } else if (model == AIEngine.gemini) {
      return _sendToGemini(userInput, apiKey);
    } else if (model == AIEngine.claude35) {
      return _sendToClaude('claude-3-5-haiku-20241022', userInput, apiKey);
    } else if (model == AIEngine.claude37) {
      return _sendToClaude('claude-3-7-sonnet-20250219', userInput, apiKey);
    } else if (model == AIEngine.grok_3) {
      return _sendToChatGrok('grok-3-beta', userInput, apiKey);
    } else if (model == AIEngine.grok_3mini) {
      return _sendToChatGrok('grok-3-mini-beta', userInput, apiKey);
    } else {
      return 'This model does not support Single mode yet.';
    }
  }

  static Future<String> sendMessageWithHistory(
      List<Message> messages, AIEngine model) async {
    final apiKey = await SettingService.loadApiKey(model);
    if (model == AIEngine.chatgpt_41) {
      return _sendToChatGPTWithHistory("gpt-4.1", messages, apiKey);
    } else if (model == AIEngine.chatgpt_4omini) {
      return _sendToChatGPTWithHistory("gpt-4o-mini", messages, apiKey);
    } else if (model == AIEngine.chatgpt_4o) {
      return _sendToChatGPTWithHistory("gpt-4o", messages, apiKey);
    } else if (model == AIEngine.chatgpt_35turbo) {
      return _sendToChatGPTWithHistory("gpt-3.5-turbo", messages, apiKey);
    } else if (model == AIEngine.chatgpt_4turbo) {
      return _sendToChatGPTWithHistory("gpt-4-turbo", messages, apiKey);
    } else if (model == AIEngine.gpt4) {
      return _sendToChatGPTWithHistory("gpt-4", messages, apiKey);
    } else if (model == AIEngine.chatgpt_davinci002) {
      return 'This model does not support thread messages.';
      //   return _sendToChatGPTWithHistoryLegacy("davinci-002", messages);
    } else if (model == AIEngine.gemini) {
      return _sendToGeminiWithHistory(messages, apiKey);
    } else if (model == AIEngine.claude35) {
      return _sendToClaudeWithHistory(
          'claude-3-5-haiku-20241022', messages, apiKey);
    } else if (model == AIEngine.claude37) {
      return _sendToClaudeWithHistory(
          'claude-3-7-sonnet-20250219', messages, apiKey);
    } else if (model == AIEngine.grok_3) {
      return _sendToGrokWithHistory("grok-3-beta", messages, apiKey);
    } else if (model == AIEngine.grok_3mini) {
      return _sendToGrokWithHistory("grok-3-mini-beta", messages, apiKey);
    } else {
      return 'This model does not support history yet.';
    }
  }

  static Future<String> sendMessageWeb(String userInput, AIEngine model) async {
    final apiKey = await SettingService.loadApiKey(model);
    if (model == AIEngine.claude35) {
      return _sendToClaudeWeb('claude-3-5-haiku-20241022', userInput, apiKey);
    } else if (model == AIEngine.claude37) {
      return _sendToClaudeWeb('claude-3-7-sonnet-20250219', userInput, apiKey);
    } else {
      return 'This model does not support history yet.';
    }
  }

  static Future<String> sendMessageWithHistoryWeb(
      List<Message> messages, AIEngine model) async {
    final apiKey = await SettingService.loadApiKey(model);
    if (model == AIEngine.claude35) {
      return _sendToClaudeWithHistoryWeb(
          'claude-3-5-haiku-20241022', messages, apiKey);
    } else if (model == AIEngine.claude37) {
      return _sendToClaudeWithHistoryWeb(
          'claude-3-7-sonnet-20250219', messages, apiKey);
    } else {
      return 'This model does not support history yet.';
    }
  }

  static Future<String> _sendToChatGPTWithHistory(
      String model, List<Message> messages, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
      String systemPrompt = await SystemService.loadSystem();

      final chatMessages = [
        //      {'role': 'system', 'content': systemPrompt},
        {'role': 'developer', 'content': systemPrompt},
        ...messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
      ];
      final sendJson = jsonEncode({
        "model": model,
        "messages": chatMessages,
        "temperature": 0.7,
      });
      msgModel = model;
      msgSendLength = sendJson.length;
      Logger.log(sendJson);
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

  static Future<String> _sendToChatGPTWithHistoryLegacy(
      String model, List<Message> messages, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
      String systemPrompt = await SystemService.loadSystem();

      final chatMessages = [
        //  {'role': 'system', 'content': systemPrompt},
        //  {'role': 'developer', 'content': systemPrompt},
        ...messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
      ];
      final sendJson = jsonEncode({
        "model": model,

        "prompt": chatMessages.join('\n'), // ここを文字列にする
        "temperature": 0.7,
        "max_tokens": 1000,
      });
      msgModel = model;
      msgSendLength = sendJson.length;
      Logger.log(sendJson);
      final response = await http.post(
        Uri.parse(openAIUrlLegacy),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        final reply = data['choices'][0]['text'];
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

  static Future<String> _sendToGeminiWithHistory(
      List<Message> messages, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
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

      Logger.log(sendJson);
      msgSendLength = sendJson.length;
      msgModel = 'Gemini';
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
      String model, List<Message> messages, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
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
      Logger.log(sendJson);
      msgSendLength = sendJson.length;
      msgModel = model;
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
      String model, List<Message> messages, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
      final systemPrompt = await SystemService.loadSystem();

      final chatMessages = [
        {'role': 'user', 'content': systemPrompt},
        ...messages.map((m) => {"role": m.role, "content": m.content}).toList(),
      ];

      final sendJson = jsonEncode({
        'model': model,
        'messages': chatMessages,
        'max_tokens': 10000,
        'temperature': 0.7,
        "tools": [
          {
            "type": "web_search_20250305",
            "name": "web_search",
            "max_uses": 5,
          }
        ]
      });
      Logger.log(sendJson);
      msgSendLength = sendJson.length;
      msgModel = model;
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

  static Future<String> _sendToGrokWithHistory(
      String model, List<Message> messages, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
      String systemPrompt = await SystemService.loadSystem();

      final chatMessages = [
        {'role': 'user', 'content': systemPrompt},
        ...messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
      ];
      final sendJson = jsonEncode({
        "model": model,
        "max_tokens": 2048,
        "messages": chatMessages,
        "temperature": 0.7,
      });
      msgModel = model;
      msgSendLength = sendJson.length;
      Logger.log(sendJson);
      final response = await http.post(
        Uri.parse(grokUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        String retStr = '';
        try {
          final reply = data['content'][0]['thinking'];
          retStr = reply.trim();
        } catch (e) {
          final reply = data['content'][0]['text'];
          retStr = reply.trim();
        }

        return retStr;
      } else {
        print('grok API error: ${response.body}');
        return 'Sorry, grok did not respond.';
      }
    } catch (e) {
      print('grok API error: $e');
      return 'grok Error occurred.';
    }
  }

  static Future<String> _sendToChatGPTLegacy(
      String model, String userInput, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';

    try {
      String systemPrompt = await SystemService.loadSystem();

      final chatMessages = [
        {"role": "user", "content": userInput}
      ];
      final sendJson = jsonEncode({
        "model": model,

        "prompt": chatMessages.join('\n'), // ここを文字列にする
        "temperature": 0.7,
        "max_tokens": 1000,
      });
      msgModel = model;
      msgSendLength = sendJson.length;
      Logger.log(sendJson);
      final response = await http.post(
        Uri.parse(openAIUrlLegacy),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        final reply = data['choices'][0]['text'];
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

  static Future<String> _sendToChatGPT(
      String model, String userInput, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';

    try {
      String systemPrompt = await SystemService.loadSystem();
      final sendJson = jsonEncode({
        "model": model,
        "messages": [
          //  {'role': 'system', 'content': systemPrompt},
          {'role': 'developer', 'content': systemPrompt},
          {"role": "user", "content": userInput}
        ],
        "temperature": 0.7,
      });
      Logger.log(sendJson);
      msgSendLength = sendJson.length;
      msgModel = model;
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

  static Future<String> _sendToGemini(String userInput, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
      String systemPrompt = await SystemService.loadSystem();

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
      Logger.log(sendJson);
      msgSendLength = sendJson.length;
      msgModel = 'gemini';
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

  static Future<String> _sendToClaude(
      String model, String userInput, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
      String systemPrompt = await SystemService.loadSystem();

      final sendJson = jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': systemPrompt},
          {'role': 'user', 'content': userInput}
        ],
        'max_tokens': 10000,
        'temperature': 0.7,
      });
      Logger.log(sendJson);
      msgSendLength = sendJson.length;
      msgModel = model;
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

  static Future<String> _sendToClaudeWeb(
      String model, String userInput, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
      String systemPrompt = await SystemService.loadSystem();

      final sendJson = jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': systemPrompt},
          {'role': 'user', 'content': userInput}
        ],
        'max_tokens': 10000,
        'temperature': 0.7,
        "tools": [
          {
            "type": "web_search_20250305",
            "name": "web_search",
            "max_uses": 5,
          }
        ],
      });
      Logger.log(sendJson);
      msgSendLength = sendJson.length;
      msgModel = model;
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

  static Future<String> _sendToChatGrok(
      String model, String userInput, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';

    try {
      String systemPrompt = await SystemService.loadSystem();

      final sendJson = jsonEncode({
        "model": model,
        "messages": [
          //  {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': systemPrompt},
          {"role": "user", "content": userInput}
        ],
        "max_tokens": 2048,
        "temperature": 0.7,
      });

      Logger.log(sendJson);
      msgSendLength = sendJson.length;
      msgModel = model;
      final response = await http.post(
        Uri.parse(grokUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        String retStr = '';
        try {
          final reply = data['content'][0]['thinking'];
          retStr = reply.trim();
        } catch (e) {
          final reply = data['content'][0]['text'];
          retStr = reply.trim();
        }
        return retStr;
      } else {
        print('Grok API error: ${response.body}');
        return 'Sorry, Grok did not respond.';
      }
    } catch (e) {
      print('Grok API error: $e');
      return 'Grok Error occurred.';
    }
  }

  static Future<String> _sendToLlama32(String userInput) async {
    try {
      const model = 'llama3.2-3b';
      final apiKey = 'xxxxx';
      msgModel = '';
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
