import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/current_user_provider.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/splash_page.dart';

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
      GoRoute(path: '/map', builder: (_, _) => const _Placeholder(title: 'Xarita')),
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

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — qurilmoqda')),
    );
  }
}
