class ApiEndpoints {
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String upcomingMovies = '/movie/upcoming';
  static const String searchMovies = '/search/movie';
  static const String movieDetails = '/movie';
  static const String genresList = '/genre/movie/list';
  static const String discoverMovies = '/discover/movie';

  static String movieById(int id) => '/movie/$id';
  static String movieCredits(int id) => '/movie/$id/credits';
  static String movieVideos(int id) => '/movie/$id/videos';
  static String similarMovies(int id) => '/movie/$id/similar';
}
