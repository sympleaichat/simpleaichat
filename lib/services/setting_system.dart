import 'dart:io';
import 'package:intl/intl.dart';
import 'package:ini/ini.dart';
import 'package:path_provider/path_provider.dart';

class SystemService {
  static bool isInit = false;

  static const String _fileName = 'system_prompt.txt';

  static String _getCurrenttime() {
    String customFormattedDate =
        DateFormat('MMM dd, yyyy').format(DateTime.now());

    return 'I would like to present the current date in the format \'${customFormattedDate}\' within the system prompt. This is intended solely to indicate the current time, and I would like the recognition of dates from the training data to remain unchanged.';
  }

  static Future<File> _getIniFile() async {
    return File(await getIniFilePath());
  }

  static Future<String> getIniFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_fileName';
  }

  static Future<String> loadSystem() async {
    final file = await _getIniFile();

    if (!await file.exists()) {
      return 'You are a polite and helpful AI assistant. Please answer the user\'s questions.';
    }
    String content = await file.readAsString();

    return content;
    //       return _getCurrenttime() + content;
  }
}
