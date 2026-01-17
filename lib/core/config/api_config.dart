class ApiConfig {
  static const String apiKey = '';   //use your own api key here
  static const String bearerToken = ''; //use your own bearer token here
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  static String imageUrl(String path, {String size = 'w500'}) {
    return '$imageBaseUrl/$size$path';
  }

  static String backdropUrl(String path) {
    return '$imageBaseUrl/w1280$path';
  }
}
