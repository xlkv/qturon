import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../data/auth_repository.dart';

enum SplashResult { needLogin, ready }

class SplashController extends AsyncNotifier<SplashResult?> {
  @override
  Future<SplashResult?> build() async => null;

  Future<void> bootstrap() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final logger = ref.read(loggerProvider);
      debugPrint('[splash] bootstrap start');
      try {
        final ok = await repo.trySilentLogin();
        debugPrint('[splash] trySilentLogin -> $ok');
        logger.info('splash.silent_login', {'ok': ok});
        return ok ? SplashResult.ready : SplashResult.needLogin;
      } catch (e, st) {
        debugPrint('[splash] ERROR: $e\n$st');
        return SplashResult.needLogin;
      }
    });
  }
}

final splashControllerProvider =
    AsyncNotifierProvider<SplashController, SplashResult?>(SplashController.new);
