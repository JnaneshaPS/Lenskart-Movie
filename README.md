# CineVault - Movie Discovery App

A feature-rich Flutter application for discovering movies using the TMDB API. Built with clean architecture, Riverpod state management, and a beautiful dark cinematic UI.

## Features

### Core Features
- Browse popular, top-rated, now playing, and upcoming movies
- Search movies with real-time results
- Filter movies by genre (Action, Comedy, Drama, etc.)
- View detailed movie information with ratings
- Mark movies as Favourites
- Add movies to Watchlist
- Local persistence using Hive database
- In-app notifications on movie playback

### UI/UX Features
- Dark cinematic theme inspired by Netflix/IMDb
- Trending movies carousel
- Horizontal scrollable movie sections
- Category tabs for different movie lists
- Hero animations between screens
- Shimmer loading placeholders
- Staggered grid animations
- Pull-to-refresh functionality
- Infinite scroll pagination
- Swipe-to-remove in Favourites/Watchlist
- Sorting options (Date Added, Rating, Title, Year)
- Responsive grid layout for all screen sizes

### State Handling
- Loading state with shimmer skeletons
- Empty state with illustrations
- Error state with retry button

## Screenshots

The app includes:
- Splash screen with animated logo
- Movies grid with search and genre filtering
- Movie detail screen with rating indicator
- Favourites and Watchlist management

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x |
| Language | Dart |
| State Management | Riverpod |
| HTTP Client | Dio |
| Local Storage | Hive |
| Image Caching | cached_network_image |
| Notifications | flutter_local_notifications |
| Animations | flutter_staggered_animations, shimmer |
| Typography | google_fonts |
| Rating Indicator | percent_indicator |

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- TMDB API key (https://www.themoviedb.org/settings/api)

## Setup Instructions

### 1. Navigate to the project

```bash
cd movie_app
```

### 2. Add your TMDB API Key

Open `lib/core/config/api_config.dart` and update with your API key:

```dart
class ApiConfig {
  static const String apiKey = 'YOUR_TMDB_API_KEY';
  ...
}
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

For development:
```bash
flutter run
```

For Chrome (Web):
```bash
flutter run -d chrome
```

For release build:
```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   ├── constants/
│   ├── network/
│   ├── error/
│   └── utils/
├── features/
│   ├── splash/
│   ├── home/
│   ├── movies/
│   ├── favourites/
│   └── watchlist/
└── shared/
    └── widgets/
```

## Architecture

The app follows Clean Architecture with three layers:

1. **Presentation Layer** - UI components, Riverpod providers
2. **Domain Layer** - Entities, repository interfaces
3. **Data Layer** - Models, data sources, repository implementations

## API Endpoints Used

| Feature | Endpoint |
|---------|----------|
| Popular Movies | GET /movie/popular |
| Top Rated | GET /movie/top_rated |
| Now Playing | GET /movie/now_playing |
| Upcoming | GET /movie/upcoming |
| Search | GET /search/movie |
| Movie Details | GET /movie/{id} |
| Genre List | GET /genre/movie/list |
| Discover by Genre | GET /discover/movie |

## Building APK

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

### Split APKs by ABI
```bash
flutter build apk --split-per-abi
```

## Troubleshooting

### API Key Issues
- Ensure your TMDB API key is valid
- Check if the API key is enabled in your TMDB account

### Build Issues
- Run `flutter clean` followed by `flutter pub get`
- Ensure Flutter SDK is up to date with `flutter upgrade`

### Android Build Issues
- Verify Android SDK is installed
- Check `minSdkVersion` is 21+ in `android/app/build.gradle`

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  dio: ^5.4.0
  hive_flutter: ^1.1.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_local_notifications: ^16.3.2
  go_router: ^13.0.0
  google_fonts: ^6.1.0
  percent_indicator: ^4.2.3
  flutter_staggered_animations: ^1.1.1
```

## License

This project is for educational purposes. Movie data provided by TMDB.
