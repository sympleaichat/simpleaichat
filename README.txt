==============================
SimpleAIChat - Thank you for installing!
==============================

■ Overview
SimpleAIChat is a lightweight and secure AI chat client built with Flutter.
It allows for flexible and private conversations by connecting directly to AI APIs,
without relying on external servers. All conversation history and API keys are securely stored on your device.

■ How to Use
This app uses an external file named `chatconf.ini` to manage settings such as AI engine selection, API keys, and dark mode preferences.

By editing `chatconf.ini`, you can configure the app without modifying any source code.

---

## Where to Find `chatconf.ini`
- Location: Same directory as the application executable
- If it does not exist, a default version will be created automatically at first launch.

---

## How to Edit
Open `chatconf.ini` with a text editor (Notepad, VSCode, etc.) and modify the settings as needed.

Example structure:

[settings]
engine = chatgpt
api_key_chatgpt4om = your_chatgpt_api_key_here
api_key_chatgpt4o = your_chatgpt_api_key_here
api_key_chatgpt35t = your_chatgpt_api_key_here
api_key_chatgpt4 = your_chatgpt_api_key_here
api_key_chatgptdavinci002 = your_chatgpt_api_key_here
api_key_gemini = your_gemini_api_key_here
api_key_claude35 = your_claude_api_key_here
api_key_claude37 = your_claude_api_key_here
dark_mode = false

### Setting Descriptions

| Key                 | Description                                   | Example                        |
|---------------------|-----------------------------------------------|--------------------------------|
| engine              | AI engine to use (chatgpt or gemini)          | engine = chatgpt               |
| api_key_chatgpt41   | API key for ChatGPT-4.1                       | api_key_chatgpt41  = sk-xxxxxx |
| api_key_chatgpt4om  | API key for ChatGPT-4 Omni                    | api_key_chatgpt4om = sk-xxxxxx |
| api_key_chatgpt4o   | API key for ChatGPT-4 O                       | api_key_chatgpt4o = sk-xxxxxx  |
| api_key_chatgpt35t  | API key for ChatGPT-3.5turbo                  | api_key_chatgpt35t = sk-xxxxxx |
| api_key_chatgpt4    | API key for ChatGPT-4                         | api_key_chatgpt4   = sk-xxxxxx |
| api_key_chatgptdavinci002  | API key for ChatGPT-davinci-002        | api_key_chatgptdavinci002 = sk-xxxxxx |
| api_key_gemini      | API key for Gemini                            | api_key_gemini = gemini-xxxxxx |
| api_key_claude35    | API key for Claude 3.5 Haiku                  | api_key_claude35 = sk-xxxxxx   |
| api_key_claude37    | API key for Claude 3.7 Sonnet                 | api_key_claude37 = sk-xxxxxx   |
| api_key_grok3       | API key for Grok 3                            | api_key_grok3 = xai-xxxx       |
| api_key_grok3mini   | API key for Grok 3 Mini Sonnet                | api_key_grok3mini = xai-xxxxx  |
| dark_mode           | UI theme: true for dark mode, false for light | dark_mode = true               |

⚠ Important Notes
- Always keep the [settings] header at the top.
- No spaces around `=` are strictly required but help readability.
- Save as UTF-8 format if possible.
- Do not remove any keys; leave them empty if unused.

🆘 Troubleshooting

| Problem                     | Solution                                               |
|-----------------------------|--------------------------------------------------------|
| App doesn't start           | Check `chatconf.ini` for syntax errors                |
| Dark mode setting ignored   | Make sure dark_mode is either `true` or `false`       |
| API key not working         | Ensure there are no extra spaces or invalid characters |

✅ Quick Tips
- Backup your `chatconf.ini` before making changes.
- Restart the app after editing `chatconf.ini` to apply changes.

■ Compatible models
ChatGPT-4.1
ChatGPT o4-mini
ChatGPT o4
ChatGPT 3.5-turbo
ChatGPT 4
ChatGPT davinci-002
Gemini 1.5 Pro
Claude 3.5 Haiku
Claude 3.7 Sonnet
Grok 3
Grok 3 Mini

■ Requirements
- Internet connection is required for AI interaction.
- Valid API keys must be provided in `chatconf.ini`.

■ Support & Contact
For questions, suggestions, or bug reports, contact us at:
- Email: sympleaichat125@gmail.com
- GitHub: https://github.com/sympleaichat/simpleaichat

■ License
This software is licensed under the MIT License.

■ Disclaimer
- The app provides an interface to third-party AI services (OpenAI, Gemini, etc.). Use is subject to the terms and conditions of each respective provider.
- The developer is not responsible for any charges, API fees, or data loss that may result from the use of the app.