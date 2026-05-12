import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/core/theme/theme_extensions.dart';
import 'package:aemo_loan_app/shared/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/loan_form_provider.dart';

class PersonalInfoStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;

  const PersonalInfoStep({
    super.key,
    required this.formKey,
  });

  @override
  ConsumerState<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends ConsumerState<PersonalInfoStep> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(loanFormProvider);
    _fullNameController = TextEditingController(text: state.fullName);
    _phoneController = TextEditingController(text: state.phone);
    
    // If provider is empty, try to get from currentUserProvider
    if (state.fullName.isEmpty || state.phone.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final user = ref.read(currentUserProvider).value;
        if (user != null) {
          final notifier = ref.read(loanFormProvider.notifier);
          if (_fullNameController.text.isEmpty && user.fullName.isNotEmpty) {
            _fullNameController.text = user.fullName;
            notifier.updateFullName(user.fullName);
          }
          if (_phoneController.text.isEmpty && user.phone.isNotEmpty) {
            _phoneController.text = user.phone;
            notifier.updatePhone(user.phone);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _fullNameController,
                  hint: 'e.g. Julian Montgomery',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  onChanged: (v) => ref.read(loanFormProvider.notifier).updateFullName(v),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'PHONE NUMBER',
                  controller: _phoneController,
                  hint: '+1 (555) 000-0000',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => ref.read(loanFormProvider.notifier).updatePhone(v),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 28),
                _buildInfoBadge(context),
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

  Widget _buildInfoBadge(BuildContext context) {
    final customColors = Theme.of(context).extension<AppCustomColors>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customColors.infoBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: customColors.infoIcon.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: customColors.infoIcon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SECURE TRANSMISSION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: customColors.infoIcon,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
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
