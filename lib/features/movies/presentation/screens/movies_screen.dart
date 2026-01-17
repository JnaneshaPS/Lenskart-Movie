import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../domain/entities/movie.dart';
import '../providers/movies_provider.dart';
import '../widgets/genre_chip.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_search_bar.dart';
import '../widgets/rating_circle.dart';
import '../widgets/shimmer_loading.dart';
import 'movie_detail_screen.dart';

class MoviesScreen extends ConsumerStatefulWidget {
  const MoviesScreen({super.key});

  @override
  ConsumerState<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends ConsumerState<MoviesScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final categories = [
      MovieCategory.popular,
      MovieCategory.topRated,
      MovieCategory.nowPlaying,
      MovieCategory.upcoming,
    ];
    ref.read(moviesProvider.notifier).selectCategory(categories[_tabController.index]);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(moviesProvider.notifier).loadMoreMovies();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToDetail(int movieId) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MovieDetailScreen(movieId: movieId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _onGenreSelected(int? genreId) {
    HapticFeedback.selectionClick();
    ref.read(moviesProvider.notifier).selectGenre(genreId);
    if (genreId != null) {
      _tabController.index = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final moviesState = ref.watch(moviesProvider);
    final genresAsync = ref.watch(genresMapProvider);
    final genresList = ref.watch(genresProvider);

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildHeader(context)),
              if (_showSearch)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: MovieSearchBar(
                      onSearch: (query) => ref.read(moviesProvider.notifier).searchMovies(query),
                      onClear: () => ref.read(moviesProvider.notifier).clearSearch(),
                      initialValue: moviesState.searchQuery,
                    ),
                  ),
                ),
              if (!_showSearch && moviesState.searchQuery.isEmpty && moviesState.selectedGenreId == null) ...[
                SliverToBoxAdapter(child: _buildFeaturedCarousel(context)),
                SliverToBoxAdapter(
                  child: _buildHorizontalSection(
                    context,
                    'Now Playing',
                    ref.watch(nowPlayingMoviesProvider),
                    Icons.play_circle_outline,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildHorizontalSection(
                    context,
                    'Top Rated',
                    ref.watch(topRatedMoviesProvider),
                    Icons.star_outline,
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    _getSectionTitle(moviesState),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: genresList.when(
                  data: (genres) => GenreFilterBar(
                    genres: genres.map((g) => MapEntry(g.id, g.name)).toList(),
                    selectedGenreId: moviesState.selectedGenreId,
                    onGenreSelected: _onGenreSelected,
                  ),
                  loading: () => const SizedBox(height: 40),
                  error: (_, __) => const SizedBox(height: 40),
                ),
              ),
              if (!_showSearch && moviesState.searchQuery.isEmpty && moviesState.selectedGenreId == null)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategoryTabDelegate(tabController: _tabController),
                ),
            ];
          },
          body: _buildContent(moviesState, genresAsync),
        ),
      ),
    );
  }

  String _getSectionTitle(MoviesState state) {
    if (state.searchQuery.isNotEmpty) return 'Search Results';
    if (state.selectedGenreId != null) {
      final genresMap = ref.read(genresMapProvider).valueOrNull ?? {};
      final genreName = genresMap[state.selectedGenreId] ?? 'Genre';
      return '$genreName Movies';
    }
    return 'Browse All';
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CineVault',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text('Discover amazing movies', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) ref.read(moviesProvider.notifier).clearSearch();
              });
            },
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: AppColors.accentGold,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarousel(BuildContext context) {
    final trendingAsync = ref.watch(trendingMoviesProvider);

    return trendingAsync.when(
      data: (movies) {
        if (movies.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Trending Now',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return _FeaturedMovieCard(movie: movie, onTap: () => _navigateToDetail(movie.id));
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildHorizontalSection(
    BuildContext context,
    String title,
    AsyncValue<List<Movie>> moviesAsync,
    IconData icon,
  ) {
    return moviesAsync.when(
      data: (movies) {
        if (movies.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.accentGold, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return _HorizontalMovieCard(movie: movie, onTap: () => _navigateToDetail(movie.id));
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 220),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(MoviesState moviesState, AsyncValue<Map<int, String>> genresAsync) {
    if (moviesState.isLoading && moviesState.movies.isEmpty) {
      return const MovieGridShimmer();
    }

    if (moviesState.error != null && moviesState.movies.isEmpty) {
      return AppErrorWidget(
        message: moviesState.error!,
        onRetry: () => ref.read(moviesProvider.notifier).refresh(),
      );
    }

    if (moviesState.movies.isEmpty) {
      return EmptyStateWidget(
        title: 'No Movies Found',
        message: moviesState.searchQuery.isNotEmpty
            ? 'Try a different search term'
            : 'Unable to load movies',
        icon: Icons.movie_filter_outlined,
        actionLabel: 'Refresh',
        onAction: () => ref.read(moviesProvider.notifier).refresh(),
      );
    }

    final genresMap = genresAsync.valueOrNull ?? {};

    return RefreshIndicator(
      onRefresh: () => ref.read(moviesProvider.notifier).refresh(),
      color: AppColors.accentGold,
      backgroundColor: AppColors.surfaceDark,
      child: AnimationLimiter(
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: moviesState.movies.length + (moviesState.isLoadingMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= moviesState.movies.length) {
              return const MovieCardShimmer();
            }

            final movie = moviesState.movies[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: _getCrossAxisCount(context),
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: MovieCard(
                    movie: movie,
                    genresMap: genresMap,
                    onTap: () => _navigateToDetail(movie.id),
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

class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _CategoryTabDelegate({required this.tabController});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.primaryBackground,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        indicatorColor: AppColors.accentGold,
        labelColor: AppColors.accentGold,
        unselectedLabelColor: AppColors.textMuted,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: const [
          Tab(text: 'Popular'),
          Tab(text: 'Top Rated'),
          Tab(text: 'Now Playing'),
          Tab(text: 'Upcoming'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _FeaturedMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _FeaturedMovieCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              movie.backdropPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ApiConfig.backdropUrl(movie.backdropPath),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.surfaceDark),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceDark,
                        child: const Icon(Icons.movie, color: AppColors.textMuted, size: 48),
                      ),
                    )
                  : Container(color: AppColors.surfaceDark),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            movie.year,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    RatingCircleSmall(rating: movie.voteAverage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalMovieCard extends ConsumerWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _HorizontalMovieCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      movie.posterPath.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: ApiConfig.imageUrl(movie.posterPath),
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: AppColors.surfaceDark),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.surfaceDark,
                                child: const Icon(Icons.movie, color: AppColors.textMuted),
                              ),
                            )
                          : Container(color: AppColors.surfaceDark),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBackground.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: AppColors.accentGold, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(movie.year, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
