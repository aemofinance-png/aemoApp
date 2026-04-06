import 'package:aemo_loan_app/core/utils/email_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/service_providers.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../data/services/firestore_service.dart';

// Stream of Firebase auth state
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user profile from Firestore
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      final firestoreService = ref.watch(firestoreServiceProvider);
      final result = await firestoreService.getUser(user.uid);
      // 👈 add this
      return result;
    },
    loading: () {
      return null;
    },
    error: (e, _) {
      print('Auth state error: $e'); // 👈 add this
      return null;
    },
  );
});

// Auth state class
class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthNotifier(this._authService, this._firestoreService)
      : super(const AuthState());

  // Register
  Future<bool> register({
    required String email,
    required String streetAddress,
    required String city,
    required String countryName,
    required String stateProvince,
    required String postalCode,
    required String password,
    required String fullName,
    required String phone,
    required String countryCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.register(
        email: email,
        password: password,
      );

      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'Registration failed.');
        return false;
      }

      await _firestoreService.saveUser(
        UserModel(
          id: user.uid,
          fullName: fullName,
          streetAddress: streetAddress,
          city: city,
          state: stateProvince,
          countryName: countryName,
          postalCode: postalCode,
          email: email,
          phone: phone,
          countryCode: countryCode,
          role: 'user',
          createdAt: DateTime.now(),
        ),
      );

      await EmailService.sendWelcomeEmail(
        toEmail: email,
        toName: fullName,
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _authService.resetPassword(email);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );

      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'Login failed.');
        return false;
      }

      /// Fetch user profile from Firestore
      final profile = await _firestoreService.getUser(user.uid);

      state = state.copyWith(isLoading: false);

      /// Return role info indirectly using result
      return profile?.role == 'admin';
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = state.copyWith(isLoading: false);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth notifier provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});
