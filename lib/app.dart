import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/home_shell.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/splash_screen.dart';

class AbyssiniaLearnApp extends StatelessWidget {
  const AbyssiniaLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abyssinia Learn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _RootGate(),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthProvider, AuthStatus>((a) => a.status);
    final Widget child;
    switch (status) {
      case AuthStatus.unknown:
        child = const SplashScreen(key: ValueKey('splash'));
        break;
      case AuthStatus.authenticated:
        child = const HomeShell(key: ValueKey('home'));
        break;
      case AuthStatus.unauthenticated:
        child = const LoginScreen(key: ValueKey('login'));
        break;
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: child,
    );
  }
}
