import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aemo_loan_app/features/withdrawal/providers/withdrawal_provider.dart';
import 'package:aemo_loan_app/data/models/loan_application_model.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:aemo_loan_app/data/models/withdrawal_model.dart';
import 'package:aemo_loan_app/data/providers/service_providers.dart';
import 'package:aemo_loan_app/data/services/firestore_service.dart';

class MockFirestoreService implements FirestoreService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<LoanApplicationModel?> getLoanApplicationById(String id) async {
    return LoanApplicationModel(
      id: id,
      userId: 'user_123',
      fullName: 'John Doe',
      phone: '123456',
      countryCode: 'BZ',
      employmentStatus: 'Employed',
      employer: 'Aemo',
      monthlyIncome: 5000,
      loanAmount: 1000,
      loanPurpose: 'Personal',
      loanDuration: 12,
      bankName: 'Belize Bank',
      accountNumber: '112233',
      documentUrls: const [],
      status: LoanStatus.approved,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<WithdrawalModel> createWithdrawal(WithdrawalModel withdrawal) async {
    return withdrawal;
  }
}

void main() {
  late ProviderContainer container;
  late MockFirestoreService mockFirestore;

  setUp(() {
    mockFirestore = MockFirestoreService();
    container = ProviderContainer(
      overrides: [
        firestoreServiceProvider.overrideWithValue(mockFirestore),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WithdrawalNotifier Tests', () {
    test('initial state is correct', () {
      final state = container.read(withdrawalProvider);
      expect(state.currentStep, 0);
      expect(state.selectedAccount, isNull);
      expect(state.isUploading, isFalse);
    });

    test('setStep updates current step', () {
      final notifier = container.read(withdrawalProvider.notifier);
      notifier.setStep(1);
      expect(container.read(withdrawalProvider).currentStep, 1);
    });

    test('fetchApplication updates application and selects bank account',
        () async {
      final notifier = container.read(withdrawalProvider.notifier);
      final user = UserModel(
        id: 'user_123',
        fullName: 'John Doe',
        email: 'john@test.com',
        phone: '123456',
        countryCode: 'BZ',
        countryName: 'Belize',
        streetAddress: '123 St',
        city: 'Belize',
        state: 'BZ',
        postalCode: '000',
        role: 'user',
        createdAt: DateTime.now(),
        bankAccounts: const [
          BankAccount(
            id: 'bank_1',
            bankName: 'Belize Bank',
            accountNumber: '112233',
            accountName: 'John Doe',
          ),
        ],
      );

      await notifier.fetchApplication('loan_123', user);

      final state = container.read(withdrawalProvider);
      expect(state.application?.id, 'loan_123');
      expect(state.selectedAccount?.accountNumber, '112233');
      expect(state.isLoadingApplication, isFalse);
    });

    test('selectAccount updates selected account', () {
      final notifier = container.read(withdrawalProvider.notifier);
      const account = BankAccount(
        id: 'bank_2',
        bankName: 'Atlantic Bank',
        accountNumber: '445566',
        accountName: 'John Doe',
      );

      notifier.selectAccount(account);
      expect(container.read(withdrawalProvider).selectedAccount, account);
    });
  });
}
