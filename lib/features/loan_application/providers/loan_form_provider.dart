import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/loan_calculator.dart';

part 'loan_form_provider.g.dart';

class LoanFormState {
  final String fullName;
  final String phone;
  final String employmentStatus;
  final String employer;
  final double monthlyIncome;
  final double loanAmount;
  final String loanPurpose;
  final int loanDuration;
  final String selectedBank;
  final String accountNumber;
  final List<PlatformFile> documents;
  
  final double? monthlyPayment;
  final double? totalPayment;
  final double? totalInterest;

  LoanFormState({
    this.fullName = '',
    this.phone = '',
    this.employmentStatus = 'Full-time',
    this.employer = '',
    this.monthlyIncome = 0.0,
    this.loanAmount = 0.0,
    this.loanPurpose = 'Personal Expenses',
    this.loanDuration = 6,
    this.selectedBank = '',
    this.accountNumber = '',
    this.documents = const [],
    this.monthlyPayment,
    this.totalPayment,
    this.totalInterest,
  });

  LoanFormState copyWith({
    String? fullName,
    String? phone,
    String? employmentStatus,
    String? employer,
    double? monthlyIncome,
    double? loanAmount,
    String? loanPurpose,
    int? loanDuration,
    String? selectedBank,
    String? accountNumber,
    List<PlatformFile>? documents,
    double? monthlyPayment,
    double? totalPayment,
    double? totalInterest,
  }) {
    return LoanFormState(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      employer: employer ?? this.employer,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      loanAmount: loanAmount ?? this.loanAmount,
      loanPurpose: loanPurpose ?? this.loanPurpose,
      loanDuration: loanDuration ?? this.loanDuration,
      selectedBank: selectedBank ?? this.selectedBank,
      accountNumber: accountNumber ?? this.accountNumber,
      documents: documents ?? this.documents,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      totalPayment: totalPayment ?? this.totalPayment,
      totalInterest: totalInterest ?? this.totalInterest,
    );
  }
}

@riverpod
class LoanForm extends _$LoanForm {
  @override
  LoanFormState build() {
    return LoanFormState(
      employmentStatus: AppStrings.employmentStatuses.first,
      loanPurpose: AppStrings.loanPurposes.first,
      loanDuration: AppStrings.loanRates.keys.first,
    );
  }

  void updateFullName(String val) => state = state.copyWith(fullName: val);
  void updatePhone(String val) => state = state.copyWith(phone: val);
  void updateEmploymentStatus(String val) => state = state.copyWith(employmentStatus: val);
  void updateEmployer(String val) => state = state.copyWith(employer: val);
  void updateMonthlyIncome(double val) => state = state.copyWith(monthlyIncome: val);
  
  void updateLoanAmount(double val) {
    state = state.copyWith(loanAmount: val);
    _calculateLoan();
  }

  void updateLoanPurpose(String val) => state = state.copyWith(loanPurpose: val);
  
  void updateLoanDuration(int val) {
    state = state.copyWith(loanDuration: val);
    _calculateLoan();
  }

  void updateBank(String val) => state = state.copyWith(selectedBank: val);
  void updateAccountNumber(String val) => state = state.copyWith(accountNumber: val);
  
  void addDocument(PlatformFile file) {
    state = state.copyWith(documents: [...state.documents, file]);
  }

  void removeDocument(int index) {
    final docs = List<PlatformFile>.from(state.documents)..removeAt(index);
    state = state.copyWith(documents: docs);
  }

  void _calculateLoan() {
    if (state.loanAmount <= 0) return;

    final interestRate = AppStrings.loanRates[state.loanDuration] ?? 0.0;
    
    final monthly = LoanCalculator.calculateMonthlyPayment(
      loanAmount: state.loanAmount,
      annualInterestRate: interestRate,
      termMonths: state.loanDuration,
    );

    final totalRepay = LoanCalculator.calculateTotalRepayment(
      monthlyPayment: monthly,
      termMonths: state.loanDuration,
    );

    final totalInterest = LoanCalculator.calculateTotalInterest(
      totalRepayment: totalRepay,
      loanAmount: state.loanAmount,
    );

    state = state.copyWith(
      monthlyPayment: monthly,
      totalPayment: totalRepay,
      totalInterest: totalInterest,
    );
  }
}
