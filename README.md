# 📚 Study Cards

> A modern and intuitive flashcard app to optimize your learning

Study Cards is a comprehensive Flutter application designed to make studying more effective through customizable flashcards. Perfect for students, professionals, and anyone who wants to memorize information quickly and efficiently.

## ✨ Key Features

### 🎯 **Advanced Deck Management**
- Create custom card decks for different subjects
- Organize your cards by specific topics
- Detailed statistics for each deck (card count, creation date)
- Quick search among available decks

### 🃏 **Interactive Cards**
- Create cards with custom questions and answers
- Support for multimedia content (images)
- Integrated Markdown editor for advanced formatting
- Optimized display for different content types

### 📱 **Optimal User Experience**
- Modern and intuitive interface
- Support for light and dark modes
- Smooth animations and haptic feedback
- Custom splash screen

### 🌍 **Cross-Platform**
- **Android**: Full support with native integration
- **iOS**: Optimized experience for Apple devices
- **Windows**: Native desktop application
- **Web**: Accessible from any browser

### 📊 **Intelligent Review System**
- Spaced repetition algorithms to optimize learning
- Study progress tracking
- Personalized performance statistics

### 🎨 **Customization**
- Customizable themes
- Custom icons and splash screens
- Adaptive interface for different devices

### 💾 **Advanced File Management**
- Import/Export of decks and cards
- Automatic data backup
- Support for multimedia files
- Local synchronization

### 🔧 **Additional Features**
- Notification system for study reminders
- Complete offline mode
- Integrated feedback and ratings
- Advanced gesture controls (swipe, long press)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.3.4+)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/TechElites/study_cards.git
   cd study_cards
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate app icons**
   ```bash
   dart run flutter_launcher_icons
   ```

4. **Generate splash screen**
   ```bash
   dart run flutter_native_splash:create
   ```

5. **Build for your platform**
   
   **Android:**
   ```bash
   flutter build apk --release
   ```
   
   **iOS:**
   ```bash
   flutter build ios --release
   ```
   
   **Windows:**
   ```bash
   flutter build windows --release
   ```
   
   **Web:**
   ```bash
   flutter build web --release
   ```

## 📱 Downloads

- **Android APK**: Available in the `web/` folder
- **iOS IPA**: Available in the `web/` folder
- **Windows EXE**: Generated in `build/windows/x64/runner/Release/`

## 🛠️ Development

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── src/
│   ├── screens/             # Main screens
│   │   ├── home/           # Homepage and deck management
│   │   ├── cards/          # Card management
│   │   └── settings/       # App settings
│   ├── models/             # Data models
│   ├── helpers/            # Utilities and helpers
│   └── widgets/            # Reusable widgets
├── l10n/                   # Localizations
└── theme/                  # Themes and styles
```

### Testing
```bash
flutter test
```

### Development Build
```bash
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run              # Android/iOS (connected device)
```

## 🌟 Technologies Used

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Hive** - Local NoSQL database
- **Provider** - State management
- **Material Design 3** - Design system
- **Path Provider** - System path management
- **Image Picker** - Image selection
- **Permission Handler** - Permission management
- **Flutter Markdown** - Markdown rendering

## 📄 License

This project is distributed under the GNU Public license. See the `LICENSE` file for more details.

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

For support, bug reports, or feature requests open an [issue](https://github.com/TechElites/study_cards/issues) on GitHub.
 