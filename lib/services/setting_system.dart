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

    return 'It is now ${customFormattedDate}. ';
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
