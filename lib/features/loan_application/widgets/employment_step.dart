import 'package:flutter/material.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/core/constants/app_strings.dart';
import 'package:aemo_loan_app/shared/widgets/custom_text_field.dart';

class EmploymentStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String selectedEmploymentStatus;
  final TextEditingController employerController;
  final TextEditingController monthlyIncomeController;
  final String currencyCode;
  final void Function(String?) onEmploymentStatusChanged;

  const EmploymentStep({
    super.key,
    required this.formKey,
    required this.selectedEmploymentStatus,
    required this.employerController,
    required this.monthlyIncomeController,
    required this.currencyCode,
    required this.onEmploymentStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: formKey,
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
                  value: selectedEmploymentStatus,
                  hint: 'Select status',
                  items: AppStrings.employmentStatuses,
                  onChanged: onEmploymentStatusChanged,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'EMPLOYER NAME',
                  controller: employerController,
                  hint: 'e.g. Global Tech Solutions',
                  prefixIcon: const Icon(Icons.business_outlined, size: 20),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Employer is required' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'MONTHLY NET INCOME ($currencyCode)',
                  controller: monthlyIncomeController,
                  hint: '0.00',
                  prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
