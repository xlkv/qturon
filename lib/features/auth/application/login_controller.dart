import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../data/auth_repository.dart';

class LoginState {
  const LoginState({
    this.input = '',
    this.isLoading = false,
    this.error,
    this.rememberMe = true,
    this.success = false,
  });

  final String input;
  final bool isLoading;
  final String? error;
  final bool rememberMe;
  final bool success;

  LoginState copyWith({
    String? input,
    bool? isLoading,
    Object? error = _sentinel,
    bool? rememberMe,
    bool? success,
  }) {
    return LoginState(
      input: input ?? this.input,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
      rememberMe: rememberMe ?? this.rememberMe,
      success: success ?? this.success,
    );
  }
}

const _sentinel = Object();

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void appendDigit(String digit) {
    if (state.isLoading) return;
    if (state.input.length >= 6) return;
    final next = state.input + digit;
    state = state.copyWith(input: next, error: null);
    if (next.length == 6) {
      _submit();
    }
  }

  void backspace() {
    if (state.isLoading) return;
    if (state.input.isEmpty) return;
    state = state.copyWith(
      input: state.input.substring(0, state.input.length - 1),
      error: null,
    );
  }

  void clear() {
    if (state.isLoading) return;
    state = state.copyWith(input: '', error: null);
  }

  void setRememberMe(bool v) {
    state = state.copyWith(rememberMe: v);
  }

  Future<void> _submit() async {
    state = state.copyWith(isLoading: true, error: null);
    final logger = ref.read(loggerProvider);
    try {
      await ref.read(authRepositoryProvider).signInWithPassKey(
            state.input,
            remember: state.rememberMe,
          );
      logger.info('auth.login_success');
      state = state.copyWith(isLoading: false, success: true);
    } on AppException catch (e) {
      logger.warn('auth.login_failed', {'code': e.code});
      state = state.copyWith(
        isLoading: false,
        input: '',
        error: e.message ?? _defaultErrorMessage(e.code),
      );
    } catch (e, st) {
      logger.error('auth.login_error', e, st);
      state = state.copyWith(
        isLoading: false,
        input: '',
        error: 'Kutilmagan xatolik. Qaytadan urinib ko\'ring.',
      );
    }
  }

  String _defaultErrorMessage(String code) {
    switch (code) {
      case 'network':
        return 'Internet ulanish yo\'q.';
      case 'pass_key_not_found':
        return 'Noto\'g\'ri kod.';
      case 'rate_limited':
        return 'Juda ko\'p urinish. Keyinroq qayta urining.';
      default:
        return 'Xatolik yuz berdi.';
    }
  }
}

final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(LoginController.new);
