import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/group_khatma/presentation/views/create_group_khatma_screen.dart';
import '../../features/group_khatma/presentation/views/group_khatma_detail_screen.dart';
import '../../features/group_khatma/presentation/views/join_group_khatma_screen.dart';
import '../../features/khatma/presentation/views/create_khatma_screen.dart';
import '../../features/khatma/presentation/views/khatma_detail_screen.dart';
import '../../features/khatma/presentation/views/khatma_home_screen.dart';
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
                builder: (context, state) => const KhatmaHomeScreen(),
                // Static segments are listed before ':id' so they match first.
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const CreateKhatmaScreen(),
                  ),
                  GoRoute(
                    path: 'group_new',
                    builder: (context, state) =>
                        const CreateGroupKhatmaScreen(),
                  ),
                  GoRoute(
                    path: 'group_join',
                    builder: (context, state) => const JoinGroupKhatmaScreen(),
                  ),
                  GoRoute(
                    path: 'group/:gid',
                    builder: (context, state) => GroupKhatmaDetailScreen(
                      groupId: state.pathParameters['gid']!,
                    ),
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
