import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/core/constants/app_strings.dart';
import 'package:aemo_loan_app/core/utils/formatters.dart';
import 'package:aemo_loan_app/data/providers/service_providers.dart';
import 'package:aemo_loan_app/shared/widgets/loading_overlay.dart';
import 'package:aemo_loan_app/features/auth/providers/auth_provider.dart';
import 'package:aemo_loan_app/features/loan_application/providers/loan_provider.dart';
import 'package:aemo_loan_app/app/router.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';

import '../widgets/personal_info_step.dart';
import '../widgets/employment_step.dart';
import '../widgets/loan_details_step.dart';
import '../widgets/bank_and_documents_step.dart';

class LoanApplicationScreen extends ConsumerStatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  ConsumerState<LoanApplicationScreen> createState() =>
      _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends ConsumerState<LoanApplicationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employerController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();

  String _selectedEmploymentStatus = AppStrings.employmentStatuses.first;
  String _selectedLoanPurpose = AppStrings.loanPurposes.first;
  late int _selectedDuration;
  String? _selectedBank;
  final List<PlatformFile> _documents = [];

  double? _monthlyPayment;
  double? _totalPayment;

  String get _countryCode =>
      ref.read(currentUserProvider).value?.countryCode ?? 'BZ';

  Map<int, double> get _currentRates => AppStrings.getLoanRates(_countryCode);

  Map<int, double> get _availableRates {
    final amount = double.tryParse(_loanAmountController.text.trim()) ?? 0;
    return Map.fromEntries(
      _currentRates.entries.where((entry) {
        final minimum = AppStrings.loanMinimums[entry.key] ?? 0;
        return amount >= minimum;
      }),
    );
  }

  double get _interestRate => _currentRates[_selectedDuration] ?? 0.0;

  @override
  void initState() {
    super.initState();
    _selectedDuration = AppStrings.getLoanRates(null).keys.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider).value;
      final countryCode = currentUser?.countryCode ?? 'BZ';
      final banks = AppStrings.banksByCountry[countryCode] ?? [];
      if (banks.isNotEmpty) setState(() => _selectedBank = banks.first);
      _fullNameController.text = currentUser?.fullName ?? '';
      _phoneController.text = currentUser?.phone ?? '';
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _employerController.dispose();
    _monthlyIncomeController.dispose();
    _loanAmountController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_loanAmountController.text.trim());
    if (amount == null || amount <= 0) return;
    final monthlyRate = _interestRate / 12 / 100;
    final months = _selectedDuration;
    final monthly = amount *
        (monthlyRate * pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);
    setState(() {
      _monthlyPayment = monthly.toDouble();
      _totalPayment = monthly * months;
    });
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1Key.currentState!.validate();
      case 1:
        return _step2Key.currentState!.validate();
      case 2:
        return _step3Key.currentState!.validate();
      case 3:
        return _step4Key.currentState!.validate();
      default:
        return true;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_validateCurrentStep()) return;
    if (_documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload at least one document'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      final alreadySaved = currentUser.bankAccounts.any(
        (a) => a.accountNumber == _accountNumberController.text.trim(),
      );
      if (!alreadySaved && _accountNumberController.text.isNotEmpty) {
        final newAccount = BankAccount(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bankName: _selectedBank ?? '',
          accountNumber: _accountNumberController.text.trim(),
          accountName: currentUser.fullName,
        );
        final updatedUser = currentUser.copyWith(
          bankAccounts: [...currentUser.bankAccounts, newAccount],
        );
        await ref.read(firestoreServiceProvider).updateUser(updatedUser);
      }
    }

    final application =
        await ref.read(loanNotifierProvider.notifier).submitApplication(
              fullName: _fullNameController.text.trim(),
              phone: _phoneController.text.trim(),
              employmentStatus: _selectedEmploymentStatus,
              employer: _employerController.text.trim(),
              monthlyIncome: double.parse(_monthlyIncomeController.text.trim()),
              loanAmount: double.parse(_loanAmountController.text.trim()),
              loanPurpose: _selectedLoanPurpose,
              loanDuration: _selectedDuration,
              bankName: _selectedBank ?? '',
              accountNumber: _accountNumberController.text.trim(),
              documents: _documents,
            );

    if (application != null && mounted) {
      context.go(AppRoutes.applicationSubmitted, extra: application);
    }
  }

  Future<void> _pickDocument() async {
    final file = await ref.read(storageServiceProvider).pickFile();
    if (file != null) setState(() => _documents.add(file));
  }

  void _removeDocument(int index) {
    setState(() => _documents.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final loanState = ref.watch(loanNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';
    final currencyCode = Formatters.getCurrencyCode(countryCode);
    final progress = (_currentStep + 1) / _totalSteps;
    final stepNames = [
      'Personal Info',
      'Employment',
      'Loan Details',
      'Bank & Docs'
    ];

    return LoadingOverlay(
      isLoading: loanState.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: _currentStep > 0
                ? _previousStep
                : () => context.go(AppRoutes.dashboard),
          ),
          title: const Text(
            'Loan Application',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Column(
          children: [
            // Progress Header
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STEP ${_currentStep + 1} OF $_totalSteps',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        stepNames[_currentStep],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.border,
                      color: AppColors.primaryDark,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  PersonalInfoStep(
                    formKey: _step1Key,
                    fullNameController: _fullNameController,
                    phoneController: _phoneController,
                  ),
                  EmploymentStep(
                    formKey: _step2Key,
                    selectedEmploymentStatus: _selectedEmploymentStatus,
                    employerController: _employerController,
                    monthlyIncomeController: _monthlyIncomeController,
                    currencyCode: currencyCode,
                    onEmploymentStatusChanged: (v) =>
                        setState(() => _selectedEmploymentStatus = v!),
                  ),
                  LoanDetailsStep(
                    formKey: _step3Key,
                    loanAmountController: _loanAmountController,
                    selectedLoanPurpose: _selectedLoanPurpose,
                    selectedDuration: _selectedDuration,
                    availableRates: _availableRates,
                    interestRate: _interestRate,
                    monthlyPayment: _monthlyPayment,
                    totalPayment: _totalPayment,
                    countryCode: countryCode,
                    onPurposeChanged: (v) =>
                        setState(() => _selectedLoanPurpose = v!),
                    onDurationChanged: (v) {
                      setState(() => _selectedDuration = v!);
                      _calculate();
                    },
                    onAmountChanged: (v) => _calculate(),
                  ),
                  BankAndDocumentsStep(
                    formKey: _step4Key,
                    selectedBank: _selectedBank,
                    accountNumberController: _accountNumberController,
                    documents: _documents,
                    currentUser: currentUser,
                    countryCode: countryCode,
                    onBankChanged: (v) => setState(() => _selectedBank = v),
                    onPickDocument: _pickDocument,
                    onRemoveDocument: _removeDocument,
                  ),
                ],
              ),
            ),

            // Navigation
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final isLastStep = _currentStep == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentStep > 0
                ? _previousStep
                : () => context.go(AppRoutes.dashboard),
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLastStep ? _handleSubmit : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(120, 52),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLastStep ? 'SUBMIT APPLICATION' : 'CONTINUE',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
