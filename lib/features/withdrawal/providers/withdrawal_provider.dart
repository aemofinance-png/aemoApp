import 'package:aemo_loan_app/data/models/loan_application_model.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:aemo_loan_app/data/models/withdrawal_model.dart';
import 'package:aemo_loan_app/data/providers/service_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'withdrawal_provider.g.dart';

class WithdrawalState {
  final int currentStep;
  final BankAccount? selectedAccount;
  final PlatformFile? uploadedDocument;
  final bool isUploading;
  final String? uploadedUrl;
  final LoanApplicationModel? application;
  final bool isLoadingApplication;
  final bool isSubmittingWithdrawal;

  WithdrawalState({
    this.currentStep = 0,
    this.selectedAccount,
    this.uploadedDocument,
    this.isUploading = false,
    this.uploadedUrl,
    this.application,
    this.isLoadingApplication = false,
    this.isSubmittingWithdrawal = false,
  });

  WithdrawalState copyWith({
    int? currentStep,
    BankAccount? selectedAccount,
    PlatformFile? uploadedDocument,
    bool? isUploading,
    String? uploadedUrl,
    LoanApplicationModel? application,
    bool? isLoadingApplication,
    bool? isSubmittingWithdrawal,
  }) {
    return WithdrawalState(
      currentStep: currentStep ?? this.currentStep,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      uploadedDocument: uploadedDocument ?? this.uploadedDocument,
      isUploading: isUploading ?? this.isUploading,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      application: application ?? this.application,
      isLoadingApplication: isLoadingApplication ?? this.isLoadingApplication,
      isSubmittingWithdrawal:
          isSubmittingWithdrawal ?? this.isSubmittingWithdrawal,
    );
  }
}

@riverpod
class Withdrawal extends _$Withdrawal {
  @override
  WithdrawalState build() {
    return WithdrawalState();
  }

  Future<void> fetchApplication(String applicationId, UserModel? user) async {
    state = state.copyWith(isLoadingApplication: true);
    try {
      final app = await ref
          .read(firestoreServiceProvider)
          .getLoanApplicationById(applicationId);

      state = state.copyWith(
        application: app,
        isLoadingApplication: false,
      );

      if (user != null && user.bankAccounts.isNotEmpty && app != null) {
        final match = user.bankAccounts.firstWhere(
          (a) => a.accountNumber == app.accountNumber,
          orElse: () => user.bankAccounts.first,
        );
        state = state.copyWith(selectedAccount: match);
      }
    } catch (e) {
      state = state.copyWith(isLoadingApplication: false);
    }
  }

  void setInitialApplication(LoanApplicationModel app, UserModel? user) {
    state = state.copyWith(application: app);
    if (user != null && user.bankAccounts.isNotEmpty) {
      final match = user.bankAccounts.firstWhere(
        (a) => a.accountNumber == app.accountNumber,
        orElse: () => user.bankAccounts.first,
      );
      state = state.copyWith(selectedAccount: match);
    }
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void selectAccount(BankAccount account) {
    state = state.copyWith(selectedAccount: account);
  }

  Future<void> uploadDocument(PlatformFile file) async {
    if (file.bytes == null) return;

    state = state.copyWith(isUploading: true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('withdrawal_documents')
          .child(state.application?.id ?? '')
          .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');

      await storageRef.putData(
        file.bytes!,
        SettableMetadata(contentType: _getContentType(file.extension)),
      );

      final url = await storageRef.getDownloadURL();

      state = state.copyWith(
        uploadedDocument: file,
        uploadedUrl: url,
        isUploading: false,
      );
    } catch (e) {
      state = state.copyWith(isUploading: false);
      rethrow;
    }
  }

  String _getContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  Future<WithdrawalModel?> submitWithdrawal(UserModel currentUser) async {
    if (state.selectedAccount == null || state.application == null) {
      return null;
    }

    state = state.copyWith(isSubmittingWithdrawal: true);

    try {
      final withdrawal = WithdrawalModel(
        id: '',
        userName: currentUser.fullName,
        countryCode: currentUser.countryCode,
        userId: currentUser.id,
        applicationId: state.application!.id,
        amount: state.application!.loanAmount,
        bankName: state.selectedAccount!.bankName,
        accountNumber: state.selectedAccount!.accountNumber,
        documentUrl: state.uploadedUrl,
        createdAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).createWithdrawal(withdrawal);
      state = state.copyWith(isSubmittingWithdrawal: false);
      return withdrawal;
    } catch (e) {
      state = state.copyWith(isSubmittingWithdrawal: false);
      rethrow;
    }
  }
}
