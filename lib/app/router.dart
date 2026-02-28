import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';

// We'll add screen imports here as we build them
// import '../features/auth/screens/login_screen.dart';
// import '../features/auth/screens/register_screen.dart';
// etc.

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String apply = '/apply';
  static const String status = '/status';
  static const String calculator = '/calculator';
  static const String admin = '/admin';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoading = authState.isLoading;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (isLoading) return null;
      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Screen — Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Register Screen — Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Dashboard — Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.apply,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Apply — Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.calculator,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Calculator — Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Admin — Coming Soon')),
        ),
      ),
    ],
  );
});
