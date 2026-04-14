import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/main_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          bottomNavigationBar: const MainBottomNav(currentIndex: 2),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 42,
                child: Text(
                  appState.username.isNotEmpty ? appState.username.characters.first.toUpperCase() : 'U',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                appState.username,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _ProfileTile(title: 'Watchlist items', value: appState.watchlistCount.toString()),
              _ProfileTile(title: 'Watched titles', value: appState.watchedCount.toString()),
              _ProfileTile(title: 'Current streak', value: '${appState.currentStreakDays} days'),
              _ProfileTile(title: 'Longest streak', value: '${appState.longestStreakDays} days'),
              _ProfileTile(title: 'Reviews written', value: appState.totalReviewsCount.toString()),
              _ProfileTile(title: 'Saved watch plans', value: appState.plans.length.toString()),
              const SizedBox(height: 18),
              Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...appState.achievements.map(
                (achievement) => Card(
                  child: ListTile(
                    leading: Icon(
                      achievement.unlocked ? Icons.emoji_events : Icons.lock_outline,
                      color: achievement.unlocked ? Colors.amber[700] : null,
                    ),
                    title: Text(achievement.title),
                    subtitle: Text(achievement.description),
                    trailing: Text('${achievement.progress}/${achievement.target}'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: appState.toggleTheme,
                icon: Icon(appState.themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                label: Text(appState.themeMode == ThemeMode.dark ? 'Switch to Light Theme' : 'Switch to Dark Theme'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: appState.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
