import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/config/theme_config.dart';
import '../../../favourites/presentation/providers/favourites_provider.dart';
import '../../../watchlist/presentation/providers/watchlist_provider.dart';
import '../../domain/entities/movie.dart';
import 'rating_circle.dart';

class MovieCard extends ConsumerWidget {
  final Movie movie;
  final VoidCallback onTap;
  final Map<int, String>? genresMap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.genresMap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavourite = ref.watch(isFavouriteProvider(movie.id));
    final isInWatchlist = ref.watch(isInWatchlistProvider(movie.id));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Hero(
                    tag: 'movie_poster_${movie.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: movie.posterPath.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl:
                                  ApiConfig.imageUrl(movie.posterPath),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceDark,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.accentGold,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceDark,
                                child: const Icon(
                                  Icons.movie_outlined,
                                  color: AppColors.textMuted,
                                  size: 48,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.surfaceDark,
                              child: const Center(
                                child: Icon(
                                  Icons.movie_outlined,
                                  color: AppColors.textMuted,
                                  size: 48,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        _ActionButton(
                          icon: isFavourite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavourite ? Colors.red : AppColors.textPrimary,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(favouritesProvider.notifier)
                                .toggleFavourite(movie);
                          },
                        ),
                        const SizedBox(height: 8),
                        _ActionButton(
                          icon: isInWatchlist
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isInWatchlist
                              ? AppColors.accentGold
                              : AppColors.textPrimary,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(watchlistProvider.notifier)
                                .toggleWatchlist(movie);
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: 8,
                    child: RatingCircleSmall(rating: movie.voteAverage),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getGenreText(),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGenreText() {
    if (genresMap == null || movie.genreIds.isEmpty) {
      return movie.year;
    }
    final genreNames = movie.genreIds
        .take(2)
        .map((id) => genresMap![id])
        .where((name) => name != null)
        .join(', ');
    if (genreNames.isEmpty) return movie.year;
    return genreNames;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}
