import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_datasource.dart';
import '../models/movie_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;

  MovieRepositoryImpl(this._remoteDataSource);

  @override
  Future<MoviesResponse> getPopularMovies({int page = 1}) async {
    return await _remoteDataSource.getPopularMovies(page: page);
  }

  @override
  Future<MoviesResponse> getTopRatedMovies({int page = 1}) async {
    return await _remoteDataSource.getTopRatedMovies(page: page);
  }

  @override
  Future<MoviesResponse> getNowPlayingMovies({int page = 1}) async {
    return await _remoteDataSource.getNowPlayingMovies(page: page);
  }

  @override
  Future<MoviesResponse> getUpcomingMovies({int page = 1}) async {
    return await _remoteDataSource.getUpcomingMovies(page: page);
  }

  @override
  Future<MoviesResponse> searchMovies(String query, {int page = 1}) async {
    return await _remoteDataSource.searchMovies(query, page: page);
  }

  @override
  Future<MovieDetail> getMovieDetails(int movieId) async {
    return await _remoteDataSource.getMovieDetails(movieId);
  }

  @override
  Future<List<Genre>> getGenres() async {
    return await _remoteDataSource.getGenres();
  }

  @override
  Future<MoviesResponse> getMoviesByGenre(int genreId, {int page = 1}) async {
    return await _remoteDataSource.getMoviesByGenre(genreId, page: page);
  }
}
