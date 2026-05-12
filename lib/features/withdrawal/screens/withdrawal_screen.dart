import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/features/auth/providers/auth_provider.dart';
import 'package:aemo_loan_app/app/router.dart';
import 'package:aemo_loan_app/data/models/loan_application_model.dart';
import '../providers/withdrawal_provider.dart';
import '../widgets/withdrawal_step_indicator.dart';
import '../widgets/step_agreement_upload.dart';
import '../widgets/step_bank_selection.dart';
import '../widgets/step_confirmation.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  final LoanApplicationModel? application;
  final String applicationId;

  const WithdrawalScreen({
    super.key,
    required this.application,
    required this.applicationId,
  });

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(withdrawalProvider.notifier);
      final user = ref.read(currentUserProvider).value;
      if (widget.application != null) {
        notifier.setInitialApplication(widget.application!, user);
      } else {
        notifier.fetchApplication(widget.applicationId, user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawalProvider);
    final notifier = ref.read(withdrawalProvider.notifier);
    final currentUser = ref.watch(currentUserProvider).value;

    if (state.isLoadingApplication || state.application == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D1B3E)),
          onPressed: () {
            if (state.currentStep > 0) {
              notifier.setStep(state.currentStep - 1);
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: const Text(
          'Withdraw Funds',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D1B3E),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          WithdrawalStepIndicator(currentStep: state.currentStep),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _buildCurrentStep(state.currentStep),
                ),
              ),
            ),
          ),
          _buildBottomBar(context, ref, state, notifier, currentUser),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(int step) {
    switch (step) {
      case 0:
        return const StepAgreementUpload();
      case 1:
        return const StepBankSelection();
      case 2:
        return const StepConfirmation();
      default:
        return const StepAgreementUpload();
    }
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    WithdrawalState state,
    Withdrawal notifier,
    dynamic currentUser,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (state.isUploading || state.isSubmittingWithdrawal)
                  ? null
                  : () async {
                      if (state.currentStep == 0) {
                        if (state.uploadedDocument == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please upload your loan agreement to proceed.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        notifier.setStep(1);
                        return;
                      }

                      if (state.currentStep == 1) {
                        if (state.selectedAccount == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please select a bank account to proceed.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        notifier.setStep(2);
                        return;
                      }

                      if (state.currentStep == 2) {
                        if (currentUser == null) return;
                        try {
                          final withdrawal =
                              await notifier.submitWithdrawal(currentUser);
                          if (withdrawal != null && context.mounted) {
                            context.go(AppRoutes.withdrawalSuccess,
                                extra: withdrawal);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Failed to process withdrawal: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B3E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: (state.isUploading || state.isSubmittingWithdrawal)
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      state.currentStep == 2 ? 'CONFIRM WITHDRAWAL' : 'CONTINUE',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
