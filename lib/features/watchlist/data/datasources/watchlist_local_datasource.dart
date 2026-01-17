import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../movies/domain/entities/movie.dart';

abstract class WatchlistLocalDataSource {
  Future<List<Movie>> getWatchlist();
  Future<void> addToWatchlist(Movie movie);
  Future<void> removeFromWatchlist(int movieId);
  bool isInWatchlist(int movieId);
  Stream<List<Movie>> watchWatchlist();
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  late Box<MovieHiveModel> _watchlistBox;

  Future<void> init() async {
    _watchlistBox = await Hive.openBox<MovieHiveModel>(
      AppConstants.watchlistBoxName,
    );
  }

  @override
  Future<List<Movie>> getWatchlist() async {
    final movies = _watchlistBox.values.toList();
    movies.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return movies.map((e) => e.toMovie()).toList();
  }

  @override
  Future<void> addToWatchlist(Movie movie) async {
    final hiveModel = MovieHiveModel.fromMovie(movie);
    await _watchlistBox.put(movie.id, hiveModel);
  }

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    await _watchlistBox.delete(movieId);
  }

  @override
  bool isInWatchlist(int movieId) {
    return _watchlistBox.containsKey(movieId);
  }

  @override
  Stream<List<Movie>> watchWatchlist() {
    return _watchlistBox.watch().map((_) {
      final movies = _watchlistBox.values.toList();
      movies.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return movies.map((e) => e.toMovie()).toList();
    });
  }
}
