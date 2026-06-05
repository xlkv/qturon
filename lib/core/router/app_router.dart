import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/current_user_provider.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/profile_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/cities/presentation/cities_manage_page.dart';
import '../../features/map/presentation/map_home_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final authValue = ref.read(firebaseAuthStateProvider);
      final isSignedIn = authValue.valueOrNull != null;
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
      GoRoute(path: '/cities', builder: (_, _) => const CitiesManagePage()),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    _sub = ref.listen(firebaseAuthStateProvider, (_, _) => notifyListeners());
  }

  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

