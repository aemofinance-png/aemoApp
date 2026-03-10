import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
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

import '../../../data/models/user_model.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _codeValid = false;
  String? _oobCode;
  String? _email;

  @override
  void initState() {
    super.initState();
    _checkResetCode();
  }

  Future<void> _checkResetCode() async {
    final uri = Uri.base;
    final code = uri.queryParameters['oobCode'];
    final mode = uri.queryParameters['mode'];

    if (mode == 'resetPassword' && code != null) {
      try {
        final email = await FirebaseAuth.instance.verifyPasswordResetCode(code);
        setState(() {
          _codeValid = true;
          _oobCode = code;
          _email = email;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _codeValid = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _codeValid = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate() || _oobCode == null) return;

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: _oobCode!,
        newPassword: _passwordController.text,
      );
      // Optionally, sign the user in or redirect to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful!')),
        );
        context.go('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset password: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (!_codeValid) {
      return const Center(child: Text('Invalid or expired reset link.'));
    }
    bool _showPassword = false;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Reset password for $_email'),
                // const SizedBox(height: 16),
                // TextFormField(
                //   controller: _passwordController,
                //   obscureText: true,
                //   decoration: const InputDecoration(labelText: 'New password'),
                //   validator: (value) {
                //     if (value == null || value.length < 6) {
                //       return 'Password must be at least 6 characters';
                //     }
                //     return null;
                //   },
                // ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text('Reset Password'),
                ),

                CustomTextField(
                  label: 'Password',
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Login button
                CustomButton(
                  label: 'Reset Password',
                  onPressed: _resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
