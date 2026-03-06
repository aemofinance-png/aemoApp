import 'package:aemo_loan_app/features/landing_page/landing_page_desktop.dart';
import 'package:aemo_loan_app/features/landing_page/landing_page_mobile.dart';
import 'package:aemo_loan_app/features/landing_page/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/user_dashboard.dart';
import '../features/loan_application/screens/loan_application_screen.dart';
import '../features/loan_application/screens/loan_application_submitted.dart';
import '../features/loan_status/screens/application_status_screen.dart';
import '../features/calculator/screens/loan_calculator_screen.dart';
import '../features/admin/screens/admin_dashboard.dart';
import '../data/models/loan_application_model.dart';
import '../features/admin/screens/admin_detail_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String apply = '/apply';
  static const String status = '/status';
  static const String calculator = '/calculator';
  static const String admin = '/admin';
  static const String applicationSubmitted = '/application-submitted';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider).value;

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoading = authState.isLoading;
      final location = state.matchedLocation;
      final isSplash = location == AppRoutes.home;
      final isPublicRoute = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.home ||
          location == AppRoutes.calculator ||
          location == AppRoutes.applicationSubmitted;

      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.register;

      if (isLoading) return null;
      // if (!isLoggedIn && !isAuthRoute) return AppRoutes.home;
      if (!isLoggedIn && !isPublicRoute) return AppRoutes.home;
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;

      // Logged in on splash — wait for user profile then redirect
      if (isLoggedIn && isSplash) {
        if (currentUser == null) return null; // 👈 wait for profile
        return currentUser.role == 'admin'
            ? AppRoutes.admin
            : AppRoutes.dashboard;
      }

      // Admin route check
      if (location.startsWith(AppRoutes.admin)) {
        if (currentUser == null) return null;
        if (currentUser.role != 'admin') return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const ResponsiveLayout(
                mobileLayout: LandingPageMobile(),
                desktopLayout: LandingPage(),
              )),
      GoRoute(
        path: AppRoutes.applicationSubmitted,
        builder: (context, state) => ApplicationSubmittedScreen(
          application: state.extra as LoanApplicationModel,
        ),
      ),
      // GoRoute(
      //   path: AppRoutes.splash,
      //   builder: (context, state) => const Scaffold(
      //     body: Center(child: CircularProgressIndicator()),
      //   ),
      // ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const UserDashboard(),
      ),
      GoRoute(
        path: AppRoutes.apply,
        builder: (context, state) => const LoanApplicationScreen(),
      ),
      GoRoute(
        path: AppRoutes.calculator,
        builder: (context, state) => const LoanCalculatorScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.status}/:id',
        builder: (context, state) {
          final applicationId = state.pathParameters['id']!;
          return ApplicationStatusScreen(applicationId: applicationId);
        },
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminDashboard(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final applicationId = state.pathParameters['id']!;
              return AdminDetailScreen(applicationId: applicationId);
            },
          ),
        ],
      ),
    ],
  );
});
