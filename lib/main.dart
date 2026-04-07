import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/movie_repository.dart';
import 'screens/genre_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/watchlist_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(const StreamyApp());
}

class StreamyApp extends StatefulWidget {
  const StreamyApp({super.key});

  @override
  State<StreamyApp> createState() => _StreamyAppState();
}

class _StreamyAppState extends State<StreamyApp> {
  final AppState _appState = AppState();
  final MovieRepository _repository = MovieRepository();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      refreshListenable: _appState,
      redirect: (context, state) {
        final loggingIn = state.matchedLocation == '/login';
        if (!_appState.isLoggedIn && !loggingIn) {
          return '/login';
        }
        if (_appState.isLoggedIn && loggingIn) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) {
            return LoginScreen(
              appState: _appState,
              onSuccess: () => context.go('/'),
            );
          },
        ),
        GoRoute(
          path: '/',
          builder: (context, state) {
            return HomeScreen(
              repository: _repository,
              appState: _appState,
              onOpenMovie: (id) => context.push('/movie/$id'),
              onOpenGenre: (genre) => context.push('/genre/${Uri.encodeComponent(genre)}'),
            );
          },
        ),
        GoRoute(
          path: '/genre/:name',
          builder: (context, state) {
            final name = state.pathParameters['name'] ?? '';
            final genre = Uri.decodeComponent(name);
            return GenreScreen(
              genre: genre,
              repository: _repository,
              onOpenMovie: (id) => context.push('/movie/$id'),
            );
          },
        ),
        GoRoute(
          path: '/favourites',
          builder: (context, state) {
            return WatchlistScreen(
              repository: _repository,
              appState: _appState,
              onOpenMovie: (id) => context.push('/movie/$id'),
            );
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) {
            return ProfileScreen(appState: _appState);
          },
        ),
        GoRoute(
          path: '/watchlist',
          redirect: (context, state) => '/favourites',
        ),
        GoRoute(
          path: '/movie/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final movie = _repository.getMovieById(id);
            if (movie == null) {
              return _NotFoundScreen(id: id);
            }

            return MovieDetailScreen(
              movie: movie,
              repository: _repository,
              appState: _appState,
              onOpenMovie: (movieId) => context.push('/movie/$movieId'),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Streamy',
          debugShowCheckedModeBanner: false,
          themeMode: _appState.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D4ED8), brightness: Brightness.light),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6), brightness: Brightness.dark),
          ),
          routerConfig: _router,
        );
      },
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Text('No movie found for id: $id'),
      ),
    );
  }
}
