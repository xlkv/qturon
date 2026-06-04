import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _Placeholder(title: 'Splash')),
      GoRoute(path: '/login', builder: (_, _) => const _Placeholder(title: 'Login')),
      GoRoute(path: '/map', builder: (_, _) => const _Placeholder(title: 'Map')),
    ],
  );
});

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title — qurilmoqda'),
      ),
    );
  }
}
