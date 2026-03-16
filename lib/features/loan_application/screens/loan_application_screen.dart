import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/providers/service_providers.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/loan_provider.dart';
import '../../../app/router.dart';

class LoanApplicationScreen extends ConsumerStatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  ConsumerState<LoanApplicationScreen> createState() =>
      _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends ConsumerState<LoanApplicationScreen> {
  // Step control
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  Map<int, double> get _availableRates {
    final amount = double.tryParse(_loanAmountController.text.trim()) ?? 0;
    return Map.fromEntries(
      AppStrings.loanRates.entries.where((entry) {
        final minimum = AppStrings.loanMinimums[entry.key] ?? 0;
        return amount >= minimum;
      }),
    );
  }

  // Form keys
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  // Step 1 controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 2 controllers
  final _employerController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  String _selectedEmploymentStatus = AppStrings.employmentStatuses.first;

  // Step 3 controllers
  final _loanAmountController = TextEditingController();
  String _selectedLoanPurpose = AppStrings.loanPurposes.first;
  int _selectedDuration = AppStrings.loanRates.keys.first;
  // int _selectedInterest = AppStrings.loanRates.keys.

  // Step 4
  String _selectedBank = '';
  final _accountNumberController = TextEditingController();
  final List<PlatformFile> _documents = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider).value;
      final countryCode = currentUser?.countryCode ?? 'BZ';
      final banks = AppStrings.banksByCountry[countryCode] ?? [];

      if (banks.isNotEmpty) {
        setState(() => _selectedBank = banks.first);
      }

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
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────

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

  // ── Submit ───────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    if (!_validateCurrentStep()) {
      // context.go(AppRoutes.dashboard);
      return;
    }

    if (_documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one document'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
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

    print('submitApplication returned: $application'); //

    if (application != null && mounted) {
      context.go(AppRoutes.applicationSubmitted, extra: application);
      setState(() {});
    }
  }

  // ── Document Picker ──────────────────────────────────────

  Future<void> _pickDocument() async {
    final file = await ref.read(storageServiceProvider).pickFile();
    if (file != null) setState(() => _documents.add(file));
  }

  void _removeDocument(int index) {
    setState(() => _documents.removeAt(index));
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loanState = ref.watch(loanNotifierProvider);

    return LoadingOverlay(
      isLoading: loanState.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousStep,
                )
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.go(AppRoutes.dashboard),
                ),
          title: const Text(
            'Loan Application',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Step indicator
            Container(
              color: AppColors.white,
              child: _buildStepIndicator(),
            ),

            // Step pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepContent(_buildStep1()),
                  _buildStepContent(_buildStep2()),
                  _buildStepContent(_buildStep3()),
                  _buildStepContent(_buildStep4()),
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

  // ── Step Indicator ───────────────────────────────────────

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              'Personal',
              'Employment',
              'Loan Details',
              'Bank & Docs',
            ].asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              final isActive = index == _currentStep;
              final isComplete = index < _currentStep;

              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppColors.success
                          : isActive
                              ? AppColors.primary
                              : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isComplete
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  // ── Step Content Wrapper ─────────────────────────────────

  Widget _buildStepContent(Widget step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: step,
        ),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────

  Widget _buildBottomNav(LoanState loanState) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            children: [
              if (_currentStep > 0) ...[
                Expanded(
                  child: CustomButton(
                    label: 'Back',
                    onPressed: _previousStep,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: CustomButton(
                  label: isLastStep ? 'Submit Application' : 'Next',
                  onPressed: isLastStep ? _handleSubmit : _nextStep,
                  isLoading: loanState.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Personal Info ────────────────────────────────

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Personal Information',
            'Confirm your personal details',
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _fullNameController,
            prefixIcon: const Icon(Icons.person_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Phone Number',
            hint: 'Enter your phone number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Step 2: Employment ───────────────────────────────────

  Widget _buildStep2() {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Employment & Income',
            'Tell us about your employment',
          ),
          const SizedBox(height: 24),
          _buildDropdown(
            label: 'Employment Status',
            value: _selectedEmploymentStatus,
            items: AppStrings.employmentStatuses,
            onChanged: (value) =>
                setState(() => _selectedEmploymentStatus = value!),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Employer Name',
            hint: 'Enter your employer name',
            controller: _employerController,
            prefixIcon: const Icon(Icons.business_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Employer name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Monthly Income',
            hint: 'Enter your monthly income',
            controller: _monthlyIncomeController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.attach_money),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Monthly income is required';
              }
              if (double.tryParse(value) == null) {
                return 'Enter a valid amount';
              }
              if (double.parse(value) <= 0) {
                return 'Income must be greater than 0';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Step 3: Loan Details ─────────────────────────────────

  Widget _buildStep3() {
    final currentUser = ref.read(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';

    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Loan Details',
            'Tell us about the loan you need',
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Loan Amount (${Formatters.getCurrencyCode(countryCode)})',
            hint: 'Enter loan amount',
            controller: _loanAmountController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.attach_money),
            onChanged: (_) {
              setState(() {
                // Reset duration if it's no longer available
                final available = _availableRates;
                if (!available.containsKey(_selectedDuration)) {
                  _selectedDuration = available.keys.first;
                }
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Loan amount is required';
              }
              if (double.tryParse(value) == null) {
                return 'Enter a valid amount';
              }
              if (double.parse(value) < 100) {
                return 'Minimum loan amount is 100';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Loan Purpose',
            value: _selectedLoanPurpose,
            items: AppStrings.loanPurposes,
            onChanged: (value) => setState(() => _selectedLoanPurpose = value!),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loan Duration',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedDuration,
                decoration: _dropdownDecoration(),
                items: _availableRates.keys.map((months) {
                  return DropdownMenuItem<int>(
                    value: months,
                    child: Text(
                      '${Formatters.duration(months)} — ${AppStrings.loanRates[months]}% p.a.',
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedDuration = value!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 4: Bank & Documents ─────────────────────────────

  Widget _buildStep4() {
    final currentUser = ref.read(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';
    final banks = AppStrings.banksByCountry[countryCode] ?? [];

    return Form(
      key: _step4Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Bank & Documents',
            'Enter your bank details and upload documents',
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bank Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBank.isEmpty ? null : _selectedBank,
                decoration: _dropdownDecoration(),
                items: banks.map((bank) {
                  return DropdownMenuItem<String>(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedBank = value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a bank';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Account Number',
            hint: 'Enter your account number',
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.credit_card_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Account number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Supporting Documents',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload your ID and latest pay slip, you can upload multiple documents (PDF, JPG, PNG)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Uploaded files
          ..._documents.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.error, size: 18),
                    onPressed: () => _removeDocument(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Upload button
          OutlinedButton.icon(
            onPressed: _pickDocument,
            icon: const Icon(Icons.upload_outlined),
            label: const Text('Upload Document'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _dropdownDecoration(),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
