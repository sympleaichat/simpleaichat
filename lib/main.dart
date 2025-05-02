import 'package:flutter/material.dart';
import 'services/setting_initializer.dart';
import 'services/setting_service.dart';
import 'services/api_service.dart';
import 'screens/chat_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized before any async operation
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings (copy config.ini if needed)
  await SettingInitializer.initializeSettings();

  // Load dark mode preference
  final bool isDarkMode = await SettingService.loadDarkMode();
  ApiService.currentEngine = await SettingService.loadEngine();
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;

  const MyApp({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SympleAIChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xfff5f5f7),
        primaryColor: Color(0xff1565c0),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xffe0e0e0),
          foregroundColor: Color(0xff2c2c2c),
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, color: Color(0xff2c2c2c)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff252526), //
        primaryColor: const Color(0xff64b5f6), //
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff2f3237), //
          foregroundColor: Color(0xffffffff), //
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, color: Color(0xfff5f5f5)), //
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ChatScreen(),
    );
  }
}
