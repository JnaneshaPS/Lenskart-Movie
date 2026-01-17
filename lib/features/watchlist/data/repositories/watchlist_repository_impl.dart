import '../../../movies/domain/entities/movie.dart';
import '../datasources/watchlist_local_datasource.dart';

abstract class WatchlistRepository {
  Future<List<Movie>> getWatchlist();
  Future<void> addToWatchlist(Movie movie);
  Future<void> removeFromWatchlist(int movieId);
  bool isInWatchlist(int movieId);
  Stream<List<Movie>> watchWatchlist();
}

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource _localDataSource;

  WatchlistRepositoryImpl(this._localDataSource);

  @override
  Future<List<Movie>> getWatchlist() async {
    return await _localDataSource.getWatchlist();
  }

  @override
  Future<void> addToWatchlist(Movie movie) async {
    await _localDataSource.addToWatchlist(movie);
  }

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    await _localDataSource.removeFromWatchlist(movieId);
  }

  @override
  bool isInWatchlist(int movieId) {
    return _localDataSource.isInWatchlist(movieId);
  }

  @override
  Stream<List<Movie>> watchWatchlist() {
    return _localDataSource.watchWatchlist();
  }
}
