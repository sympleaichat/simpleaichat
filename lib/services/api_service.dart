import 'dart:io';
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
  gemini25flash,
  gemini25pro,
  gemini20flash,
  gemini15pro,
  claude41opus,
  claude40opus,
  claude40sonnet,
  claude35,
  claude37,
  grok_3,
  grok_3mini,
  grok_4,
  grok_3_fast,
  grok_3_fast_mini,
  deepseek_chat,
  deepseek_reasoner,
  mistral_large,
  mistral_medium,
  mistral_small,
}

class ApiService {
  static String? pdffilePath;
  static String? pdffileName;
  static AIEngine currentEngine = AIEngine.chatgpt_4omini;

  static const String openAIUrl = 'https://api.openai.com/v1/chat/completions';
  static const String openAIUrlLegacy = 'https://api.openai.com/v1/completions';
  static const String geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/';
  static const String geminiUrl2 =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';
  static const String claudeUrl = 'https://api.anthropic.com/v1/messages';
  static const String grokUrl = 'https://api.x.ai/v1/messages';
  static const String deepseekUrl = 'https://api.deepseek.com/chat/completions';
  static const String llamaUrl =
      'https://api.llama.com/compat/v1/chat/completions';
  static const String mistralUrl = 'https://api.mistral.ai/v1';

  static const String NAME_chatgpt_41 = 'ChatGPT 4.1';
  static const String NAME_chatgpt_4omini = 'ChatGPT o4-mini';
  static const String NAME_chatgpt_4o = 'ChatGPT o4';
  static const String NAME_chatgpt_35turbo = 'ChatGPT 3.5-turbo';
  static const String NAME_chatgpt_4turbo = 'ChatGPT 4-turbo';
  static const String NAME_chatgpt_4 = 'ChatGPT 4';
  static const String NAME_chatgpt_davinci002 = 'ChatGPT davinci002';
  static const String NAME_gemini25flash = 'Gemini 2.5 Flash';
  static const String NAME_gemini25pro = 'Gemini 2.5 Pro';
  static const String NAME_gemini20flash = 'Gemini 2.0 Flash';
  static const String NAME_gemini15pro = 'Gemini 1.5 Pro';
  static const String NAME_claude41opus = 'Claude Opus 4.1';
  static const String NAME_claude40opus = 'Claude Opus 4';
  static const String NAME_claude40sonnet = 'Claude Sonnet 4';
  static const String NAME_claude35 = 'Claude 3.5 Haiku';
  static const String NAME_claude37 = 'Claude 3.7 Sonnet';
  static const String NAME_grok_3 = 'Grok 3';
  static const String NAME_grok_3mini = 'Grok 3 Mini';
  static const String NAME_grok4 = 'Grok 4';
  static const String NAME_grok3_fast = 'Grok 3 fast';
  static const String NAME_grok3_fast_mini = 'Grok 3 Mini fast';
  static const String NAME_deepseek_chat = 'deepseek-chat';
  static const String NAME_deepseek_reasoner = 'deepseek-reasoner';
  static const String NAME_mistral_large = 'Mistral Large';
  static const String NAME_mistral_medium = 'Mistral Medium';
  static const String NAME_mistral_small = 'Mistral Small';

  static const String STR_chatgpt_41 = "gpt-4.1";
  static const String STR_chatgpt_4omini = "gpt-4o-mini";
  static const String STR_chatgpt_4omini_web = "gpt-4o-mini-search-preview";
  static const String STR_chatgpt_4o = "gpt-4o";
  static const String STR_chatgpt_4o_web = "gpt-4o-search-preview";
  static const String STR_chatgpt_35turbo = "gpt-3.5-turbo";
  static const String STR_chatgpt_4turbo = "gpt-4-turbo";
  static const String STR_chatgpt_4 = "gpt-4";
  static const String STR_chatgpt_davinci002 = "davinci-002";
  static const String STR_gemini25flash = 'gemini-2.5-flash-preview-05-20';
  static const String STR_gemini25pro = 'gemini-2.5-pro-preview-05-06';
  static const String STR_gemini20flash = 'gemini-2.0-flash';
  static const String STR_gemini15pro = 'gemini-1.5-pro';
  static const String STR_claude41opus = 'claude-opus-4-1';
  static const String STR_claude40opus = 'claude-opus-4-0';
  static const String STR_claude40sonnet = 'claude-sonnet-4-0';
  static const String STR_claude35 = 'claude-3-5-haiku-latest';
  static const String STR_claude37 = 'claude-3-7-sonnet-latest';
  static const String STR_grok4 = 'grok-4';
  static const String STR_grok3_fast = 'grok-3-fast';
  static const String STR_grok3_fast_mini = 'grok-3-mini-fast';
  static const String STR_grok3 = 'grok-3';
  static const String STR_grok3mini = 'grok-3-mini';
  static const String STR_deepseek_chat = 'deepseek-chat';
  static const String STR_deepseek_reasoner = 'deepseek-reasoner';
  static const String STR_mistral_large = 'mistral-large-latest';
  static const String STR_mistral_medium = 'mistral-medium-latest';
  static const String STR_mistral_small = 'mistral-small-latest';

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
      case AIEngine.gemini25flash:
        return NAME_gemini25flash;
      case AIEngine.gemini25pro:
        return NAME_gemini25pro;
      case AIEngine.gemini20flash:
        return NAME_gemini20flash;
      case AIEngine.gemini15pro:
        return NAME_gemini15pro;
      case AIEngine.claude41opus:
        return NAME_claude41opus;
      case AIEngine.claude40opus:
        return NAME_claude40opus;
      case AIEngine.claude40sonnet:
        return NAME_claude40sonnet;
      case AIEngine.claude35:
        return NAME_claude35;
      case AIEngine.claude37:
        return NAME_claude37;
      case AIEngine.grok_3:
        return NAME_grok_3;
      case AIEngine.grok_3mini:
        return NAME_grok_3mini;
      case AIEngine.grok_4:
        return NAME_grok4;
      case AIEngine.grok_3_fast:
        return NAME_grok3_fast;
      case AIEngine.grok_3_fast_mini:
        return NAME_grok3_fast_mini;
      case AIEngine.deepseek_chat:
        return NAME_deepseek_chat;
      case AIEngine.deepseek_reasoner:
        return NAME_deepseek_reasoner;
      case AIEngine.mistral_large:
        return NAME_mistral_large;
      case AIEngine.mistral_medium:
        return NAME_mistral_medium;
      case AIEngine.mistral_small:
        return NAME_mistral_small;
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
      case AIEngine.gemini25flash:
        return STR_gemini25flash;
      case AIEngine.gemini25pro:
        return STR_gemini25pro;
      case AIEngine.gemini20flash:
        return STR_gemini20flash;
      case AIEngine.gemini15pro:
        return STR_gemini15pro;
      case AIEngine.claude41opus:
        return STR_claude41opus;
      case AIEngine.claude40opus:
        return STR_claude40opus;
      case AIEngine.claude40sonnet:
        return STR_claude40sonnet;
      case AIEngine.claude35:
        return STR_claude35;
      case AIEngine.claude37:
        return STR_claude37;
      case AIEngine.grok_3:
        return STR_grok3;
      case AIEngine.grok_3mini:
        return STR_grok3mini;
      case AIEngine.grok_4:
        return STR_grok4;
      case AIEngine.grok_3_fast:
        return STR_grok3_fast;
      case AIEngine.grok_3_fast_mini:
        return STR_grok3_fast_mini;
      case AIEngine.deepseek_chat:
        return STR_deepseek_chat;
      case AIEngine.deepseek_reasoner:
        return STR_deepseek_reasoner;
      case AIEngine.mistral_large:
        return STR_mistral_large;
      case AIEngine.mistral_medium:
        return STR_mistral_medium;
      case AIEngine.mistral_small:
        return STR_mistral_small;
    }
  }

  static Future<String> sendMessage(String userInput, AIEngine model) async {
    final modelStr = getModelStr(model);
    final apiKey = await SettingService.loadApiKey(model);

    switch (model) {
      case AIEngine.chatgpt_41:
      case AIEngine.chatgpt_4omini:
      case AIEngine.chatgpt_4o:
      case AIEngine.chatgpt_35turbo:
      case AIEngine.chatgpt_4turbo:
      case AIEngine.gpt4:
        return _sendToChatGPT(modelStr, userInput, apiKey);
      case AIEngine.chatgpt_davinci002:
        return _sendToChatGPTLegacy(modelStr, userInput, apiKey);
      case AIEngine.gemini25flash:
      case AIEngine.gemini25pro:
      case AIEngine.gemini20flash:
      case AIEngine.gemini15pro:
        return _sendToGemini(modelStr, userInput, apiKey);
      case AIEngine.claude41opus:
      case AIEngine.claude40opus:
      case AIEngine.claude40sonnet:
      case AIEngine.claude35:
      case AIEngine.claude37:
        return _sendToClaude(modelStr, userInput, apiKey);
      case AIEngine.grok_3:
      case AIEngine.grok_3mini:
      case AIEngine.grok_3_fast:
      case AIEngine.grok_3_fast_mini:
        return _sendToChatGrok(modelStr, userInput, apiKey);
      case AIEngine.grok_4:
        return _sendToChatGrok4(modelStr, userInput, apiKey);

      case AIEngine.deepseek_chat:
      case AIEngine.deepseek_reasoner:
        return _sendToChatDeepSeek(modelStr, userInput, apiKey);
      case AIEngine.mistral_large:
      case AIEngine.mistral_medium:
      case AIEngine.mistral_small:
        return _sendToChatMistral(modelStr, userInput, apiKey);
    }
  }

  static Future<String> sendMessageWithHistory(
      List<Message> messages, AIEngine model) async {
    final modelStr = getModelStr(model);
    final apiKey = await SettingService.loadApiKey(model);

    switch (model) {
      case AIEngine.chatgpt_41:
      case AIEngine.chatgpt_4omini:
      case AIEngine.chatgpt_4o:
      case AIEngine.chatgpt_35turbo:
      case AIEngine.chatgpt_4turbo:
      case AIEngine.gpt4:
        return _sendToChatGPTWithHistory(modelStr, messages, apiKey);
      case AIEngine.chatgpt_davinci002:
        return 'This model does not support thread messages.';
      case AIEngine.gemini25flash:
      case AIEngine.gemini25pro:
      case AIEngine.gemini20flash:
      case AIEngine.gemini15pro:
        return _sendToGeminiWithHistory(modelStr, messages, apiKey);
      case AIEngine.claude41opus:
      case AIEngine.claude40opus:
      case AIEngine.claude40sonnet:
      case AIEngine.claude35:
      case AIEngine.claude37:
        return _sendToClaudeWithHistory(modelStr, messages, apiKey);
      case AIEngine.grok_3:
      case AIEngine.grok_3mini:
      case AIEngine.grok_3_fast:
      case AIEngine.grok_3_fast_mini:
        return _sendToGrokWithHistory(modelStr, messages, apiKey);
      case AIEngine.grok_4:
        return _sendToGrok4WithHistory(modelStr, messages, apiKey);

      case AIEngine.deepseek_chat:
      case AIEngine.deepseek_reasoner:
        return _sendToDeepSeekWithHistory(modelStr, messages, apiKey);
      case AIEngine.mistral_large:
      case AIEngine.mistral_medium:
      case AIEngine.mistral_small:
        return _sendToMistralWithHistory(modelStr, messages, apiKey);
    }
  }

  static Future<String> sendMessageWeb(String userInput, AIEngine model) async {
    final modelStr = getModelStr(model);
    final apiKey = await SettingService.loadApiKey(model);
    if (model == AIEngine.chatgpt_4omini) {
      return _sendToChatGPTWeb(STR_chatgpt_4omini_web, userInput, apiKey);
    } else if (model == AIEngine.chatgpt_4o) {
      return _sendToChatGPTWeb(STR_chatgpt_4o_web, userInput, apiKey);
    } else if (model == AIEngine.claude35 ||
        model == AIEngine.claude37 ||
        model == AIEngine.claude40opus ||
        model == AIEngine.claude40sonnet) {
      return _sendToClaudeWeb(modelStr, userInput, apiKey);
    } else {
      return 'This model does not support history yet.';
    }
  }

  static Future<String> sendMessageWithHistoryWeb(
      List<Message> messages, AIEngine model) async {
    final modelStr = getModelStr(model);
    final apiKey = await SettingService.loadApiKey(model);
    if (model == AIEngine.chatgpt_4omini) {
      return _sendToChatGPTWithHistoryWeb(
          STR_chatgpt_4omini_web, messages, apiKey);
    } else if (model == AIEngine.chatgpt_4o) {
      return _sendToChatGPTWithHistoryWeb(STR_chatgpt_4o_web, messages, apiKey);
    } else if (model == AIEngine.claude35 ||
        model == AIEngine.claude37 ||
        model == AIEngine.claude40opus ||
        model == AIEngine.claude40sonnet) {
      return _sendToClaudeWithHistoryWeb(modelStr, messages, apiKey);
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

  static Future<String> _sendToChatGPTWithHistoryWeb(
      String model, List<Message> messages, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
      String systemPrompt = await SystemService.loadSystem();

      final chatMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
      ];
      final sendJson = jsonEncode({
        "model": model,
        'web_search_options': {},
        "messages": chatMessages,
        // "temperature": 0.7,
      });
      msgModel = model;
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
        Logger.log(response.body);
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;

        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final message = data['choices'][0]['message'];
          final content = message['content']?.toString() ?? '';

          if (message['annotations'] != null &&
              message['annotations'] is List) {
            final annotations = message['annotations'] as List;
            if (annotations.isNotEmpty) {
              final StringBuffer annotated = StringBuffer(content.trim());
              annotated.write(' [');
              for (int i = 0; i < annotations.length; i++) {
                if (i > 0) annotated.write(', ');
                final annotation = annotations[i];
                if (annotation['type'] == 'url_citation' &&
                    annotation['url_citation'] != null &&
                    annotation['url_citation']['title'] != null) {
                  annotated.write(annotation['url_citation']['title']);
                }
              }
              annotated.write(']');
              return annotated.toString();
            }
          }

          return content.trim();
        } else {
          return '(No choices returned from ChatGPT)';
        }
      } else {
        print('ChatGPT API error: ${response.body}');
        return 'Sorry, ChatGPT did not respond. ${response.statusCode}';
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
      String model, List<Message> messages, String apiKey) async {
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
      msgModel = model;
      final response = await http.post(
        //   Uri.parse('$geminiUrl?key=$apiKey'),
        Uri.parse(geminiUrl + model + ':generateContent?key=$apiKey'),
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
      List<Map<String, dynamic>> chatMessages = [];

      if (ApiService.pdffilePath != "" && ApiService.pdffilePath != null) {
        final file = File(ApiService.pdffilePath!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        chatMessages = [
          {'role': 'user', 'content': systemPrompt},
          ...messages.asMap().entries.map((entry) {
            int index = entry.key;
            var message = entry.value;

            // Create the base message map
            Map<String, dynamic> messageMap = {
              "role": message.role,
              "content": message.content,
            };

            // If it's the last message, append the document object
            if (index == messages.length - 1) {
              if (ApiService.pdffilePath != "" &&
                  ApiService.pdffilePath != null) {
                messageMap["content"] = [
                  {
                    "type": "document",
                    "source": {
                      "type": "base64",
                      "media_type": "application/pdf",
                      "data": base64String,
                    }
                  },
                  {
                    "type": "text",
                    "text": message.content,
                  }
                ];
              }
            }

            return messageMap;
          }).toList(),
        ];
      } else {
        chatMessages = [
          {'role': 'user', 'content': systemPrompt},
          ...messages
              .map((m) => {"role": m.role, "content": m.content})
              .toList(),
        ];
      }

      int maxtoken = 60000;
      if (model == STR_claude35) {
        maxtoken = 8000;
      } else if (model == STR_claude40opus || model == STR_claude41opus) {
        maxtoken = 30000;
      }

      final sendJson = jsonEncode({
        'model': model,
        'messages': chatMessages,
        'max_tokens': maxtoken,
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
      ApiService.pdffilePath = "";
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

      List<Map<String, dynamic>> chatMessages = [];

      if (ApiService.pdffilePath != "" && ApiService.pdffilePath != null) {
        final file = File(ApiService.pdffilePath!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        chatMessages = [
          {'role': 'user', 'content': systemPrompt},
          ...messages.asMap().entries.map((entry) {
            int index = entry.key;
            var message = entry.value;

            // Create the base message map
            Map<String, dynamic> messageMap = {
              "role": message.role,
              "content": message.content,
            };

            // If it's the last message, append the document object
            if (index == messages.length - 1) {
              if (ApiService.pdffilePath != "" &&
                  ApiService.pdffilePath != null) {
                messageMap["content"] = [
                  {
                    "type": "document",
                    "source": {
                      "type": "base64",
                      "media_type": "application/pdf",
                      "data": base64String,
                    }
                  },
                  {
                    "type": "text",
                    "text": message.content,
                  }
                ];
              }
            }

            return messageMap;
          }).toList(),
        ];
      } else {
        chatMessages = [
          {'role': 'user', 'content': systemPrompt},
          ...messages
              .map((m) => {"role": m.role, "content": m.content})
              .toList(),
        ];
      }

      int maxtoken = 60000;
      if (model == STR_claude35) {
        maxtoken = 8000;
      } else if (model == STR_claude40opus || model == STR_claude41opus) {
        maxtoken = 30000;
      }

      final sendJson = jsonEncode({
        'model': model,
        'messages': chatMessages,
        'max_tokens': maxtoken,
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
      ApiService.pdffilePath = "";
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
        "max_tokens": 20000,
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
        Logger.log(data);
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

  static Future<String> _sendToGrok4WithHistory(
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
        "max_tokens": 60000,
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
        Logger.log(data);
        msgReceivedLength = response.bodyBytes.length;
        String retStr = '';
        final reply = data['content'][1]['text'];
        retStr = reply.trim();

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

  static Future<String> _sendToDeepSeekWithHistory(
      String model, List<Message> messages, String apiKey) async {
    Logger.log('_sendToDeepseeqWithHistory start');
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
      String systemPrompt = await SystemService.loadSystem();

      final chatMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
      ];

      final sendJson = jsonEncode({
        "model": model,
        "messages": chatMessages,
        "temperature": 0.7,
        "max_tokens": 4000,
        "stream": false,
      });

      msgModel = model;
      msgSendLength = sendJson.length;
      Logger.log(sendJson);
      final response = await http.post(
        Uri.parse(deepseekUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: sendJson,
      );

      if (response.statusCode == 200) {
        Logger.log(response.body);
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;
        final reply = data['choices'][0]['message']['content'];
        return reply.trim();
      } else {
        print('DeepSeek API error: ${response.body}');
        return 'Sorry, DeepSeek did not respond.';
      }
    } catch (e) {
      print('DeepSeek API error: $e');
      return 'DeepSeek Error occurred.';
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

  static Future<String> _sendToMistralWithHistory(
      String model, List<Message> messages, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';
    try {
      String systemPrompt = await SystemService.loadSystem();

      final chatMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
      ];
      final sendJson = jsonEncode({
        "model": model,
        "messages": chatMessages,
        "temperature": 0.6,
        "max_tokens": 8000,
      });
      msgModel = model;
      msgSendLength = sendJson.length;
      Logger.log(sendJson);
      final response = await http.post(
        Uri.parse(mistralUrl + '/chat/completions'),
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
        print('Mistral API error: ${response.body}');
        return 'Sorry, Mistral did not respond.';
      }
    } catch (e) {
      print('Mistral API error: $e');
      return 'Mistral Error occurred.';
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

  static Future<String> _sendToChatGPTWeb(
      String model, String userInput, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';

    try {
      String systemPrompt = await SystemService.loadSystem();
      final sendJson = jsonEncode({
        "model": model,
        'web_search_options': {},
        "messages": [
          {'role': 'developer', 'content': systemPrompt},
          {"role": "user", "content": userInput}
        ],
        // "temperature": 0.7,
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
        Logger.log(response.body);
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        msgReceivedLength = response.bodyBytes.length;

        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final message = data['choices'][0]['message'];
          final content = message['content']?.toString() ?? '';

          if (message['annotations'] != null &&
              message['annotations'] is List) {
            final annotations = message['annotations'] as List;
            if (annotations.isNotEmpty) {
              final StringBuffer annotated = StringBuffer(content.trim());
              annotated.write(' [');
              for (int i = 0; i < annotations.length; i++) {
                if (i > 0) annotated.write(', ');
                final annotation = annotations[i];
                if (annotation['type'] == 'url_citation' &&
                    annotation['url_citation'] != null &&
                    annotation['url_citation']['title'] != null) {
                  annotated.write(annotation['url_citation']['title']);
                }
              }
              annotated.write(']');
              return annotated.toString();
            }
          }

          return content.trim();
        } else {
          return '(No choices returned from ChatGPT)';
        }
      } else {
        print('ChatGPT API error: ${response.body}');
        return 'Sorry, ChatGPT did not respond. ${response.statusCode}';
      }
    } catch (e) {
      print('ChatGPT API error: $e');
      return 'ChatGPT Error occurred.';
    }
  }

  static Future<String> _sendToGemini(
      String model, String userInput, String apiKey) async {
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
      msgModel = model;
      final response = await http.post(
        Uri.parse(geminiUrl + model + ':generateContent?key=$apiKey'),
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
      int maxtoken = 60000;
      if (model == STR_claude35) {
        maxtoken = 8000;
      } else if (model == STR_claude40opus || model == STR_claude41opus) {
        maxtoken = 30000;
      }

      String sendJson = "";

      if (ApiService.pdffilePath != "" && ApiService.pdffilePath != null) {
        final file = File(ApiService.pdffilePath!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        sendJson = jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': systemPrompt},
            {
              "role": "user",
              "content": [
                {
                  "type": "document",
                  "source": {
                    "type": "base64",
                    "media_type": "application/pdf",
                    "data": base64String
                  }
                },
                {"type": "text", "text": userInput}
              ]
            }
          ],
          'max_tokens': maxtoken,
          'temperature': 0.7,
        });
      } else {
        sendJson = jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': systemPrompt},
            {'role': 'user', 'content': userInput}
          ],
          'max_tokens': maxtoken,
          'temperature': 0.7,
        });
      }

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
      ApiService.pdffilePath = "";
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
      int maxtoken = 60000;
      if (model == STR_claude35) {
        maxtoken = 8000;
      } else if (model == STR_claude40opus || model == STR_claude41opus) {
        maxtoken = 30000;
      }

      String sendJson = "";

      if (ApiService.pdffilePath != "" && ApiService.pdffilePath != null) {
        final file = File(ApiService.pdffilePath!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        sendJson = jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': systemPrompt},
            {
              "role": "user",
              "content": [
                {
                  "type": "document",
                  "source": {
                    "type": "base64",
                    "media_type": "application/pdf",
                    "data": base64String
                  }
                },
                {"type": "text", "text": userInput}
              ]
            }
          ],
          'max_tokens': maxtoken,
          'temperature': 0.7,
        });
      } else {
        sendJson = jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': systemPrompt},
            {'role': 'user', 'content': userInput}
          ],
          'max_tokens': maxtoken,
          'temperature': 0.7,
          "tools": [
            {
              "type": "web_search_20250305",
              "name": "web_search",
              "max_uses": 5,
            }
          ]
        });
      }
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

      ApiService.pdffilePath = "";
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
        "max_tokens": 20000,
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

  static Future<String> _sendToChatGrok4(
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
        "max_tokens": 60000,
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
        final reply = data['content'][1]['text'];
        retStr = reply.trim();
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

  static Future<String> _sendToChatDeepSeek(
      String model, String userInput, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';

    try {
      String systemPrompt = await SystemService.loadSystem();
      final sendJson = jsonEncode({
        "model": model,
        "messages": [
          {'role': 'system', 'content': systemPrompt},
          {"role": "user", "content": userInput}
        ],
        "temperature": 0.7,
        "max_tokens": 4000,
        "stream": false,
      });
      Logger.log(sendJson);
      msgSendLength = sendJson.length;
      msgModel = model;
      final response = await http.post(
        Uri.parse(deepseekUrl),
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
        print('DeepSeek API error: ${response.body}');
        return 'Sorry, DeepSeek did not respond.';
      }
    } catch (e) {
      print('DeepSeek API error: $e');
      return 'DeepSeek Error occurred.';
    }
  }

  static Future<String> _sendToChatMistral(
      String model, String userInput, String apiKey) async {
    msgSendLength = 0;
    msgReceivedLength = 0;
    msgModel = '';

    try {
      String systemPrompt = await SystemService.loadSystem();
      final sendJson = jsonEncode({
        "model": model,
        "messages": [
          {'role': 'system', 'content': systemPrompt},
          {"role": "user", "content": userInput}
        ],
        "temperature": 0.7,
      });
      Logger.log(sendJson);
      msgSendLength = sendJson.length;
      msgModel = model;
      final response = await http.post(
        Uri.parse(mistralUrl + '/chat/completions'),
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
        print('Mistral API error: ${response.body}');
        return 'Sorry, Mistral did not respond.';
      }
    } catch (e) {
      print('Mistral API error: $e');
      return 'Mistral Error occurred.';
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
