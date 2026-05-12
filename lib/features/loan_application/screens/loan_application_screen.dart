import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/core/utils/formatters.dart';
import 'package:aemo_loan_app/data/providers/service_providers.dart';
import 'package:aemo_loan_app/shared/widgets/loading_overlay.dart';
import 'package:aemo_loan_app/shared/widgets/custom_popup.dart';
import 'package:aemo_loan_app/features/auth/providers/auth_provider.dart';
import 'package:aemo_loan_app/features/loan_application/providers/loan_provider.dart';
import 'package:aemo_loan_app/app/router.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';

import '../providers/loan_form_provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        final notifier = ref.read(loanFormProvider.notifier);
        notifier.updateFullName(currentUser.fullName);
        notifier.updatePhone(currentUser.phone ?? '');
        
        final banks = ref.read(loanFormProvider).selectedBank;
        if (banks.isEmpty) {
          // Initialize with first bank if not set
          // (Actual initialization logic depends on AppStrings, 
          // handled in Step widget for now or can be moved to Notifier build)
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    
    final formState = ref.read(loanFormProvider);
    if (formState.documents.isEmpty) {
      CustomPopup.show(
        context,
        title: 'Documents Required',
        message:
            'Please upload at least one document to proceed with your application.',
        isWarning: true,
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      final alreadySaved = currentUser.bankAccounts.any(
        (a) => a.accountNumber == formState.accountNumber.trim(),
      );
      if (!alreadySaved && formState.accountNumber.isNotEmpty) {
        final newAccount = BankAccount(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bankName: formState.selectedBank,
          accountNumber: formState.accountNumber.trim(),
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
              fullName: formState.fullName.trim(),
              phone: formState.phone.trim(),
              employmentStatus: formState.employmentStatus,
              employer: formState.employer.trim(),
              monthlyIncome: formState.monthlyIncome,
              loanAmount: formState.loanAmount,
              loanPurpose: formState.loanPurpose,
              loanDuration: formState.loanDuration,
              bankName: formState.selectedBank,
              accountNumber: formState.accountNumber.trim(),
              documents: formState.documents,
            );

    if (application != null && mounted) {
      context.go(AppRoutes.applicationSubmitted, extra: application);
    }
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
                  PersonalInfoStep(formKey: _step1Key),
                  EmploymentStep(
                    formKey: _step2Key,
                    currencyCode: currencyCode,
                  ),
                  LoanDetailsStep(
                    formKey: _step3Key,
                    countryCode: countryCode,
                  ),
                  BankAndDocumentsStep(
                    formKey: _step4Key,
                    currentUser: currentUser,
                    countryCode: countryCode,
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
          ElevatedButton(
            onPressed: isLastStep ? _handleSubmit : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
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
        ],
      ),
    );
  }
}
