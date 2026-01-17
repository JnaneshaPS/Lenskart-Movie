import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../movies/presentation/providers/movies_provider.dart';
import '../../../movies/presentation/screens/movie_detail_screen.dart';
import '../../../movies/presentation/widgets/movie_card.dart';
import '../../../movies/presentation/widgets/shimmer_loading.dart';
import '../providers/watchlist_provider.dart';

enum SortOption { dateAdded, rating, title, year }

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  SortOption _sortOption = SortOption.dateAdded;
  bool _sortAscending = false;

  List<Movie> _sortMovies(List<Movie> movies) {
    final sorted = List<Movie>.from(movies);
    switch (_sortOption) {
      case SortOption.dateAdded:
        break;
      case SortOption.rating:
        sorted.sort((a, b) => _sortAscending 
            ? a.voteAverage.compareTo(b.voteAverage)
            : b.voteAverage.compareTo(a.voteAverage));
        break;
      case SortOption.title:
        sorted.sort((a, b) => _sortAscending 
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case SortOption.year:
        sorted.sort((a, b) => _sortAscending 
            ? a.releaseDate.compareTo(b.releaseDate)
            : b.releaseDate.compareTo(a.releaseDate));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final watchlistState = ref.watch(watchlistProvider);
    final genresAsync = ref.watch(genresMapProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, watchlistState),
            if (watchlistState.movies.isNotEmpty) _buildSortBar(context),
            const SizedBox(height: 8),
            Expanded(
              child: _buildContent(context, watchlistState, genresAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WatchlistState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bookmark_rounded, color: AppColors.accentGold, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watchlist',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  state.movies.isEmpty
                      ? 'Nothing to watch yet'
                      : '${state.movies.length} movie${state.movies.length != 1 ? 's' : ''} to watch',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.sort, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 8),
          const Text('Sort by:', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<SortOption>(
              value: _sortOption,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: AppColors.surfaceDark,
              style: const TextStyle(color: AppColors.textPrimary),
              items: const [
                DropdownMenuItem(value: SortOption.dateAdded, child: Text('Date Added')),
                DropdownMenuItem(value: SortOption.rating, child: Text('Rating')),
                DropdownMenuItem(value: SortOption.title, child: Text('Title')),
                DropdownMenuItem(value: SortOption.year, child: Text('Year')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sortOption = value);
              },
            ),
          ),
          IconButton(
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppColors.accentGold,
              size: 20,
            ),
            onPressed: () => setState(() => _sortAscending = !_sortAscending),
            tooltip: _sortAscending ? 'Ascending' : 'Descending',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WatchlistState watchlistState,
    AsyncValue<Map<int, String>> genresAsync,
  ) {
    if (watchlistState.isLoading && watchlistState.movies.isEmpty) {
      return const MovieGridShimmer();
    }

    if (watchlistState.error != null && watchlistState.movies.isEmpty) {
      return AppErrorWidget(
        message: watchlistState.error!,
        onRetry: () => ref.read(watchlistProvider.notifier).loadWatchlist(),
      );
    }

    if (watchlistState.movies.isEmpty) {
      return EmptyStateWidget(
        title: 'Watchlist Empty',
        message: 'Add movies you want to watch later.\nThey\'ll be waiting for you here!',
        icon: Icons.bookmark_border_rounded,
      );
    }

    final genresMap = genresAsync.valueOrNull ?? {};
    final sortedMovies = _sortMovies(watchlistState.movies);

    return RefreshIndicator(
      onRefresh: () => ref.read(watchlistProvider.notifier).loadWatchlist(),
      color: AppColors.accentGold,
      backgroundColor: AppColors.surfaceDark,
      child: AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: sortedMovies.length,
          itemBuilder: (context, index) {
            final movie = sortedMovies[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: _getCrossAxisCount(context),
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: Dismissible(
                    key: ValueKey(movie.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: AppColors.primaryBackground, size: 32),
                          SizedBox(height: 4),
                          Text('Watched', style: TextStyle(color: AppColors.primaryBackground, fontSize: 12)),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.surfaceDark,
                          title: const Text('Remove from Watchlist?'),
                          content: Text('Mark "${movie.title}" as watched and remove?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: AppColors.accentGold),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      ref.read(watchlistProvider.notifier).removeFromWatchlist(movie.id);
                    },
                    child: MovieCard(
                      movie: movie,
                      genresMap: genresMap,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movieId: movie.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 3;
    if (width > 400) return 2;
    return 2;
  }
}
