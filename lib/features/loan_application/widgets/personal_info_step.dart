import 'package:flutter/material.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/shared/widgets/custom_text_field.dart';

class PersonalInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;

  const PersonalInfoStep({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.phoneController,
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
                      "Let's get started.",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _buildStepDots(0),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tell us a bit about yourself to help us build your personalized loan offer.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 52),
                CustomTextField(
                  label: 'FULL NAME',
                  controller: fullNameController,
                  hint: 'e.g. Julian Montgomery',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'PHONE NUMBER',
                  controller: phoneController,
                  hint: '+1 (555) 000-0000',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Phone number is required'
                      : null,
                ),
                const SizedBox(height: 28),
                _buildInfoBadge(),
              ],
            ),
          ),
        ),
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

  Widget _buildInfoBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SECURE TRANSMISSION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your data is encrypted with bank-grade security.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
