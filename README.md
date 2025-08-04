# Click to Chat

A Flutter application that enables users to quickly start a chat with a phone number without saving it to contacts. Supports multiple platforms including Android, iOS, Web, and Windows.

## Features

- Start WhatsApp chats without saving contacts
- Cross-platform: Android, iOS, Web, Windows
- Country code picker
- Localized in English and Italian

## Getting Started

### Prerequisites

- [Dart](https://dart.dev/get-dart)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio, Xcode, or Visual Studio Code (recommended)

### Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/LRNZ09/click-to-chat.git
   cd click-to-chat
   ```

2. Get dependencies:

   ```sh
   flutter pub get
   ```

3. Run the app:

   ```sh
   flutter run
   ```

## Folder Structure

```t
lib/
  app.dart           # App entry point
  main.dart          # Main entry
  debug.dart         # Debug utilities
  l10n/              # Localization files
  routes/            # App routes
  utils/             # Utility functions
assets/              # App assets (icons, images)
web/                 # Web-specific files
android/             # Android project
ios/                 # iOS project
windows/             # Windows project
```

## Localization

- English and Italian supported
- Add new translations in `lib/l10n/`

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](LICENSE)
