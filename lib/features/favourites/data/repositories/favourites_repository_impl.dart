import '../../../movies/domain/entities/movie.dart';
import '../datasources/favourites_local_datasource.dart';

abstract class FavouritesRepository {
  Future<List<Movie>> getFavourites();
  Future<void> addToFavourites(Movie movie);
  Future<void> removeFromFavourites(int movieId);
  bool isFavourite(int movieId);
  Stream<List<Movie>> watchFavourites();
}

class FavouritesRepositoryImpl implements FavouritesRepository {
  final FavouritesLocalDataSource _localDataSource;

  FavouritesRepositoryImpl(this._localDataSource);

  @override
  Future<List<Movie>> getFavourites() async {
    return await _localDataSource.getFavourites();
  }

  @override
  Future<void> addToFavourites(Movie movie) async {
    await _localDataSource.addToFavourites(movie);
  }

  @override
  Future<void> removeFromFavourites(int movieId) async {
    await _localDataSource.removeFromFavourites(movieId);
  }

  @override
  bool isFavourite(int movieId) {
    return _localDataSource.isFavourite(movieId);
  }

  @override
  Stream<List<Movie>> watchFavourites() {
    return _localDataSource.watchFavourites();
  }
}
