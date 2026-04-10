import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/loan_application_model.dart';
import '../../../../data/providers/service_providers.dart';
import '../../../../data/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../data/models/user_model.dart';
import 'package:flutter/foundation.dart';

// Admin state
class AdminState {
  final bool isLoading;
  final String? error;
  final List<LoanApplicationModel> applications;
  final LoanApplicationModel? selectedApplication;

  const AdminState({
    this.isLoading = false,
    this.error,
    this.applications = const [],
    this.selectedApplication,
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    List<LoanApplicationModel>? applications,
    LoanApplicationModel? selectedApplication,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      applications: applications ?? this.applications,
      selectedApplication: selectedApplication ?? this.selectedApplication,
    );
  }
}

// Admin notifier
class AdminNotifier extends StateNotifier<AdminState> {
  final FirestoreService _firestoreService;
  final String _adminId;

  AdminNotifier(this._firestoreService, this._adminId)
      : super(const AdminState());

  Future<void> deleteApplication(String applicationId) async {
    try {
      await _firestoreService.deleteApplication(applicationId);
      state = state.copyWith(
        applications:
            state.applications.where((a) => a.id != applicationId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      debugPrint('Delete application error: $e');
    }
  }

  Future<void> updateBankVerificationStatus({
    required String userId,
    required String bankAccountId,
    required BankVerificationStatus status,
  }) async {
    await _firestoreService.updateBankVerificationStatus(
      userId: userId,
      bankAccountId: bankAccountId,
      status: status,
    );
  }

  Future<void> updateKycStatus({
    required String userId,
    required VerificationStatus status,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _firestoreService.updateVerificationStatus(userId, status);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint('KYC update error: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Fetch all applications
  Future<void> fetchAllApplications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final applications = await _firestoreService.getAllApplications();
      state = state.copyWith(
        isLoading: false,
        applications: applications,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Select application for review
  void selectApplication(LoanApplicationModel application) {
    state = state.copyWith(selectedApplication: application);
  }

  // Clear selected application
  void clearSelectedApplication() {
    state = state.copyWith(selectedApplication: null);
  }

  // Approve application
  Future<bool> approveApplication({
    required String applicationId,
    String? adminNote,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _firestoreService.updateApplicationStatus(
        applicationId: applicationId,
        status: LoanStatus.approved,
        reviewedBy: _adminId,
        adminNote: adminNote,
      );

      final updatedApplications = state.applications.map((app) {
        if (app.id == applicationId) {
          return app.copyWith(
            status: LoanStatus.approved,
            reviewedBy: _adminId,
            reviewedAt: DateTime.now(),
            adminNote: adminNote,
          );
        }
        return app;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        applications: updatedApplications,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Reject application
  Future<bool> rejectApplication({
    required String applicationId,
    String? adminNote,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _firestoreService.updateApplicationStatus(
        applicationId: applicationId,
        status: LoanStatus.rejected,
        reviewedBy: _adminId,
        adminNote: adminNote,
      );

      final updatedApplications = state.applications.map((app) {
        if (app.id == applicationId) {
          return app.copyWith(
            status: LoanStatus.rejected,
            reviewedBy: _adminId,
            reviewedAt: DateTime.now(),
            adminNote: adminNote,
          );
        }
        return app;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        applications: updatedApplications,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Admin provider
final adminNotifierProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final currentUser = ref.watch(currentUserProvider).value;

  return AdminNotifier(
    firestoreService,
    currentUser?.id ?? '',
  );
});
