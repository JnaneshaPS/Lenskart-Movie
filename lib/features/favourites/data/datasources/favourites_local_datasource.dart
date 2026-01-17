import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../movies/domain/entities/movie.dart';

abstract class FavouritesLocalDataSource {
  Future<List<Movie>> getFavourites();
  Future<void> addToFavourites(Movie movie);
  Future<void> removeFromFavourites(int movieId);
  bool isFavourite(int movieId);
  Stream<List<Movie>> watchFavourites();
}

class FavouritesLocalDataSourceImpl implements FavouritesLocalDataSource {
  late Box<MovieHiveModel> _favouritesBox;

  Future<void> init() async {
    _favouritesBox = await Hive.openBox<MovieHiveModel>(
      AppConstants.favouritesBoxName,
    );
  }

  @override
  Future<List<Movie>> getFavourites() async {
    final movies = _favouritesBox.values.toList();
    movies.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return movies.map((e) => e.toMovie()).toList();
  }

  @override
  Future<void> addToFavourites(Movie movie) async {
    final hiveModel = MovieHiveModel.fromMovie(movie);
    await _favouritesBox.put(movie.id, hiveModel);
  }

  @override
  Future<void> removeFromFavourites(int movieId) async {
    await _favouritesBox.delete(movieId);
  }

  @override
  bool isFavourite(int movieId) {
    return _favouritesBox.containsKey(movieId);
  }

  @override
  Stream<List<Movie>> watchFavourites() {
    return _favouritesBox.watch().map((_) {
      final movies = _favouritesBox.values.toList();
      movies.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return movies.map((e) => e.toMovie()).toList();
    });
  }
}
