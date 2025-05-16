import 'package:flutter/material.dart';
import '../services/setting_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/setting_system.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AIEngine _selectedEngine = AIEngine.chatgpt_41;
  bool _isDarkMode = false;
  bool _loading = true;
  bool _darkModeChanged = false;

  final TextEditingController _chatgpt41ApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt4omApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt4oApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt35ApiKeyController =
      TextEditingController();
  final TextEditingController _geminiApiKeyController = TextEditingController();
  final TextEditingController _claude35ApiKeyController =
      TextEditingController();
  final TextEditingController _claude37ApiKeyController =
      TextEditingController();
  final TextEditingController _grok3ApiKeyController = TextEditingController();
  final TextEditingController _grok3miniApiKeyController =
      TextEditingController();

  String _historyFilePath = '';
  String _systempromptPath = '';
  String _iniFilePath = '';
  var _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadHistoryFilePath();
  }

  void _loadHistoryFilePath() async {
    final path = await StorageService.getHistoryFilePath();
    final ipath = await SettingService.getIniFilePath();
    final spath = await SystemService.getIniFilePath();
    setState(() {
      _historyFilePath = path;
      _iniFilePath = ipath;
      _systempromptPath = spath;
    });
  }

  Future<void> _loadSettings() async {
    final engine = await SettingService.loadEngine();
    final darkMode = await SettingService.loadDarkMode();

    final chatgpt41Key = await SettingService.loadApiKey(AIEngine.chatgpt_41);
    final chatgpt4omKey =
        await SettingService.loadApiKey(AIEngine.chatgpt_4omini);
    final chatgpt4oKey = await SettingService.loadApiKey(AIEngine.chatgpt_4o);
    final chatgpt35tKey =
        await SettingService.loadApiKey(AIEngine.chatgpt_35turbo);
    final geminiKey = await SettingService.loadApiKey(AIEngine.gemini);
    final claude35Key = await SettingService.loadApiKey(AIEngine.claude35);
    final claude37Key = await SettingService.loadApiKey(AIEngine.claude37);
    final groq3Key = await SettingService.loadApiKey(AIEngine.grok_3);
    final groq3miniKey = await SettingService.loadApiKey(AIEngine.grok_3mini);
    setState(() {
      _selectedEngine = engine;
      _isDarkMode = darkMode;

      _chatgpt41ApiKeyController.text = chatgpt41Key;
      _chatgpt4omApiKeyController.text = chatgpt4omKey;
      _chatgpt4oApiKeyController.text = chatgpt4oKey;
      _chatgpt35ApiKeyController.text = chatgpt35tKey;
      _geminiApiKeyController.text = geminiKey;
      _claude35ApiKeyController.text = claude35Key;
      _claude37ApiKeyController.text = claude37Key;
      _grok3ApiKeyController.text = groq3Key;
      _grok3miniApiKeyController.text = groq3miniKey;

      _loading = false;
    });
  }

  Future<void> _onEngineChanged(AIEngine? newEngine) async {
    if (newEngine != null) {
      await SettingService.saveEngine(newEngine);
      setState(() {
        _selectedEngine = newEngine;
      });
      ApiService.currentEngine = newEngine;
    }
  }

  Future<void> _onDarkModeChanged(bool value) async {
    await SettingService.saveDarkMode(value);
    setState(() {
      _isDarkMode = value;
      _darkModeChanged = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please restart the app to apply the theme change.'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _onApiKeyChanged(AIEngine engine, String newKey) async {
    await SettingService.saveApiKey(engine, newKey);
  }

  Widget _buildEngineCard(AIEngine engine, TextEditingController controller) {
    final bool isSelected = _selectedEngine == engine;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Radio<AIEngine>(
            value: engine,
            groupValue: _selectedEngine,
            onChanged: _onEngineChanged,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ApiService.getModelName(engine),
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                TextField(
                  controller: controller,
                  style: TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'API Key',
                  ),
                  onChanged: (value) => _onApiKeyChanged(engine, value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatgpt41ApiKeyController.dispose();
    _chatgpt4omApiKeyController.dispose();
    _chatgpt4oApiKeyController.dispose();
    _chatgpt35ApiKeyController.dispose();
    _geminiApiKeyController.dispose();
    _claude35ApiKeyController.dispose();
    _claude37ApiKeyController.dispose();
    _grok3ApiKeyController.dispose();
    _grok3miniApiKeyController.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _darkModeChanged),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _darkModeChanged),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode',
                style: TextStyle(fontWeight: FontWeight.bold)),
            value: _isDarkMode,
            onChanged: _onDarkModeChanged,
          ),
          const SizedBox(height: 6),
          ListTile(
            title: const Text('History Save Location',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              _historyFilePath,
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 6),
          ListTile(
            title: Text('config Location',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              _iniFilePath,
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 6),
          ListTile(
            title: const Text('system prompt',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              _systempromptPath,
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 6),
          ListTile(
            title: const Text('Model List',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 400,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _buildEngineCard(
                        AIEngine.chatgpt_41, _chatgpt41ApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_4omini, _chatgpt4omApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_4o, _chatgpt4oApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_35turbo, _chatgpt35ApiKeyController),
                    _buildEngineCard(AIEngine.gemini, _geminiApiKeyController),
                    _buildEngineCard(
                        AIEngine.claude35, _claude35ApiKeyController),
                    _buildEngineCard(
                        AIEngine.claude37, _claude37ApiKeyController),
                    _buildEngineCard(AIEngine.grok_3, _grok3ApiKeyController),
                    _buildEngineCard(
                        AIEngine.grok_3mini, _grok3miniApiKeyController),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
