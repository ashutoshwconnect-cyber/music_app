# 🎵 SoundWave – Flutter Music Player App

SoundWave is a modern, responsive Flutter music player application powered by the [Jamendo Music API](https://developer.jamendo.com/v3.0). The codebase is designed to meet professional industry standards while remaining simple, clean, and accessible for a developer with 0–1 years of experience.

---

## 📱 Features

### 1. UI / UX
- **Home & Music Listing**: Clean, modern list of trending songs with high-resolution artwork, titles, artists, and durations.
- **Search**: Search songs by name or artist with instant submit and clear (`✕`) options.
- **Persistent Mini Player**: Docked at the bottom above the safe area, displaying album thumbnail, title, artist, play/pause, next button, and live progress bar.
- **Now Playing Screen**: Full-screen player featuring large album artwork, track details, seek slider with elapsed/total duration, play/pause, previous/next, shuffle, and repeat controls.
- **Responsive Layout**: Adapts gracefully across different screen sizes and orientations without overflow errors.
- **Dark & Light Mode**: Toggle themes instantly from the top app bar; preferences are saved locally.

### 2. API Integration & Pagination
- **Jamendo API (v3.0)**: Fetches popular tracks and handles keyword search.
- **Pagination (Infinite Scroll)**: Automatically loads the next 20 songs when the user scrolls near the bottom of the list.
- **Duplicate Prevention**: Guards against simultaneous duplicate network requests while a page is loading.
- **End of List Handling**: Gracefully detects when no more songs are available and indicates to the user.
- **Robust State Handling**: Dedicated widgets and states for loading spinners, empty search results, and network errors with a "Try Again" retry button.

### 3. Audio Playback
- **Powered by `just_audio`**:
  - Play, Pause, and Resume
  - Skip to Next and Previous tracks (with loop support)
  - Interactive Seek / Progress bar slider
  - Auto-play next track when current song finishes
  - Shuffle and Repeat modes

### 4. Offline Caching & Favorites (Bonus)
- **Offline Fallback**: Automatically caches the latest songs to local storage (`SharedPreferences`). If the user launches the app without an internet connection, cached tracks are loaded with an "Offline Mode" notice.
- **Favorites Screen**: Users can tap the heart icon on any song to save it for quick offline access.

---

## 🏗️ Project Architecture & State Management

The project is structured with a straightforward, beginner-friendly layered architecture that avoids unnecessary complexity or boilerplate:

```
lib/
├── core/
│   └── constants/
│       └── api_constants.dart      # Jamendo endpoints & secure Client ID resolution
├── themes/
│   ├── light_mode.dart             # Simple light theme definition
│   └── dark_mode.dart              # Simple dark theme definition
├── models/
│   └── track_model.dart            # Track data class with JSON parsing & duration helpers
├── services/
│   ├── api_service.dart            # HTTP communication with Jamendo API
│   └── storage_service.dart        # SharedPreferences wrapper for cache & favorites
├── providers/
│   ├── theme_provider.dart         # Dark/Light theme state
│   ├── music_provider.dart         # Song list, search, pagination, & favorites state
│   └── audio_player_provider.dart  # Playback state, streams, & player controls
├── screens/
│   ├── home_screen.dart            # Main music listing, search, & pagination
│   ├── now_playing_screen.dart     # Full-screen player with seek bar & controls
│   ├── favorites_screen.dart       # Offline favorites screen
│   └── home_page.dart              # Backward-compatible export
├── widgets/
│   ├── track_tile.dart             # Reusable song list item with live playing indicator
│   ├── mini_player.dart            # Persistent bottom audio player
│   └── error_view.dart             # Reusable error view with retry action
└── main.dart                       # App entry point, dotenv loading, & MultiProvider
```

### Why Provider & ChangeNotifier?
- **Beginner-Friendly**: Avoids steep learning curves associated with complex state management libraries like BLoC or Redux.
- **Native to Flutter**: Built on top of Flutter's `InheritedWidget`, making state changes easy to track, debug, and explain.
- **Clean Separation**:
  - `MusicProvider` handles API fetching, pagination flags (`isLoading`, `isLoadingMore`, `hasMore`), and search.
  - `AudioPlayerProvider` handles playback streams (`positionStream`, `playerStateStream`, `durationStream`) and playback methods.
  - `ThemeProvider` manages the visual theme.

---

## 🔑 API Configuration

The app connects directly to the official Jamendo Music API using straightforward, beginner-friendly constants in [`lib/core/constants/api_constants.dart`](lib/core/constants/api_constants.dart):

```dart
class ApiConstants {
  static const String baseUrl = 'https://api.jamendo.com/v3.0';
  static const String clientId = 'bc66595a';
  static const int pageSize = 20;
}
```

No external `.env` packages or complex environment setups are required—making it easy for beginner developers to run, debug, and understand right out of the box.

---

## 🚀 Setup & Run Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.13+ or higher)
- Android Studio / VS Code with Flutter extension
- An Android device or emulator with Android 5.0+ (API 21+)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd music_player
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🧪 Testing & Code Quality

Run static analysis to ensure 100% adherence to Flutter lint rules:
```bash
flutter analyze
```
*(Result: `No issues found!`)*

Run unit tests:
```bash
flutter test
```
*(Result: `All tests passed!`)*

---

## 📦 Building the Release APK

To generate a production-ready Android APK:

```bash
flutter build apk --release
```

The compiled APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📄 License
This project is created for educational and assignment purposes using the Jamendo Music API.
