# CineVault - Flutter Movie Application

A production-quality Flutter movie application using the TMDB API with a dark cinematic UI, local Hive storage for favorites/watchlist, and modern animations.

## Architecture

The application follows Clean Architecture principles with a feature-first folder structure:

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

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x (Dart) |
| State Management | flutter_riverpod |
| HTTP Client | dio with interceptors |
| Local Storage | hive_flutter |
| Image Caching | cached_network_image |
| Notifications | flutter_local_notifications |
| Animations | flutter_staggered_animations + shimmer |

## Features

### Core Features
- Browse popular movies from TMDB
- Search movies with debounced API calls
- Filter movies by genre
- View detailed movie information
- Animated circular rating indicator
- Mark movies as Favourites
- Add movies to Watchlist
- Local persistence with Hive database
- In-app notification on Play Now

### UI/UX Features
- Dark cinematic theme (Netflix/IMDb inspired)
- Trending movies carousel
- Horizontal movie sections
- Category tabs (Popular, Top Rated, Now Playing, Upcoming)
- Hero animations between screens
- Shimmer loading placeholders
- Staggered grid animations
- Pull-to-refresh functionality
- Infinite scroll pagination
- Swipe-to-remove in Favourites/Watchlist
- Sorting options
- Haptic feedback on interactions
- Responsive grid layout

### State Handling
- Loading state with shimmer skeletons
- Empty state with illustrations
- Error state with retry button

## TMDB API Endpoints Used

| Feature | Endpoint |
|---------|----------|
| Popular Movies | GET /movie/popular |
| Top Rated | GET /movie/top_rated |
| Now Playing | GET /movie/now_playing |
| Upcoming | GET /movie/upcoming |
| Search Movies | GET /search/movie |
| Movie Details | GET /movie/{id} |
| Genres List | GET /genre/movie/list |
| Discover by Genre | GET /discover/movie |

## Data Flow

```
User Action → UI Widget → Riverpod Provider → Repository → DataSource → API/Hive
                    ↑                                           ↓
                    └───────────── State Update ←───────────────┘
```

## Color Palette

- Primary Background: #0D0D0D
- Surface Dark: #1A1A2E
- Surface Light: #16213E
- Accent Gold: #F5C518
- Text Primary: #FFFFFF
- Text Secondary: #B0B0B0
- Text Muted: #707070

## Typography

- Headings: Montserrat
- Body: Source Sans Pro
