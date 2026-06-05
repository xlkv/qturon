import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/geo_point.dart' show GeoPoint;
import '../../features/auth/application/current_user_provider.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/profile_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/map/presentation/map_home_page.dart';
import '../../features/masters/presentation/masters_manage_page.dart';
import '../../features/pipes/presentation/pipe_create_edit_page.dart';
import '../../features/pipes/presentation/pipe_detail_page.dart';
import '../../features/users/presentation/users_manage_page.dart';
import '../../features/wells/presentation/well_create_edit_page.dart';
import '../../features/wells/presentation/well_detail_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final isSignedIn = ref.read(authStateProvider).valueOrNull != null;
      final loc = state.matchedLocation;
      final atSplash = loc == '/splash';
      final atLogin = loc == '/login';

      if (atSplash) return null;
      if (!isSignedIn && !atLogin) return '/login';
      if (isSignedIn && atLogin) return '/map';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/map', builder: (_, _) => const MapHomePage()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
      GoRoute(path: '/masters', builder: (_, _) => const MastersManagePage()),
      GoRoute(path: '/users', builder: (_, _) => const UsersManagePage()),
      GoRoute(path: '/wells/new', builder: (context, state) {
        final extra = state.extra as Map<String, double>?;
        return WellCreateEditPage(initialLat: extra?['lat'], initialLng: extra?['lng']);
      }),
      GoRoute(
        path: '/wells/:wellId',
        builder: (_, state) => WellDetailPage(wellId: state.pathParameters['wellId']!),
      ),
      GoRoute(
        path: '/wells/:wellId/edit',
        builder: (_, state) => WellCreateEditPage(wellId: state.pathParameters['wellId']),
      ),
      GoRoute(
        path: '/pipes/new',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final raw = (extra?['points'] as List?) ?? const [];
          final points = <GeoPoint>[];
          for (final s in raw.whereType<String>()) {
            final parts = s.split(',');
            if (parts.length == 2) {
              final lat = double.tryParse(parts[0]);
              final lng = double.tryParse(parts[1]);
              if (lat != null && lng != null) points.add(GeoPoint(lat, lng));
            }
          }
          return PipeCreateEditPage(initialPoints: points);
        },
      ),
      GoRoute(
        path: '/pipes/:pipeId',
        builder: (_, state) => PipeDetailPage(pipeId: state.pathParameters['pipeId']!),
      ),
      GoRoute(
        path: '/pipes/:pipeId/edit',
        builder: (_, state) => PipeCreateEditPage(pipeId: state.pathParameters['pipeId']),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    _sub = ref.listen(authStateProvider, (_, _) => notifyListeners());
  }

  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
