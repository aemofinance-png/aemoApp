import 'package:aemo_loan_app/core/constants/app_assets.dart';
import 'package:aemo_loan_app/core/utils/email_service.dart';
import 'package:aemo_loan_app/shared/widgets/custom_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/auth_provider.dart';
import '../../../app/router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  // Local state
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String _selectedCountry = 'BZ'; // Default to Belize

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  // Handle register
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).register(
          countryName: _selectedCountry,
          streetAddress: _streetAddressController.text.trim(),
          city: _cityController.text.trim(),
          stateProvince: _stateController.text.trim(),
          postalCode: '',
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          countryCode: _selectedCountry,
        );

    if (success && mounted) {
      await EmailService.sendWelcomeEmail(
        toEmail: _emailController.text.trim(),
        toName: _fullNameController.text.trim().split(' ').first,
      );
      if (mounted) context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return LoadingOverlay(
      isLoading: authState.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo & Title
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Image.asset(AppAssets.logo),
                          const SizedBox(height: 16),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.tagline,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),

                    // Heading
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Fill in your details to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Error message
                    if (authState.error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authState.error!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Full Name
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _fullNameController,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 16),

                    // Email
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone
                    CustomTextField(
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 16),

                    // Password
                    CustomTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                      validator: (value) =>
                          value == null || value.length < 6 ? 'Min 6 chars' : null,
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Repeat your password',
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Country Selection
                    const Text(
                      'Country',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCountry,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.public_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: AppStrings.supportedCountries.map((country) {
                        return DropdownMenuItem(
                          value: country['code'],
                          child: Text(country['name']!),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCountry = value!),
                    ),

                    const SizedBox(height: 24),

                    // Register button
                    CustomButton(
                      label: 'Create Account',
                      onPressed: _handleRegister,
                      isLoading: authState.isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
