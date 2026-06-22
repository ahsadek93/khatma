import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/khatma/presentation/views/create_khatma_screen.dart';
import '../../features/khatma/presentation/views/khatma_detail_screen.dart';
import '../../features/khatma/presentation/views/khatma_list_screen.dart';
import '../../features/settings/presentation/views/settings_screen.dart';
import '../../features/wird/presentation/views/wird_list_screen.dart';
import '../presentation/home_shell.dart';

/// Application router. A [StatefulShellRoute] gives each bottom-nav tab its own
/// navigation stack while keeping the shell (bottom bar) persistent.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/khatma',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/khatma',
                builder: (context, state) => const KhatmaListScreen(),
                routes: [
                  // Static 'new' is listed before ':id' so it matches first.
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const CreateKhatmaScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => KhatmaDetailScreen(
                      khatmaId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wird',
                builder: (context, state) => const WirdListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
