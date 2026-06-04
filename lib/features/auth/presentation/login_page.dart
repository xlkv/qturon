import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/login_controller.dart';
import 'widgets/numeric_keypad.dart';
import 'widgets/pin_input.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final ch = event.character;
    final ctrl = ref.read(loginControllerProvider.notifier);
    if (ch != null && RegExp(r'\d').hasMatch(ch)) {
      ctrl.appendDigit(ch);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      ctrl.backspace();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginControllerProvider, (prev, next) {
      if (next.success && (prev?.success ?? false) == false) {
        context.go('/map');
      }
    });

    final state = ref.watch(loginControllerProvider);
    final ctrl = ref.read(loginControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: _onKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LogoMini(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Tizimga kiring',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '6 xonali kirish kodi',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PinInput(
                      value: state.input,
                      hasError: state.error != null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 20,
                      child: state.error != null
                          ? Text(
                              state.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            )
                          : null,
                    ),
                    if (state.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    else
                      const SizedBox(height: AppSpacing.xl + AppSpacing.md),
                    NumericKeypad(
                      onDigit: ctrl.appendDigit,
                      onBackspace: ctrl.backspace,
                      enabled: !state.isLoading,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SwitchListTile.adaptive(
                      value: state.rememberMe,
                      onChanged: state.isLoading ? null : ctrl.setRememberMe,
                      title: const Text('Meni eslab qol'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoMini extends StatelessWidget {
  const _LogoMini();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.brand,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'TS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
