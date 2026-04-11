import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/providers/service_providers.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/loan_provider.dart';
import '../../../app/router.dart';
import 'dart:math';

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
  int _selectedDuration = AppStrings.loanRates.keys.first;
  String _selectedBank = '';
  final List<PlatformFile> _documents = [];

  double? _monthlyPayment;
  double? _totalPayment;
  double? _totalInterest;

  Map<int, double> get _availableRates {
    final amount = double.tryParse(_loanAmountController.text.trim()) ?? 0;
    return Map.fromEntries(
      AppStrings.loanRates.entries.where((entry) {
        final minimum = AppStrings.loanMinimums[entry.key] ?? 0;
        return amount >= minimum;
      }),
    );
  }

  double get _interestRate => AppStrings.loanRates[_selectedDuration] ?? 0.0;

  @override
  void initState() {
    super.initState();
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
      _totalInterest = (monthly * months) - amount;
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
          bankName: _selectedBank,
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
              bankName: _selectedBank,
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'STEP ${_currentStep + 1} OF $_totalSteps',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar + step label
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
                        _currentStep == 1
                            ? '${(progress * 100).toInt()}%'
                            : stepNames[_currentStep],
                        style: TextStyle(
                          fontSize: _currentStep == 1 ? 16 : 12,
                          fontWeight: _currentStep == 1
                              ? FontWeight.w800
                              : FontWeight.w500,
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
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),

            // Bottom nav
            _buildBottomNav(loanState),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────
  Widget _buildBottomNav(LoanState loanState) {
    final isLastStep = _currentStep == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: _currentStep > 0
                ? _previousStep
                : () => context.go(AppRoutes.dashboard),
            child: Row(
              children: const [
                Icon(Icons.arrow_back,
                    size: 16, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  'BACK',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ✅ No SizedBox with double.infinity inside a Row
          ElevatedButton(
            onPressed: isLastStep ? _handleSubmit : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLastStep ? 'SUBMIT APPLICATION' : 'CONTINUE',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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

  // ── Step 1: Personal Info ────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _step1Key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Let's get started.",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tell us a bit about yourself to help us build your personalized loan offer.',
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5),
                ),
                const SizedBox(height: 24),

                // Security badge
                _buildInfoBadge(
                  icon: Icons.shield_outlined,
                  title: 'SECURE TRANSMISSION',
                  subtitle: 'Your data is encrypted with bank-grade security.',
                ),

                const SizedBox(height: 28),

                _buildFieldLabel('FULL NAME'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _fullNameController,
                  hint: 'e.g. Julian Montgomery',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Full name is required' : null,
                ),

                const SizedBox(height: 20),

                _buildFieldLabel('PHONE NUMBER'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _phoneController,
                  hint: '+1 (555) 000-0000',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Phone number is required'
                      : null,
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 2: Employment ───────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _step2Key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Employment & Income',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please provide your professional details to help us assess your eligibility.',
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5),
                ),
                const SizedBox(height: 28),
                _buildFieldLabel('EMPLOYMENT STATUS'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedEmploymentStatus,
                  hint: 'Select status',
                  items: AppStrings.employmentStatuses,
                  onChanged: (v) =>
                      setState(() => _selectedEmploymentStatus = v!),
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('EMPLOYER NAME'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _employerController,
                  hint: 'e.g. Acme Corporation',
                  icon: Icons.business_outlined,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Employer name is required'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('GROSS MONTHLY INCOME'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _monthlyIncomeController,
                  hint: '0.00',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Monthly income is required';
                    if (double.tryParse(v) == null)
                      return 'Enter a valid amount';
                    if (double.parse(v) <= 0)
                      return 'Income must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                _buildInfoBadge(
                  icon: Icons.security_outlined,
                  title: 'Data Privacy',
                  subtitle:
                      'Your income details are encrypted and only used for credit assessment purposes.',
                  titleBold: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 3: Loan Details ─────────────────────────────────
  Widget _buildStep3() {
    final currentUser = ref.read(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';
    final currencyCode = Formatters.getCurrencyCode(countryCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _step3Key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Loan Details',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Step dots
                    Row(
                      children: List.generate(
                          4,
                          (i) => Container(
                                width: i == 2 ? 24 : 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  color: i == 2
                                      ? AppColors.primaryDark
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please specify the amount and purpose of your loan. This helps us tailor the best rates for your financial goals.',
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5),
                ),
                const SizedBox(height: 28),

                _buildFieldLabel('DESIRED LOAN AMOUNT'),
                const SizedBox(height: 8),

                // Amount field with currency prefix
                TextFormField(
                  controller: _loanAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    prefixText: '$currencyCode  ',
                    prefixStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                  ),
                  onChanged: (_) {
                    _calculate();
                    setState(() {
                      final available = _availableRates;
                      if (!available.containsKey(_selectedDuration) &&
                          available.isNotEmpty) {
                        _selectedDuration = available.keys.first;
                      }
                    });
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Loan amount is required';
                    if (double.tryParse(v) == null)
                      return 'Enter a valid amount';
                    if (double.parse(v) < 100)
                      return 'Minimum loan amount is 100';
                    return null;
                  },
                ),

                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Min: $currencyCode 1,000',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint)),
                    Text('Max: $currencyCode 50,000',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint)),
                  ],
                ),

                const SizedBox(height: 20),

                _buildFieldLabel('LOAN PURPOSE'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedLoanPurpose,
                  hint: 'Select an option',
                  items: AppStrings.loanPurposes,
                  onChanged: (v) => setState(() => _selectedLoanPurpose = v!),
                ),

                const SizedBox(height: 20),

                _buildFieldLabel('LOAN DURATION'),
                const SizedBox(height: 12),
                // Replace _buildDropdown with a direct DropdownButtonFormField for duration:
                DropdownButtonFormField<int>(
                  value: _selectedDuration,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                  ),
                  hint: const Text('Select an option',
                      style: TextStyle(color: AppColors.textHint)),
                  items: _availableRates.keys
                      .map((months) => DropdownMenuItem<int>(
                            value: months,
                            child: Text(
                              '${Formatters.duration(months)} — ${AppStrings.loanRates[months]}% p.a.',
                            ),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    _selectedDuration = value!;
                    _calculate();
                  }),
                ),
                // Duration grid
                // GridView.count(
                //   crossAxisCount: 2,
                //   shrinkWrap: true,
                //   physics: const NeverScrollableScrollPhysics(),
                //   crossAxisSpacing: 12,
                //   mainAxisSpacing: 12,
                //   childAspectRatio: 1.8,
                //   children: _availableRates.entries.map((entry) {
                //     final months = entry.key;
                //     final rate = entry.value;
                //     final isSelected = _selectedDuration == months;
                //     return GestureDetector(
                //       onTap: () => setState(() {
                //         _selectedDuration = months;
                //         _calculate();
                //       }),
                //       child: Container(
                //         padding: const EdgeInsets.all(14),
                //         decoration: BoxDecoration(
                //           color: isSelected
                //               ? Colors.transparent
                //               : AppColors.background,
                //           borderRadius: BorderRadius.circular(10),
                //           border: Border.all(
                //             color: isSelected
                //                 ? AppColors.primaryDark
                //                 : AppColors.border,
                //             width: isSelected ? 2 : 1,
                //           ),
                //         ),
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Text(
                //               '${Formatters.duration(months).toUpperCase()}',
                //               style: TextStyle(
                //                 fontSize: 11,
                //                 fontWeight: FontWeight.w600,
                //                 color: isSelected
                //                     ? AppColors.primaryDark
                //                     : AppColors.textSecondary,
                //                 letterSpacing: 0.5,
                //               ),
                //             ),
                //             const SizedBox(height: 4),
                //             Text(
                //               '$rate% APR',
                //               style: TextStyle(
                //                 fontSize: 18,
                //                 fontWeight: FontWeight.w800,
                //                 color: isSelected
                //                     ? AppColors.primaryDark
                //                     : AppColors.textPrimary,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   }).toList(),
                // ),

                if (_monthlyPayment != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.info_outline,
                              color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly Payment',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '${Formatters.currency(_monthlyPayment!, countryCode)} / month • Total: ${Formatters.currency(_totalPayment!, countryCode)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 4: Bank & Documents ─────────────────────────────
  Widget _buildStep4() {
    final currentUser = ref.read(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';
    final banks = AppStrings.banksByCountry[countryCode] ?? [];
    final savedAccounts = currentUser?.bankAccounts ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _step4Key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Bank & Documents',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please verify your payout details and upload required documentation.',
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5),
                ),
                const SizedBox(height: 28),

                // Saved accounts
                if (savedAccounts.isNotEmpty) ...[
                  _buildFieldLabel('SAVED ACCOUNTS'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: savedAccounts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final account = entry.value;
                        final isSelected = _selectedBank == account.bankName &&
                            _accountNumberController.text ==
                                account.accountNumber;
                        final isLast = index == savedAccounts.length - 1;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => setState(() {
                                _selectedBank = account.bankName;
                                _accountNumberController.text =
                                    account.accountNumber;
                              }),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.account_balance_outlined,
                                          color: AppColors.primary,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(account.bankName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              )),
                                          Text(
                                            '•••• ${account.accountNumber.length >= 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Verification badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: account.verificationStatus ==
                                                BankVerificationStatus.verified
                                            ? AppColors.primaryLight
                                            : AppColors.background,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (account.verificationStatus ==
                                              BankVerificationStatus.verified)
                                            const Icon(Icons.check_circle,
                                                color: AppColors.primary,
                                                size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            account.verificationStatus.name
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  account.verificationStatus ==
                                                          BankVerificationStatus
                                                              .verified
                                                      ? AppColors.primary
                                                      : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast) const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Manual entry
                _buildFieldLabel('ADD NEW ACCOUNT'),
                const SizedBox(height: 15),

                _buildFieldLabel('BANK NAME'),
                const SizedBox(height: 8),

                _buildDropdown(
                  value: _selectedBank,
                  hint: 'Select bank',
                  items: AppStrings.banksByCountry[countryCode] ?? [],
                  onChanged: (v) => setState(() => _selectedBank = v!),
                ),

                const SizedBox(height: 16),

                _buildFieldLabel('ACCOUNT NUMBER'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _accountNumberController,
                  hint: '• • • • • • • • • • • •',
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Account number is required'
                      : null,
                ),

                const SizedBox(height: 28),

                // Documents
                _buildFieldLabel('SUPPORTING DOCUMENTS'),
                const SizedBox(height: 12),

                // Upload area
                GestureDetector(
                  onTap: _pickDocument,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.upload_file_outlined,
                              color: AppColors.textSecondary, size: 24),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Upload ID or Pay Stubs',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PDF, PNG or JPG (Max 10MB)',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Browse Files',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Uploaded files
                if (_documents.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ..._documents.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file_outlined,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: 1.0,
                                  backgroundColor: AppColors.border,
                                  color: AppColors.primaryDark,
                                  minHeight: 2,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('100%',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeDocument(index),
                            child: const Icon(Icons.close,
                                color: AppColors.textSecondary, size: 18),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textHint, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  Widget _buildDropdown({
    final int? duration,
    final String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value?.isEmpty ?? true ? null : value,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      hint: Text(hint, style: const TextStyle(color: AppColors.textHint)),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String title,
    required String subtitle,
    bool titleBold = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: titleBold ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: titleBold ? 0 : 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
