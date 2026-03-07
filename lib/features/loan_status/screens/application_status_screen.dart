import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/loan_application_model.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../loan_application/providers/loan_provider.dart';
import '../../../app/router.dart';
import 'dart:math';

class ApplicationStatusScreen extends ConsumerStatefulWidget {
  final String applicationId;

  const ApplicationStatusScreen({
    super.key,
    required this.applicationId,
  });

  @override
  ConsumerState<ApplicationStatusScreen> createState() =>
      _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState
    extends ConsumerState<ApplicationStatusScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(loanNotifierProvider.notifier).fetchApplications());
  }

  double _calculateMonthlyRepayment(LoanApplicationModel application) {
    final double principal = application.loanAmount;
    final double annualRate =
        AppStrings.loanRates[application.loanDuration] ?? 0;
    final int months = application.loanDuration;

    if (annualRate == 0) return principal / months;

    final double r = annualRate / 12 / 100;
    final double factor = pow(1 + r, months).toDouble();
    return principal * (r * factor) / (factor - 1);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final loanState = ref.watch(loanNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';

    // Find the application from the list
    final application = loanState.applications
        .where((a) => a.id == widget.applicationId)
        .firstOrNull;
    final canVerify = application?.status == LoanStatus.approved &&
        currentUser?.verificationStatus == VerificationStatus.unverified;
    if (application == null) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text(
            'Application not found',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status card
                _buildStatusCard(application),

                const SizedBox(height: 24),

                // Loan details
                _buildSection(
                  title: 'Loan Details',
                  icon: Icons.description_outlined,
                  children: [
                    _buildDetailRow('Purpose', application.loanPurpose),
                    _buildDetailRow(
                        'Amount',
                        Formatters.currency(
                            application.loanAmount, countryCode)),
                    _buildDetailRow('Duration',
                        Formatters.duration(application.loanDuration)),
                    _buildDetailRow(
                      'Interest Rate',
                      '${AppStrings.loanRates[application.loanDuration]}% p.a.',
                    ),
                    _buildDetailRow(
                      'Monthly Repayment',
                      Formatters.currency(
                          _calculateMonthlyRepayment(application), countryCode),
                    ),
                    _buildDetailRow(
                        'Applied On', Formatters.date(application.createdAt)),
                  ],
                ),

                const SizedBox(height: 16),

                // Employment details
                _buildSection(
                  title: 'Employment Details',
                  icon: Icons.business_outlined,
                  children: [
                    _buildDetailRow('Status', application.employmentStatus),
                    _buildDetailRow('Employer', application.employer),
                  ],
                ),

                const SizedBox(height: 16),

                // Bank details
                _buildSection(
                  title: 'Bank Details',
                  icon: Icons.account_balance_outlined,
                  children: [
                    _buildDetailRow('Bank', application.bankName),
                    _buildDetailRow(
                        'Account Number', application.accountNumber),
                  ],
                ),

                const SizedBox(height: 16),

                // Documents
                _buildSection(
                  title: 'Documents',
                  icon: Icons.attach_file_outlined,
                  children: application.documentUrls.isEmpty
                      ? [
                          const Text(
                            'No documents uploaded',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          )
                        ]
                      : application.documentUrls
                          .asMap()
                          .entries
                          .map((entry) => _buildDocumentRow(
                              context, entry.key + 1, entry.value))
                          .toList(),
                ),

                // Admin review section
                if (application.status != LoanStatus.pending) ...[
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Review Details',
                    icon: Icons.rate_review_outlined,
                    children: [
                      _buildDetailRow(
                        'Decision',
                        application.status == LoanStatus.approved
                            ? 'Approved'
                            : 'Rejected',
                      ),
                      if (application.reviewedAt != null)
                        _buildDetailRow(
                          'Reviewed On',
                          Formatters.date(application.reviewedAt!),
                        ),
                      if (application.adminNote != null &&
                          application.adminNote!.isNotEmpty)
                        _buildDetailRow(
                          'Note',
                          application.adminNote!,
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: canVerify ? () => context.go(AppRoutes.kyc) : null,
                  icon: const Icon(Icons.perm_identity),
                  label: const Text('Proceed to KYC'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canVerify ? AppColors.primary : AppColors.primaryLight,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // App bar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(AppRoutes.dashboard),
      ),
      title: const Text(
        'Application Status',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  // Status card at the top
  Widget _buildStatusCard(LoanApplicationModel application) {
    Color bgColor;
    Color textColor;
    String message;
    IconData icon;

    switch (application.status) {
      case LoanStatus.pending:
        bgColor = AppColors.pendingLight;
        textColor = AppColors.pending;
        message = 'Your application is being reviewed';
        icon = Icons.hourglass_empty_rounded;
        break;
      case LoanStatus.approved:
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        message = 'Your application has been approved!';
        icon = Icons.check_circle_outline_rounded;
        break;
      case LoanStatus.rejected:
        bgColor = AppColors.errorLight;
        textColor = AppColors.error;
        message = 'Your application was not approved';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 48),
          const SizedBox(height: 12),
          StatusBadge(status: application.status),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Section card
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // Detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Document row with link
  Widget _buildDocumentRow(BuildContext context, int index, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Opens document URL in browser
          // We'll add url_launcher in polish phase
        },
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_outlined,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Document $index',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
