class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final List<int> genreIds;
  final double popularity;
  final bool adult;
  final String originalLanguage;
  final String originalTitle;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genreIds,
    required this.popularity,
    required this.adult,
    required this.originalLanguage,
    required this.originalTitle,
  });

  String get year {
    if (releaseDate.isEmpty) return '';
    return releaseDate.split('-').first;
  }

  int get ratingPercentage => (voteAverage * 10).round();

  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    String? releaseDate,
    List<int>? genreIds,
    double? popularity,
    bool? adult,
    String? originalLanguage,
    String? originalTitle,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
      genreIds: genreIds ?? this.genreIds,
      popularity: popularity ?? this.popularity,
      adult: adult ?? this.adult,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      originalTitle: originalTitle ?? this.originalTitle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Movie && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Genre {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});
}

class MovieDetail extends Movie {
  final List<Genre> genres;
  final int runtime;
  final String status;
  final String tagline;
  final int budget;
  final int revenue;
  final String? homepage;

  const MovieDetail({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.backdropPath,
    required super.voteAverage,
    required super.voteCount,
    required super.releaseDate,
    required super.genreIds,
    required super.popularity,
    required super.adult,
    required super.originalLanguage,
    required super.originalTitle,
    required this.genres,
    required this.runtime,
    required this.status,
    required this.tagline,
    required this.budget,
    required this.revenue,
    this.homepage,
  });

  String get formattedRuntime {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
