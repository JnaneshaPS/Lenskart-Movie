import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<MoviesResponse> getPopularMovies({int page = 1});
  Future<MoviesResponse> getTopRatedMovies({int page = 1});
  Future<MoviesResponse> getNowPlayingMovies({int page = 1});
  Future<MoviesResponse> getUpcomingMovies({int page = 1});
  Future<MoviesResponse> searchMovies(String query, {int page = 1});
  Future<MovieDetailModel> getMovieDetails(int movieId);
  Future<List<GenreModel>> getGenres();
  Future<MoviesResponse> getMoviesByGenre(int genreId, {int page = 1});
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient _dioClient;

  MovieRemoteDataSourceImpl(this._dioClient);

  @override
  Future<MoviesResponse> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.popularMovies,
        queryParameters: {'page': page},
      );
      return MoviesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<MoviesResponse> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.topRatedMovies,
        queryParameters: {'page': page},
      );
      return MoviesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<MoviesResponse> getNowPlayingMovies({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.nowPlayingMovies,
        queryParameters: {'page': page},
      );
      return MoviesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<MoviesResponse> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.upcomingMovies,
        queryParameters: {'page': page},
      );
      return MoviesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<MoviesResponse> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.searchMovies,
        queryParameters: {'query': query, 'page': page},
      );
      return MoviesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<MovieDetailModel> getMovieDetails(int movieId) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.movieById(movieId));
      return MovieDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<GenreModel>> getGenres() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.genresList);
      final genres = (response.data['genres'] as List<dynamic>)
          .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return genres;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<MoviesResponse> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.discoverMovies,
        queryParameters: {
          'with_genres': genreId,
          'page': page,
          'sort_by': 'popularity.desc',
        },
      );
      return MoviesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return NotFoundException(message: 'Movie not found.');
        }
        return ServerException(
          message: 'Server error occurred.',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return NetworkException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection. Please check your network.',
        );
      default:
        return NetworkException(message: 'Something went wrong. Please try again.');
    }
  }
}
