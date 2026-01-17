import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/movie_remote_datasource.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final movieRemoteDataSourceProvider = Provider<MovieRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MovieRemoteDataSourceImpl(dioClient);
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final remoteDataSource = ref.watch(movieRemoteDataSourceProvider);
  return MovieRepositoryImpl(remoteDataSource);
});

final genresProvider = FutureProvider<List<Genre>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  return await repository.getGenres();
});

final genresMapProvider = FutureProvider<Map<int, String>>((ref) async {
  final genres = await ref.watch(genresProvider.future);
  return {for (var genre in genres) genre.id: genre.name};
});

enum MovieCategory { popular, topRated, nowPlaying, upcoming }

final selectedCategoryProvider = StateProvider<MovieCategory>((ref) => MovieCategory.popular);
final selectedGenreProvider = StateProvider<int?>((ref) => null);

class MoviesState {
  final List<Movie> movies;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMorePages;
  final String searchQuery;
  final int? selectedGenreId;
  final MovieCategory category;

  const MoviesState({
    this.movies = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = true,
    this.searchQuery = '',
    this.selectedGenreId,
    this.category = MovieCategory.popular,
  });

  MoviesState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMorePages,
    String? searchQuery,
    int? selectedGenreId,
    MovieCategory? category,
    bool clearGenre = false,
  }) {
    return MoviesState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGenreId: clearGenre ? null : (selectedGenreId ?? this.selectedGenreId),
      category: category ?? this.category,
    );
  }
}

class MoviesNotifier extends StateNotifier<MoviesState> {
  final MovieRepository _repository;
  Timer? _debounceTimer;

  MoviesNotifier(this._repository) : super(const MoviesState()) {
    loadMovies();
  }

  Future<void> loadMovies() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      MoviesResponse response;
      
      if (state.searchQuery.isNotEmpty) {
        response = await _repository.searchMovies(state.searchQuery, page: 1);
      } else if (state.selectedGenreId != null) {
        response = await _repository.getMoviesByGenre(state.selectedGenreId!, page: 1);
      } else {
        response = await _getCategoryMovies(1);
      }

      state = state.copyWith(
        movies: response.results,
        isLoading: false,
        currentPage: 1,
        hasMorePages: response.hasMorePages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<MoviesResponse> _getCategoryMovies(int page) async {
    switch (state.category) {
      case MovieCategory.popular:
        return await _repository.getPopularMovies(page: page);
      case MovieCategory.topRated:
        return await _repository.getTopRatedMovies(page: page);
      case MovieCategory.nowPlaying:
        return await _repository.getNowPlayingMovies(page: page);
      case MovieCategory.upcoming:
        return await _repository.getUpcomingMovies(page: page);
    }
  }

  Future<void> loadMoreMovies() async {
    if (state.isLoadingMore || !state.hasMorePages) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      MoviesResponse response;
      
      if (state.searchQuery.isNotEmpty) {
        response = await _repository.searchMovies(state.searchQuery, page: nextPage);
      } else if (state.selectedGenreId != null) {
        response = await _repository.getMoviesByGenre(state.selectedGenreId!, page: nextPage);
      } else {
        response = await _getCategoryMovies(nextPage);
      }

      state = state.copyWith(
        movies: [...state.movies, ...response.results],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMorePages: response.hasMorePages,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void searchMovies(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(searchQuery: query, currentPage: 1, clearGenre: true);
      loadMovies();
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = state.copyWith(searchQuery: '', currentPage: 1);
    loadMovies();
  }

  void selectGenre(int? genreId) {
    if (genreId == state.selectedGenreId) return;
    state = MoviesState(
      selectedGenreId: genreId,
      category: state.category,
      isLoading: true,
    );
    loadMovies();
  }

  void selectCategory(MovieCategory category) {
    if (category == state.category && state.selectedGenreId == null) return;
    state = MoviesState(
      category: category,
      isLoading: true,
    );
    loadMovies();
  }

  Future<void> refresh() async {
    await loadMovies();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final moviesProvider = StateNotifierProvider<MoviesNotifier, MoviesState>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return MoviesNotifier(repository);
});

final movieDetailProvider = FutureProvider.family<MovieDetail, int>((ref, movieId) async {
  final repository = ref.watch(movieRepositoryProvider);
  return await repository.getMovieDetails(movieId);
});

final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  final response = await repository.getPopularMovies(page: 1);
  return response.results.take(10).toList();
});

final nowPlayingMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  final response = await repository.getNowPlayingMovies(page: 1);
  return response.results.take(10).toList();
});

final topRatedMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  final response = await repository.getTopRatedMovies(page: 1);
  return response.results.take(10).toList();
});

final upcomingMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  final response = await repository.getUpcomingMovies(page: 1);
  return response.results.take(10).toList();
});
