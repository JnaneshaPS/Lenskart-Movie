import '../entities/movie.dart';
import '../../data/models/movie_model.dart';

abstract class MovieRepository {
  Future<MoviesResponse> getPopularMovies({int page = 1});
  Future<MoviesResponse> getTopRatedMovies({int page = 1});
  Future<MoviesResponse> getNowPlayingMovies({int page = 1});
  Future<MoviesResponse> getUpcomingMovies({int page = 1});
  Future<MoviesResponse> searchMovies(String query, {int page = 1});
  Future<MovieDetail> getMovieDetails(int movieId);
  Future<List<Genre>> getGenres();
  Future<MoviesResponse> getMoviesByGenre(int genreId, {int page = 1});
}
