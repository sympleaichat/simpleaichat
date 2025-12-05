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
api_key_chatgpt51 = your_chatgpt_api_key_here
api_key_chatgpt5 = your_chatgpt_api_key_here
api_key_chatgpt5mini = your_chatgpt_api_key_here
api_key_chatgpt5nano = your_chatgpt_api_key_here
api_key_chatgpt41 = your_chatgpt_api_key_here
api_key_chatgpt4om = your_chatgpt_api_key_here
api_key_chatgpt4o = your_chatgpt_api_key_here
api_key_chatgpt35t = your_chatgpt_api_key_here
api_key_chatgpt4t  = your_chatgpt_api_key_here
api_key_chatgpt4 = your_chatgpt_api_key_here
api_key_chatgptdavinci002 = your_chatgpt_api_key_here
api_key_gemini30pro = your_gemini_api_key_here
api_key_gemini25flash = your_gemini_api_key_here
api_key_gemini25pro = your_gemini_api_key_here
api_key_gemini20flash = your_gemini_api_key_here
api_key_gemini15pro = your_gemini_api_key_here
api_key_claude45opus = your_claude_api_key_here
api_key_claude41opus = your_claude_api_key_here
api_key_claude40opus = your_claude_api_key_here
api_key_claude45sonnet = your_claude_api_key_here
api_key_claude40sonnet = your_claude_api_key_here
api_key_claude35 = your_claude_api_key_here
api_key_claude37 = your_claude_api_key_here
api_key_claude45haiku = your_claude_api_key_here
api_key_grok4 = your_grok_api_key_here
api_key_grok41fast = your_grok_api_key_here
api_key_grok3fast = your_grok_api_key_here
api_key_grok3fastmini = your_grok_api_key_here
api_key_grok3 = your_grok_api_key_here
api_key_grok3mini = your_grok_api_key_here
api_key_deepseek_chat = your_deepseek_api_key_here
api_key_deepseek_reasoner = your_deepseek_api_key_here
api_key_mistral_medium = your_mistral_api_key_here
api_key_mistral_large = your_mistral_api_key_here
api_key_mistral_ocr = your_mistral_api_key_here
api_key_mistral_small = your_mistral_api_key_here
dark_mode = false

### Setting Descriptions

| Key                 | Description                                   | Example                        |
|---------------------|-----------------------------------------------|--------------------------------|
| engine              | AI engine to use (chatgpt or gemini)          | engine = chatgpt               |
| api_key_chatgpt51   | API key for ChatGPT-5.1                      | api_key_chatgpt  = sk-xxxxxx |
| api_key_chatgpt5   | API key for ChatGPT-5                       | api_key_chatgpt  = sk-xxxxxx |
| api_key_chatgpt5mini   | API key for ChatGPT-5 mini                       | api_key_chatgpt  = sk-xxxxxx |
| api_key_chatgpt5nano   | API key for ChatGPT-5 nano                      | api_key_chatgpt  = sk-xxxxxx |
| api_key_chatgpt41   | API key for ChatGPT-4.1                       | api_key_chatgpt  = sk-xxxxxx |
| api_key_chatgpt4om  | API key for ChatGPT-4 Omni                    | api_key_chatgpt = sk-xxxxxx |
| api_key_chatgpt4o   | API key for ChatGPT-4 O                       | api_key_chatgpt = sk-xxxxxx  |
| api_key_chatgpt35t  | API key for ChatGPT-3.5turbo                  | api_key_chatgpt = sk-xxxxxx |
| api_key_chatgpt4t   | API key for ChatGPT-4 turbo                   | api_key_chatgpt = sk-xxxxxx  |
| api_key_chatgpt4    | API key for ChatGPT-4                         | api_key_chatgpt   = sk-xxxxxx |
| api_key_chatgptdavinci002  | API key for ChatGPT-davinci-002        | api_key_chatgpt = sk-xxxxxx |
| api_key_gemini25flash      | API key for Gemini 2.5 Flash           | api_key_gemini = AIxxxxxx      |
| api_key_gemini25pro        | API key for Gemini 2.5 Pro             | api_key_gemini = AIxxxxxx      |
| api_key_gemini25flash      | API key for Gemini 2.0 Flash           | api_key_gemini = AIxxxxxx      |
| api_key_gemini15pro        | API key for Gemini 1.5 Pro             | api_key_gemini = AIxxxxxx      |
| api_key_claude45opus| API key for Claude Opus 4.5                     | api_key_claude = sk-xxxxxx     |
| api_key_claude41opus| API key for Claude Opus 4.1                     | api_key_claude = sk-xxxxxx     |
| api_key_claude40opus| API key for Claude Opus 4                     | api_key_claude = sk-xxxxxx     |
| api_key_claude45sonnet    | API key for Claude Sonnet 4.5                 | api_key_claude = sk-xxxxxx |
| api_key_claude40sonnet    | API key for Claude Sonnet 4                 | api_key_claude = sk-xxxxxx |
| api_key_claude35    | API key for Claude 3.5 Haiku                  | api_key_claude = sk-xxxxxx     |
| api_key_claude37    | API key for Claude 3.7 Sonnet                 | api_key_claude = sk-xxxxxx     |
| api_key_claude45haiku    | API key for Claude 4.5 Haiku             | api_key_claude = sk-xxxxxx     |
| api_key_grok4       | API key for Grok 4                            | api_key_grok = xai-xxxx        |
| api_key_grok41fast   | API key for Grok 41 fast                       | api_key_grok = xai-xxxx        |
| api_key_grok3fast   | API key for Grok 3 fast                       | api_key_grok = xai-xxxx        |
| api_key_grok3fastmini      | API key for Grok 3 Mini fast           | api_key_grok = xai-xxxx        |
| api_key_grok3       | API key for Grok 3                            | api_key_grok = xai-xxxx        |
| api_key_grok3mini   | API key for Grok 3 Mini Sonnet                | api_key_grok = xai-xxxxx       |
| api_key_deepseek_chat       | API key for deepseek-chat             | api_key_deepseek = sk-xxxx     |
| api_key_deepseek_reasoner   | API key for deepseek-reasoner         | api_key_deepseek = sk-xxxxx    |
| api_key_mistral_large   | API key for Grok 3 Mistral Larget         | mistral_api_key = xxxxx        |
| api_key_mistral_ocr | API key for Mistral Medium                    | mistral_api_key = xxxxx        |
| api_key_mistral_small   | API key for Mistral Small                 | api_key_grok = xxxxx           |
| dark_mode           | UI theme: true for dark mode, false for light | mode = true                    |

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

■ Memory function
Information registered in the memory list can be sent with the chat message.
Only information that is checked in the checkbox will be sent

■ Compatible models
ChatGPT-5.1
ChatGPT-5
ChatGPT-5 mini
ChatGPT-5 nano
ChatGPT-4.1
ChatGPT o4-mini
ChatGPT o4
ChatGPT 3.5-turbo
ChatGPT 4-turbo
ChatGPT 4
ChatGPT davinci-002
Gemini 3.0 Pro
Gemini 2.5 Flash
Gemini 2.5 Pro
Gemini 2.0 Flash
Gemini 1.5 Pro
Claude Opus 4.5
Claude Opus 4.1
Claude Opus 4
Claude Sonnet 4.5
Claude Sonnet 4
Claude 3.5 Haiku
Claude 3.7 Sonnet
Claude 4.5 Haiku
Grok 4
Grok 4.1 fast
Grok 3 fast
Grok 3 Mini fast
Grok 3
Grok 3 Mini
deepseek-chat
deepseek-reasoner
Mistral Large
Mistral Medium
Mistral Small

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