import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../favourites/presentation/providers/favourites_provider.dart';
import '../../../watchlist/presentation/providers/watchlist_provider.dart';
import '../../domain/entities/movie.dart';
import '../providers/movies_provider.dart';
import '../widgets/genre_chip.dart';
import '../widgets/rating_circle.dart';
import '../widgets/shimmer_loading.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieDetailAsync = ref.watch(movieDetailProvider(movieId));

    return Scaffold(
      body: movieDetailAsync.when(
        data: (movie) => _MovieDetailContent(movie: movie),
        loading: () => const MovieDetailShimmer(),
        error: (error, _) => Scaffold(
          appBar: AppBar(backgroundColor: Colors.transparent),
          body: AppErrorWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(movieDetailProvider(movieId)),
          ),
        ),
      ),
    );
  }
}

class _MovieDetailContent extends ConsumerStatefulWidget {
  final MovieDetail movie;

  const _MovieDetailContent({required this.movie});

  @override
  ConsumerState<_MovieDetailContent> createState() => _MovieDetailContentState();
}

class _MovieDetailContentState extends ConsumerState<_MovieDetailContent> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFavourite = ref.watch(isFavouriteProvider(widget.movie.id));
    final isInWatchlist = ref.watch(isInWatchlistProvider(widget.movie.id));

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, isFavourite, isInWatchlist),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, bool isFavourite, bool isInWatchlist) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primaryBackground,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        _ActionButton(
          icon: isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavourite ? Colors.red : AppColors.textPrimary,
          tooltip: isFavourite ? 'Remove from Favourites' : 'Add to Favourites',
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(favouritesProvider.notifier).toggleFavourite(widget.movie);
            _showSnackBar(
              context,
              isFavourite ? 'Removed from Favourites' : 'Added to Favourites',
              isFavourite ? Icons.favorite_border : Icons.favorite,
            );
          },
        ),
        _ActionButton(
          icon: isInWatchlist ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: isInWatchlist ? AppColors.accentGold : AppColors.textPrimary,
          tooltip: isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(watchlistProvider.notifier).toggleWatchlist(widget.movie);
            _showSnackBar(
              context,
              isInWatchlist ? 'Removed from Watchlist' : 'Added to Watchlist',
              isInWatchlist ? Icons.bookmark_border : Icons.bookmark,
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'movie_poster_${widget.movie.id}',
              child: widget.movie.backdropPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ApiConfig.backdropUrl(widget.movie.backdropPath),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.surfaceDark),
                      errorWidget: (_, __, ___) => _buildPosterFallback(),
                    )
                  : _buildPosterFallback(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.primaryBackground.withOpacity(0.7),
                    AppColors.primaryBackground,
                  ],
                  stops: const [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildTitleSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterFallback() {
    return Container(
      color: AppColors.surfaceDark,
      child: widget.movie.posterPath.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: ApiConfig.imageUrl(widget.movie.posterPath),
              fit: BoxFit.cover,
            )
          : const Center(
              child: Icon(Icons.movie_outlined, color: AppColors.textMuted, size: 80),
            ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.movie.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 8),
                ],
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.movie.tagline.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '"${widget.movie.tagline}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.accentGold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickInfo(context),
          const SizedBox(height: 24),
          _buildRatingSection(context),
          const SizedBox(height: 24),
          _buildPlayButton(context),
          const SizedBox(height: 24),
          if (widget.movie.genres.isNotEmpty) ...[
            _buildSectionTitle(context, 'Genres', Icons.category_outlined),
            const SizedBox(height: 12),
            GenreChipList(genres: widget.movie.genres.map((g) => g.name).toList()),
            const SizedBox(height: 24),
          ],
          _buildSectionTitle(context, 'Overview', Icons.description_outlined),
          const SizedBox(height: 12),
          Text(
            widget.movie.overview.isNotEmpty
                ? widget.movie.overview
                : 'No overview available for this movie.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          _buildMovieStats(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentGold, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickInfo(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (widget.movie.releaseDate.isNotEmpty)
            _InfoChip(
              icon: Icons.calendar_today_rounded,
              label: _formatDate(widget.movie.releaseDate),
              color: Colors.blue,
            ),
          if (widget.movie.runtime > 0) ...[
            const SizedBox(width: 12),
            _InfoChip(
              icon: Icons.access_time_rounded,
              label: widget.movie.formattedRuntime,
              color: Colors.green,
            ),
          ],
          if (widget.movie.originalLanguage.isNotEmpty) ...[
            const SizedBox(width: 12),
            _InfoChip(
              icon: Icons.language_rounded,
              label: widget.movie.originalLanguage.toUpperCase(),
              color: Colors.purple,
            ),
          ],
          if (widget.movie.status.isNotEmpty) ...[
            const SizedBox(width: 12),
            _InfoChip(
              icon: Icons.info_outline_rounded,
              label: widget.movie.status,
              color: Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceDark,
            AppColors.surfaceLight.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          RatingCircle(
            rating: widget.movie.voteAverage,
            size: 90,
            lineWidth: 8,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Score',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.movie.voteCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} votes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    final rating = widget.movie.voteAverage / 2;
                    return Icon(
                      index < rating.floor()
                          ? Icons.star
                          : index < rating
                              ? Icons.star_half
                              : Icons.star_border,
                      color: AppColors.accentGold,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isPlaying ? null : () async {
          setState(() => _isPlaying = true);
          HapticFeedback.mediumImpact();
          await NotificationService().showMoviePlayingNotification(widget.movie.title);
          _showSnackBar(
            context,
            '${widget.movie.title} is now playing!',
            Icons.play_circle_filled,
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) setState(() => _isPlaying = false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _isPlaying ? AppColors.surfaceDark : AppColors.accentGold,
          foregroundColor: _isPlaying ? AppColors.accentGold : AppColors.primaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: _isPlaying ? 0 : 4,
        ),
        child: _isPlaying
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Loading...', style: TextStyle(fontSize: 18)),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 32),
                  SizedBox(width: 8),
                  Text('Play Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Widget _buildMovieStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Movie Info', Icons.movie_filter_outlined),
          const SizedBox(height: 16),
          _buildStatRow('Original Title', widget.movie.originalTitle),
          if (widget.movie.budget > 0)
            _buildStatRow('Budget', '\$${_formatNumber(widget.movie.budget)}'),
          if (widget.movie.revenue > 0)
            _buildStatRow('Revenue', '\$${_formatNumber(widget.movie.revenue)}'),
          _buildStatRow('Popularity', widget.movie.popularity.toStringAsFixed(1)),
          _buildStatRow('Adult', widget.movie.adult ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: AppColors.accentGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onTap,
        tooltip: tooltip,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
