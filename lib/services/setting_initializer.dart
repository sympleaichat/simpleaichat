import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'setting_service.dart';

class SettingInitializer {
  static const _fileName = 'chatconf.ini';

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
}
