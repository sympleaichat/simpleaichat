# SimpleAIChat (Flutter Project)

This is the Flutter project source code for SimpleAIChat — a lightweight, secure, local AI chat client.


## How to Run

1. Install Flutter (version 3.10 or higher recommended).
2. Clone this repository.
3. Navigate to the project directory.
4. Run:

flutter pub get flutter run -d windows

or for other platforms:

flutter run

## Dependencies

- [http](https://pub.dev/packages/http)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

## Notes

- API keys are stored locally using SharedPreferences.
- Conversation data is stored on the local device only.
- Currently supports OpenAI and Gemini APIs.

---

## License

This project is licensed under the MIT License.