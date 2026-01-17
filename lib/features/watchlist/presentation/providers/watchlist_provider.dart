import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../data/datasources/watchlist_local_datasource.dart';
import '../../data/repositories/watchlist_repository_impl.dart';

final watchlistLocalDataSourceProvider =
    Provider<WatchlistLocalDataSourceImpl>((ref) {
  throw UnimplementedError('Provider should be overridden in main.dart');
});

final watchlistRepositoryProvider = Provider<WatchlistRepositoryImpl>((ref) {
  final localDataSource = ref.watch(watchlistLocalDataSourceProvider);
  return WatchlistRepositoryImpl(localDataSource);
});

class WatchlistState {
  final List<Movie> movies;
  final bool isLoading;
  final String? error;

  const WatchlistState({
    this.movies = const [],
    this.isLoading = false,
    this.error,
  });

  WatchlistState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    String? error,
  }) {
    return WatchlistState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WatchlistNotifier extends StateNotifier<WatchlistState> {
  final WatchlistRepositoryImpl _repository;

  WatchlistNotifier(this._repository) : super(const WatchlistState()) {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final movies = await _repository.getWatchlist();
      state = state.copyWith(movies: movies, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleWatchlist(Movie movie) async {
    try {
      if (_repository.isInWatchlist(movie.id)) {
        await _repository.removeFromWatchlist(movie.id);
      } else {
        await _repository.addToWatchlist(movie);
      }
      await loadWatchlist();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    try {
      await _repository.removeFromWatchlist(movieId);
      await loadWatchlist();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  bool isInWatchlist(int movieId) {
    return _repository.isInWatchlist(movieId);
  }
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, WatchlistState>((ref) {
  final repository = ref.watch(watchlistRepositoryProvider);
  return WatchlistNotifier(repository);
});

final isInWatchlistProvider = Provider.family<bool, int>((ref, movieId) {
  final watchlistState = ref.watch(watchlistProvider);
  return watchlistState.movies.any((movie) => movie.id == movieId);
});
