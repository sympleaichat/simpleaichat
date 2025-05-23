import 'dart:io';
import 'package:ini/ini.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';

class SettingService {
  static bool isInit = false;

  static const String _fileName = 'chatconf.ini';

  static Future<File> _getIniFile() async {
    return File(await getIniFilePath());
  }

  static Future<String> getIniFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_fileName';
  }

  static Future<Config> _loadConfig() async {
    final file = await _getIniFile();
    if (!await file.exists()) {
      throw Exception('configuration file does not exist');
    }
    final content = await file.readAsString();
    return Config.fromString(content);
  }

  static String getKeyStr(AIEngine engine) {
    switch (engine) {
      case AIEngine.chatgpt_41:
        return 'api_key_chatgpt41';
      case AIEngine.chatgpt_4omini:
        return 'api_key_chatgpt4om';
      case AIEngine.chatgpt_4o:
        return 'api_key_chatgpt4o';
      case AIEngine.chatgpt_35turbo:
        return 'api_key_chatgpt35t';
      case AIEngine.chatgpt_4turbo:
        return 'api_key_chatgpt4t';
      case AIEngine.gpt4:
        return 'api_key_chatgpt4';
      case AIEngine.chatgpt_davinci002:
        return 'api_key_chatgptdavinci002';
      case AIEngine.gemini25flash:
        return 'api_key_gemini25flash';
      case AIEngine.gemini25pro:
        return 'api_key_gemini25pro';
      case AIEngine.gemini20flash:
        return 'api_key_gemini20flash';
      case AIEngine.gemini15pro:
        return 'api_key_gemini15pro';
      case AIEngine.claude40opus:
        return 'api_key_claude40opus';
      case AIEngine.claude40sonnet:
        return 'api_key_claude40sonnet';
      case AIEngine.claude35:
        return 'api_key_claude35';
      case AIEngine.claude37:
        return 'api_key_claude37';
      case AIEngine.grok_3:
        return 'api_key_grok3';
      case AIEngine.grok_3mini:
        return 'api_key_grok3mini';
      case AIEngine.deepseek_chat:
        return 'api_key_deepseek_chat';
      case AIEngine.deepseek_reasoner:
        return 'api_key_deepseek_reasoner';
    }
  }

  static Future<AIEngine> loadEngine() async {
    final config = await _loadConfig();
    final engine = config.get('settings', 'engine');

    if (engine == ApiService.STR_chatgpt_41) {
      return AIEngine.chatgpt_41;
    } else if (engine == ApiService.STR_chatgpt_4omini) {
      return AIEngine.chatgpt_4omini;
    } else if (engine == ApiService.STR_chatgpt_4o) {
      return AIEngine.chatgpt_4o;
    } else if (engine == ApiService.STR_chatgpt_35turbo) {
      return AIEngine.chatgpt_35turbo;
    } else if (engine == ApiService.STR_chatgpt_4turbo) {
      return AIEngine.chatgpt_4turbo;
    } else if (engine == ApiService.STR_chatgpt_4) {
      return AIEngine.gpt4;
    } else if (engine == ApiService.STR_chatgpt_davinci002) {
      return AIEngine.chatgpt_davinci002;
    } else if (engine == ApiService.STR_gemini25flash) {
      return AIEngine.gemini25flash;
    } else if (engine == ApiService.STR_gemini25pro) {
      return AIEngine.gemini25pro;
    } else if (engine == ApiService.STR_gemini20flash) {
      return AIEngine.gemini20flash;
    } else if (engine == ApiService.STR_gemini15pro) {
      return AIEngine.gemini15pro;
    } else if (engine == ApiService.STR_claude40opus) {
      return AIEngine.claude40opus;
    } else if (engine == ApiService.STR_claude40sonnet) {
      return AIEngine.claude40sonnet;
    } else if (engine == ApiService.STR_claude35) {
      return AIEngine.claude35;
    } else if (engine == ApiService.STR_claude37) {
      return AIEngine.claude37;
    } else if (engine == ApiService.STR_grok3) {
      return AIEngine.grok_3;
    } else if (engine == ApiService.STR_grok3mini) {
      return AIEngine.grok_3mini;
    } else if (engine == ApiService.STR_deepseek_chat) {
      return AIEngine.deepseek_chat;
    } else if (engine == ApiService.STR_deepseek_reasoner) {
      return AIEngine.deepseek_reasoner;
    } else {
      return AIEngine.chatgpt_4omini;
    }
  }

  static Future<void> saveEngine(AIEngine engine) async {
    final file = await _getIniFile();
    final config = await _loadConfig();
    config.set('settings', 'engine', ApiService.getModelStr(engine));
    await file.writeAsString(config.toString());
  }

  static Future<String> loadApiKey(AIEngine engine) async {
    final config = await _loadConfig();

    if (config.hasOption('settings', getKeyStr(engine))) {
      return config.get('settings', getKeyStr(engine))!;
    }
    return 'your_api_key';
  }

  static Future<bool> loadDarkMode() async {
    final config = await _loadConfig();
    final value = config.get('settings', 'dark_mode');
    return value?.toLowerCase() == 'true';
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final file = await _getIniFile();
    final config = await _loadConfig();
    config.set('settings', 'dark_mode', isDark.toString());
    await file.writeAsString(config.toString());
  }

  // APIキー保存
  static Future<void> saveApiKey(AIEngine engine, String apiKey) async {
    final file = await _getIniFile();
    final config = await _loadConfig();
    config.set('settings', getKeyStr(engine), apiKey);

    await file.writeAsString(config.toString());
  }
}
