import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'setting_service.dart';
import 'setting_system.dart';

class SettingInitializer {
  static const _fileName = 'chatconf.ini';
  static const _fileNameSystem = 'system_prompt.txt';
  static Future<void> initializeSettings() async {
    final dir = await getApplicationDocumentsDirectory();
    final configFile = File('${dir.path}/$_fileName');

    if (await configFile.exists()) {
      SettingService.isInit = true;
      return;
    }

    final defaultIni = await rootBundle.loadString('assets/' + _fileName);
    await configFile.writeAsString(defaultIni);
  }

  static Future<void> initializeSystem() async {
    final dir = await getApplicationDocumentsDirectory();
    final configFile = File('${dir.path}/$_fileNameSystem');

    if (await configFile.exists()) {
      SystemService.isInit = true;
      return;
    }

    final defaultIni = await rootBundle.loadString('assets/' + _fileNameSystem);
    await configFile.writeAsString(defaultIni);
  }
}
