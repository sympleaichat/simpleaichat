import 'dart:convert';
import 'package:http/http.dart' as http;
import 'setting_service.dart';

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
      return _sendToClaude35(userInput);
    } else if (currentEngine == AIEngine.claude37) {
      return _sendToClaude37(userInput);
    } else {
      return _sendToChatGPT_4omini(userInput);
    }
  }

  static Future<String> _sendToChatGPT_4omini(String userInput) async {
    try {
      final apiKey = await SettingService.loadApiKey(AIEngine.chatgpt_4omini);
      final response = await http.post(
        Uri.parse(openAIUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {"role": "user", "content": userInput}
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
    try {
      final apiKey = await SettingService.loadApiKey(AIEngine.chatgpt_4o);
      final response = await http.post(
        Uri.parse(openAIUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o",
          "messages": [
            {"role": "user", "content": userInput}
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
    try {
      final apiKey = await SettingService.loadApiKey(AIEngine.chatgpt_35turbo);
      final response = await http.post(
        Uri.parse(openAIUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": userInput}
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
    try {
      final apiKey = await SettingService.loadApiKey(AIEngine.gemini);
      final response = await http.post(
        Uri.parse('$geminiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userInput}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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

  static Future<String> _sendToClaude35(String userInput) async {
    try {
      const model = 'claude-3-5-haiku-20241022';
      final apiKey = await SettingService.loadApiKey(AIEngine.claude35);
      final response = await http.post(
        Uri.parse('$claudeUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': userInput}
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
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

  static Future<String> _sendToClaude37(String userInput) async {
    try {
      const model = 'claude-3-7-sonnet-20250219';
      final apiKey = await SettingService.loadApiKey(AIEngine.claude35);
      final response = await http.post(
        Uri.parse('$claudeUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': userInput}
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
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
