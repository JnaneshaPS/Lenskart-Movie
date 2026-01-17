import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/utils/notification_service.dart';
import 'features/movies/data/models/movie_model.dart';
import 'features/favourites/data/datasources/favourites_local_datasource.dart';
import 'features/favourites/presentation/providers/favourites_provider.dart';
import 'features/watchlist/data/datasources/watchlist_local_datasource.dart';
import 'features/watchlist/presentation/providers/watchlist_provider.dart';

late FavouritesLocalDataSourceImpl _favouritesDataSource;
late WatchlistLocalDataSourceImpl _watchlistDataSource;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initializeHive();
  await _initializeNotifications();

  runApp(
    ProviderScope(
      overrides: [
        favouritesLocalDataSourceProvider.overrideWithValue(_favouritesDataSource),
        watchlistLocalDataSourceProvider.overrideWithValue(_watchlistDataSource),
      ],
      child: const MovieApp(),
    ),
  );
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(MovieHiveModelAdapter());

  _favouritesDataSource = FavouritesLocalDataSourceImpl();
  await _favouritesDataSource.init();

  _watchlistDataSource = WatchlistLocalDataSourceImpl();
  await _watchlistDataSource.init();
}

Future<void> _initializeNotifications() async {
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();
}
