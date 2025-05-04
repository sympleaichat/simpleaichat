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

  static Future<AIEngine> loadEngine() async {
    final config = await _loadConfig();
    final engine = config.get('settings', 'engine');

    if (engine == ApiService.STR_chatgpt_4omini) {
      return AIEngine.chatgpt_4omini;
    } else if (engine == ApiService.STR_chatgpt_4o) {
      return AIEngine.chatgpt_4o;
    } else if (engine == ApiService.STR_chatgpt_35turbo) {
      return AIEngine.chatgpt_35turbo;
    } else if (engine == ApiService.STR_gemini) {
      return AIEngine.gemini;
    } else if (engine == ApiService.STR_claude35) {
      return AIEngine.claude35;
    } else if (engine == ApiService.STR_claude37) {
      return AIEngine.claude37;
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

    switch (engine) {
      case AIEngine.chatgpt_4omini:
        return config.get('settings', 'api_key_chatgpt4om')!;
      case AIEngine.chatgpt_4o:
        return config.get('settings', 'api_key_chatgpt4o')!;
      case AIEngine.chatgpt_35turbo:
        return config.get('settings', 'api_key_chatgpt35t')!;
      case AIEngine.gemini:
        return config.get('settings', 'api_key_gemini')!;
      case AIEngine.claude35:
        return config.get('settings', 'api_key_claude35')!;
      case AIEngine.claude37:
        return config.get('settings', 'api_key_claude37')!;
      default:
        return config.get('settings', 'api_key_chatgpt')!;
    }
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
    if (engine == AIEngine.gemini) {
      config.set('settings', 'api_key_gemini', apiKey);
    } else if (engine == AIEngine.chatgpt_4omini) {
      config.set('settings', 'api_key_chatgpt4om', apiKey);
    } else if (engine == AIEngine.chatgpt_4o) {
      config.set('settings', 'api_key_chatgpt4o', apiKey);
    } else if (engine == AIEngine.chatgpt_35turbo) {
      config.set('settings', 'api_key_chatgpt35t', apiKey);
    } else if (engine == AIEngine.claude35) {
      config.set('settings', 'api_key_claude35', apiKey);
    } else if (engine == AIEngine.claude37) {
      config.set('settings', 'api_key_claude37', apiKey);
    } else {
      config.set('settings', 'api_key_chatgpt4om', apiKey);
    }
    await file.writeAsString(config.toString());
  }
}
