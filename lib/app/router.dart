import 'package:aemo_loan_app/features/landing_page/landing_page_desktop.dart';
import 'package:aemo_loan_app/features/landing_page/landing_page_mobile.dart';
import 'package:aemo_loan_app/features/landing_page/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/reset_password.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/user_dashboard.dart';
import '../features/dashboard/screens/kyc_screen.dart';
import '../features/dashboard/screens/user_profile.dart';
import '../features/dashboard/screens/kyc_state.dart';
import '../features/loan_application/screens/loan_application_screen.dart';
import '../features/loan_application/screens/loan_application_submitted.dart';
import '../features/loan_status/screens/application_status_screen.dart';
import '../features/calculator/screens/loan_calculator_screen.dart';
import '../features/admin/screens/admin_dashboard.dart';
import '../features/admin/screens/admin_user_profile.dart';
import '../features/admin/screens/admin_kyc_screen.dart';
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
  static const String profile = '/profile';
  static const String kyc = '/kyc';
  static const String adminUserProfile = '/admin-user-profile';
  static const String reviewKYc = '/review-kyc';
  static const String kycStatus = '/kyc-status';
  static const String resetPassword = '/reset-password';

// In routes list:
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

      final mode = state.uri.queryParameters['mode'];
      final oobCode = state.uri.queryParameters['oobCode'];

      // 🔹 Detect Firebase reset links
      if (mode == 'resetPassword' && oobCode != null) {
        return AppRoutes.resetPassword;
      }
      final isPublicRoute = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.home ||
          location == AppRoutes.calculator ||
          location == AppRoutes.applicationSubmitted ||
          location == AppRoutes.resetPassword;

      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.register;

      if (isLoading) return null;
      if (!isLoggedIn && !isPublicRoute) return AppRoutes.home;
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;

      // Logged in on splash — wait for user profile then redirect
      if (isLoggedIn && isSplash) {
        if (currentUser == null) return null;
        return currentUser.role == 'admin'
            ? AppRoutes.admin
            : AppRoutes.dashboard;
      }

      // Admin user profile route guard — must come before the admin check
      if (location.startsWith(AppRoutes.adminUserProfile)) {
        if (currentUser == null) return null; // wait for user to load
        if (currentUser.role != 'admin') return AppRoutes.dashboard;
        return null; // explicitly allow through
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
        path: AppRoutes.kyc,
        builder: (context, state) => const KycScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.adminUserProfile}/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return AdminUserProfile(userId: userId);
        },
      ),
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
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => ProfileScreen(),
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
              final userId = state.uri.queryParameters['userId'] ?? '';
              return AdminDetailScreen(
                  applicationId: applicationId, userId: userId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.reviewKYc}/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return KycApprovalScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.kycStatus}/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return KycStatusScreen(userId: userId);
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
    ],
  );
});
