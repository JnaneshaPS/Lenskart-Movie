import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../data/datasources/favourites_local_datasource.dart';
import '../../data/repositories/favourites_repository_impl.dart';

final favouritesLocalDataSourceProvider =
    Provider<FavouritesLocalDataSourceImpl>((ref) {
  throw UnimplementedError('Provider should be overridden in main.dart');
});

final favouritesRepositoryProvider = Provider<FavouritesRepositoryImpl>((ref) {
  final localDataSource = ref.watch(favouritesLocalDataSourceProvider);
  return FavouritesRepositoryImpl(localDataSource);
});

class FavouritesState {
  final List<Movie> movies;
  final bool isLoading;
  final String? error;

  const FavouritesState({
    this.movies = const [],
    this.isLoading = false,
    this.error,
  });

  FavouritesState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    String? error,
  }) {
    return FavouritesState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FavouritesNotifier extends StateNotifier<FavouritesState> {
  final FavouritesRepositoryImpl _repository;

  FavouritesNotifier(this._repository) : super(const FavouritesState()) {
    loadFavourites();
  }

  Future<void> loadFavourites() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final movies = await _repository.getFavourites();
      state = state.copyWith(movies: movies, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleFavourite(Movie movie) async {
    try {
      if (_repository.isFavourite(movie.id)) {
        await _repository.removeFromFavourites(movie.id);
      } else {
        await _repository.addToFavourites(movie);
      }
      await loadFavourites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromFavourites(int movieId) async {
    try {
      await _repository.removeFromFavourites(movieId);
      await loadFavourites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  bool isFavourite(int movieId) {
    return _repository.isFavourite(movieId);
  }
}

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, FavouritesState>((ref) {
  final repository = ref.watch(favouritesRepositoryProvider);
  return FavouritesNotifier(repository);
});

final isFavouriteProvider = Provider.family<bool, int>((ref, movieId) {
  final favouritesState = ref.watch(favouritesProvider);
  return favouritesState.movies.any((movie) => movie.id == movieId);
});
