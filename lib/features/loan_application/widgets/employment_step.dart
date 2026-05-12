import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/core/constants/app_strings.dart';
import 'package:aemo_loan_app/shared/widgets/custom_text_field.dart';
import '../providers/loan_form_provider.dart';

class EmploymentStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final String currencyCode;

  const EmploymentStep({
    super.key,
    required this.formKey,
    required this.currencyCode,
  });

  @override
  ConsumerState<EmploymentStep> createState() => _EmploymentStepState();
}

class _EmploymentStepState extends ConsumerState<EmploymentStep> {
  late TextEditingController _employerController;
  late TextEditingController _monthlyIncomeController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(loanFormProvider);
    _employerController = TextEditingController(text: state.employer);
    _monthlyIncomeController = TextEditingController(
      text: state.monthlyIncome > 0 ? state.monthlyIncome.toString() : '',
    );
  }

  @override
  void dispose() {
    _employerController.dispose();
    _monthlyIncomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loanState = ref.watch(loanFormProvider);
    final notifier = ref.read(loanFormProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Work & Income',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _buildStepDots(1),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your employment information helps us understand your ability to repay.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                _buildFieldLabel('EMPLOYMENT STATUS'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: loanState.employmentStatus,
                  hint: 'Select status',
                  items: AppStrings.employmentStatuses,
                  onChanged: (v) => notifier.updateEmploymentStatus(v!),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'EMPLOYER NAME',
                  controller: _employerController,
                  hint: 'e.g. Global Tech Solutions',
                  prefixIcon: const Icon(Icons.business_outlined, size: 20),
                  onChanged: (v) => notifier.updateEmployer(v),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Employer is required' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'MONTHLY NET INCOME (${widget.currencyCode})',
                  controller: _monthlyIncomeController,
                  hint: '0.00',
                  prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) {
                    final amount = double.tryParse(v) ?? 0.0;
                    notifier.updateMonthlyIncome(amount);
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Income is required';
                    if (double.tryParse(v) == null) return 'Invalid amount';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint),
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildStepDots(int activeIndex) {
    return Row(
      children: List.generate(
        4,
        (i) => Container(
          width: i == activeIndex ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: i == activeIndex ? AppColors.primaryDark : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
