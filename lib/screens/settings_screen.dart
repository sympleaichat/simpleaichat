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

  final TextEditingController _chatgpt51ApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt5ApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt5miniApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt5nanoApiKeyController =
      TextEditingController();

  final TextEditingController _chatgpt41ApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt4omApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt4oApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt35ApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt4tApiKeyController =
      TextEditingController();
  final TextEditingController _chatgpt4ApiKeyController =
      TextEditingController();
  final TextEditingController _chatgptdavinci002ApiKeyController =
      TextEditingController();

  final TextEditingController _gemini30proApiKeyController =
      TextEditingController();
  final TextEditingController _gemini25flashApiKeyController =
      TextEditingController();
  final TextEditingController _gemini25proApiKeyController =
      TextEditingController();
  final TextEditingController _gemini20flashApiKeyController =
      TextEditingController();
  final TextEditingController _gemini15proApiKeyController =
      TextEditingController();
  final TextEditingController _claude41oApiKeyController =
      TextEditingController();
  final TextEditingController _claude40oApiKeyController =
      TextEditingController();

  final TextEditingController _claude45sApiKeyController =
      TextEditingController();
  final TextEditingController _claude40sApiKeyController =
      TextEditingController();
  final TextEditingController _claude35ApiKeyController =
      TextEditingController();
  final TextEditingController _claude37ApiKeyController =
      TextEditingController();
  final TextEditingController _claude45haikuApiKeyController =
      TextEditingController();

  final TextEditingController _grok4ApiKeyController = TextEditingController();
  final TextEditingController _grok3fastApiKeyController =
      TextEditingController();
  final TextEditingController _grok41fastminiApiKeyController =
      TextEditingController();
  final TextEditingController _grok3fastminiApiKeyController =
      TextEditingController();

  final TextEditingController _grok3ApiKeyController = TextEditingController();
  final TextEditingController _grok3miniApiKeyController =
      TextEditingController();
  final TextEditingController _deepseek_chat_ApiKeyController =
      TextEditingController();
  final TextEditingController _deepseek_reasoner_ApiKeyController =
      TextEditingController();
  final TextEditingController _mistral_large_ApiKeyController =
      TextEditingController();
  final TextEditingController _mistral_medium_ApiKeyController =
      TextEditingController();
  final TextEditingController _mistral_small_ApiKeyController =
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

    final chatgpt51Key = await SettingService.loadApiKey(AIEngine.chatgpt_51);
    final chatgpt5Key = await SettingService.loadApiKey(AIEngine.chatgpt_5);
    final chatgpt5miniKey =
        await SettingService.loadApiKey(AIEngine.chatgpt_5mini);
    final chatgpt5nanoKey =
        await SettingService.loadApiKey(AIEngine.chatgpt_5nano);

    final chatgpt41Key = await SettingService.loadApiKey(AIEngine.chatgpt_41);
    final chatgpt4omKey =
        await SettingService.loadApiKey(AIEngine.chatgpt_4omini);
    final chatgpt4oKey = await SettingService.loadApiKey(AIEngine.chatgpt_4o);
    final chatgpt35tKey =
        await SettingService.loadApiKey(AIEngine.chatgpt_35turbo);
    final chatgpt4tKey =
        await SettingService.loadApiKey(AIEngine.chatgpt_4turbo);
    final chatgpt4Key = await SettingService.loadApiKey(AIEngine.gpt4);
    final chatgptdavinci002Key =
        await SettingService.loadApiKey(AIEngine.chatgpt_davinci002);

    final gemini30proKey =
        await SettingService.loadApiKey(AIEngine.gemini30pro);
    final gemini25flashKey =
        await SettingService.loadApiKey(AIEngine.gemini25flash);
    final gemini25proKey =
        await SettingService.loadApiKey(AIEngine.gemini25pro);
    final gemini20flashKey =
        await SettingService.loadApiKey(AIEngine.gemini20flash);
    final gemini15proKey =
        await SettingService.loadApiKey(AIEngine.gemini15pro);
    final claude41oKey = await SettingService.loadApiKey(AIEngine.claude41opus);
    final claude40oKey = await SettingService.loadApiKey(AIEngine.claude40opus);
    final claude45sKey =
        await SettingService.loadApiKey(AIEngine.claude45sonnet);
    final claude40sKey =
        await SettingService.loadApiKey(AIEngine.claude40sonnet);
    final claude35Key = await SettingService.loadApiKey(AIEngine.claude35);
    final claude37Key = await SettingService.loadApiKey(AIEngine.claude37);
    final claude45haikuKey =
        await SettingService.loadApiKey(AIEngine.claude45haiku);

    final groq4Key = await SettingService.loadApiKey(AIEngine.grok_4);
    final grok41fastKey =
        await SettingService.loadApiKey(AIEngine.grok_41_fast);
    final grok3fastKey = await SettingService.loadApiKey(AIEngine.grok_3_fast);
    final grok3fastminiKey =
        await SettingService.loadApiKey(AIEngine.grok_3_fast_mini);

    final groq3Key = await SettingService.loadApiKey(AIEngine.grok_3);
    final groq3miniKey = await SettingService.loadApiKey(AIEngine.grok_3mini);
    final deepseek_chat_Key =
        await SettingService.loadApiKey(AIEngine.deepseek_chat);
    final deepseek_reasoner_Key =
        await SettingService.loadApiKey(AIEngine.deepseek_reasoner);
    final mistral_large_Key =
        await SettingService.loadApiKey(AIEngine.mistral_large);
    final mistral_medium_Key =
        await SettingService.loadApiKey(AIEngine.mistral_medium);
    final mistral_small_Key =
        await SettingService.loadApiKey(AIEngine.mistral_small);

    setState(() {
      _selectedEngine = engine;
      _isDarkMode = darkMode;

      _chatgpt51ApiKeyController.text = chatgpt51Key;
      _chatgpt5ApiKeyController.text = chatgpt5Key;
      _chatgpt5miniApiKeyController.text = chatgpt5miniKey;
      _chatgpt5nanoApiKeyController.text = chatgpt5nanoKey;

      _chatgpt41ApiKeyController.text = chatgpt41Key;
      _chatgpt4omApiKeyController.text = chatgpt4omKey;
      _chatgpt4oApiKeyController.text = chatgpt4oKey;
      _chatgpt35ApiKeyController.text = chatgpt35tKey;
      _chatgpt4tApiKeyController.text = chatgpt4tKey;
      _chatgpt4ApiKeyController.text = chatgpt4Key;
      _chatgptdavinci002ApiKeyController.text = chatgptdavinci002Key;
      _gemini30proApiKeyController.text = gemini30proKey;
      _gemini25flashApiKeyController.text = gemini25flashKey;
      _gemini25proApiKeyController.text = gemini25proKey;
      _gemini20flashApiKeyController.text = gemini20flashKey;
      _gemini15proApiKeyController.text = gemini15proKey;
      _claude41oApiKeyController.text = claude41oKey;
      _claude40oApiKeyController.text = claude40oKey;
      _claude45sApiKeyController.text = claude45sKey;
      _claude40sApiKeyController.text = claude40sKey;
      _claude35ApiKeyController.text = claude35Key;
      _claude37ApiKeyController.text = claude37Key;
      _claude45haikuApiKeyController.text = claude45haikuKey;

      _grok4ApiKeyController.text = groq4Key;
      _grok41fastminiApiKeyController.text = grok41fastKey;
      _grok3fastApiKeyController.text = grok3fastKey;
      _grok3fastminiApiKeyController.text = grok3fastminiKey;

      _grok3ApiKeyController.text = groq3Key;
      _grok3miniApiKeyController.text = groq3miniKey;
      _deepseek_chat_ApiKeyController.text = deepseek_chat_Key;
      _deepseek_reasoner_ApiKeyController.text = deepseek_reasoner_Key;
      _mistral_large_ApiKeyController.text = mistral_large_Key;
      _mistral_medium_ApiKeyController.text = mistral_medium_Key;
      _mistral_small_ApiKeyController.text = mistral_small_Key;

      _loading = false;
    });
  }

  Future<void> _onEngineChanged(AIEngine? newEngine) async {
    ApiService.pdffilePath = "";
    ApiService.pdffileName = "";
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
    _chatgpt51ApiKeyController.dispose();

    _chatgpt5ApiKeyController.dispose();
    _chatgpt5miniApiKeyController.dispose();
    _chatgpt5nanoApiKeyController.dispose();

    _claude41oApiKeyController.dispose();
    _claude40oApiKeyController.dispose();
    _claude45sApiKeyController.dispose();
    _claude40sApiKeyController.dispose();
    _claude35ApiKeyController.dispose();
    _claude37ApiKeyController.dispose();
    _claude45haikuApiKeyController.dispose();
    _chatgpt41ApiKeyController.dispose();
    _chatgpt4omApiKeyController.dispose();
    _chatgpt4oApiKeyController.dispose();
    _chatgpt35ApiKeyController.dispose();
    _chatgpt4tApiKeyController.dispose();
    _chatgpt4ApiKeyController.dispose();
    _chatgptdavinci002ApiKeyController.dispose();
    _gemini30proApiKeyController.dispose();
    _gemini25flashApiKeyController.dispose();
    _gemini25proApiKeyController.dispose();
    _gemini20flashApiKeyController.dispose();
    _gemini15proApiKeyController.dispose();
    _grok4ApiKeyController.dispose();
    _grok3fastApiKeyController.dispose();
    _grok41fastminiApiKeyController.dispose();
    _grok3fastminiApiKeyController.dispose();
    _grok3ApiKeyController.dispose();
    _grok3miniApiKeyController.dispose();
    _deepseek_chat_ApiKeyController.dispose();
    _deepseek_reasoner_ApiKeyController.dispose();
    _mistral_large_ApiKeyController.dispose();
    _mistral_medium_ApiKeyController.dispose();
    _mistral_small_ApiKeyController.dispose();

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
            //    activeTrackColor: Colors.blue[800],
            //   inactiveTrackColor: Colors.blue[200],
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
                        AIEngine.chatgpt_51, _chatgpt51ApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_5, _chatgpt5ApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_5mini, _chatgpt5miniApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_5nano, _chatgpt5nanoApiKeyController),
                    _buildEngineCard(
                        AIEngine.claude41opus, _claude41oApiKeyController),
                    _buildEngineCard(
                        AIEngine.claude40opus, _claude40oApiKeyController),
                    _buildEngineCard(
                        AIEngine.claude45sonnet, _claude45sApiKeyController),
                    _buildEngineCard(
                        AIEngine.claude40sonnet, _claude40sApiKeyController),
                    _buildEngineCard(
                        AIEngine.claude35, _claude35ApiKeyController),
                    _buildEngineCard(
                        AIEngine.claude37, _claude37ApiKeyController),
                    _buildEngineCard(
                        AIEngine.claude45haiku, _claude45haikuApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_41, _chatgpt41ApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_4omini, _chatgpt4omApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_4o, _chatgpt4oApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_35turbo, _chatgpt35ApiKeyController),
                    _buildEngineCard(
                        AIEngine.chatgpt_4turbo, _chatgpt4tApiKeyController),
                    _buildEngineCard(AIEngine.gpt4, _chatgpt4ApiKeyController),
                    _buildEngineCard(AIEngine.chatgpt_davinci002,
                        _chatgptdavinci002ApiKeyController),
                    _buildEngineCard(
                        AIEngine.gemini30pro, _gemini30proApiKeyController),
                    _buildEngineCard(
                        AIEngine.gemini25flash, _gemini25flashApiKeyController),
                    _buildEngineCard(
                        AIEngine.gemini25pro, _gemini25proApiKeyController),
                    _buildEngineCard(
                        AIEngine.gemini20flash, _gemini20flashApiKeyController),
                    _buildEngineCard(
                        AIEngine.gemini15pro, _gemini15proApiKeyController),
                    _buildEngineCard(
                        AIEngine.grok_41_fast, _grok41fastminiApiKeyController),
                    _buildEngineCard(AIEngine.grok_4, _grok4ApiKeyController),
                    _buildEngineCard(
                        AIEngine.grok_3_fast, _grok3fastApiKeyController),
                    _buildEngineCard(AIEngine.grok_3_fast_mini,
                        _grok3fastminiApiKeyController),
                    _buildEngineCard(AIEngine.grok_3, _grok3ApiKeyController),
                    _buildEngineCard(
                        AIEngine.grok_3mini, _grok3miniApiKeyController),
                    _buildEngineCard(AIEngine.deepseek_chat,
                        _deepseek_chat_ApiKeyController),
                    _buildEngineCard(AIEngine.deepseek_reasoner,
                        _deepseek_reasoner_ApiKeyController),
                    _buildEngineCard(AIEngine.mistral_medium,
                        _mistral_medium_ApiKeyController),
                    _buildEngineCard(AIEngine.mistral_small,
                        _mistral_small_ApiKeyController),
                    _buildEngineCard(AIEngine.mistral_large,
                        _mistral_large_ApiKeyController),
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
