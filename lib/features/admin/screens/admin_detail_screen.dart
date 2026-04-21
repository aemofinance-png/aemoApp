import 'dart:math';

import 'package:aemo_loan_app/core/constants/app_strings.dart';
import 'package:aemo_loan_app/core/utils/email_service.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:aemo_loan_app/features/admin/screens/admin_user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/loan_application_model.dart';

import '../../../shared/widgets/loading_overlay.dart';
import '../providers/admin_provider.dart';
import '../screens/document_viewer_screen.dart';
import '../../../app/router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../loan_application/providers/loan_provider.dart';

class AdminDetailScreen extends ConsumerStatefulWidget {
  const AdminDetailScreen({
    super.key,
    required this.applicationId,
    required this.userId,
  });
  final String applicationId;
  final String userId;

  @override
  ConsumerState<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends ConsumerState<AdminDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminNotifierProvider.notifier).fetchAllApplications(),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final adminState = ref.watch(adminNotifierProvider);
    final application = adminState.applications
        .where((a) => a.id == widget.applicationId)
        .firstOrNull;
    final loanState = ref.watch(loanNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';

    if (application == null) {
      return const Scaffold(
        body: Center(
          child: Text('Application not found'),
        ),
      );
    }
    final applicantAsync = ref.watch(userByIdProvider(application!.userId));
    final applicant = applicantAsync.value;

    Widget _buildActionButtons(
      BuildContext context,
      WidgetRef ref,
      LoanApplicationModel app,
      UserModel user,
    ) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: app.status == LoanStatus.pending
                  ? () async {
                      await ref
                          .read(adminNotifierProvider.notifier)
                          .approveApplication(applicationId: app.id);
                      await EmailService.sendApprovalEmail(
                        duration: app.loanDuration,
                        repayment: Formatters.currency(
                            _calculateMonthlyRepayment(app), user.countryCode),
                        toEmail: applicant?.email ?? '',
                        toName: applicant!.fullName,
                        loanAmount: Formatters.currency(
                            app.loanAmount, user.countryCode),
                        referenceNo: app.id,
                        // date: app.createdAt);
                      );

                      if (context.mounted) {
                        context.go(AppRoutes.admin);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('Approve'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: app.status == LoanStatus.pending
                  ? () async {
                      await ref
                          .read(adminNotifierProvider.notifier)
                          .rejectApplication(applicationId: app.id);
                      await EmailService.sendRejectionEmail(
                        duration: app.loanDuration,
                        repayment: Formatters.currency(
                            _calculateMonthlyRepayment(app), user.countryCode),
                        toEmail: applicant?.email ?? '',
                        toName: applicant!.fullName,
                        loanAmount: Formatters.currency(
                            app.loanAmount, user.countryCode),
                        referenceNo: app.id,
                        // date: app.createdAt);
                      );
                      if (context.mounted) {
                        context.go(AppRoutes.admin);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Reject'),
            ),
          ),
        ],
      );
    }

    return LoadingOverlay(
        isLoading: adminState.isLoading,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Application Details'),
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.textPrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
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
                      _buildDetailRow(
                          'Monthly Income',
                          Formatters.currency(
                              application.monthlyIncome, countryCode)),
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
// Action buttons (only show if pending)
                  _buildActionButtons(context, ref, application, applicant!),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(adminNotifierProvider.notifier)
                          .deleteApplication(application.id);
                      if (context.mounted) {
                        context.go(AppRoutes.admin);
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Application'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorButton,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(
                          '${AppRoutes.adminUserProfile}/${application.userId}');
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('User Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Back button

                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.admin),
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
        ));
  }
}

Widget _buildStatusCard(LoanApplicationModel application) {
  Color bgColor;
  Color textColor;
  String message;
  IconData icon;

  switch (application.status) {
    case LoanStatus.pending:
      bgColor = AppColors.pendingLight;
      textColor = AppColors.pending;
      message = 'This application is being reviewed';
      icon = Icons.hourglass_empty_rounded;
      break;
    case LoanStatus.approved:
      bgColor = AppColors.successLight;
      textColor = AppColors.success;
      message = 'This application has been approved!';
      icon = Icons.check_circle_outline_rounded;
      break;
    case LoanStatus.rejected:
      bgColor = AppColors.errorLight;
      textColor = AppColors.error;
      message = 'This application was not approved';
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

// Widget _buildLoanSection(LoanApplicationModel app) {
//   return Card(
//     child: Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Loan Details',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Amount: ${Formatters.currency(app.loanAmount, app.countryCode)}',
//           ),
//           Text('Purpose: ${app.loanPurpose}'),
//           Text('Applied: ${Formatters.date(app.createdAt)}'),
//           Text('Status: ${app.status.name.toUpperCase()}'),
//         ],
//       ),
//     ),
//   );
// }

Widget _buildDocumentRow(
  BuildContext context,
  int index,
  String url,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentViewerScreen(
              imageUrl: url,
              title: 'Document $index',
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, size: 40),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Document $index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

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

double _calculateMonthlyRepayment(LoanApplicationModel application) {
  final double principal = application.loanAmount;
  final double annualRate = AppStrings.loanRates[application.loanDuration] ?? 0;
  final int months = application.loanDuration;

  if (annualRate == 0) return principal / months;

  final double r = annualRate / 12 / 100;
  final double factor = pow(1 + r, months).toDouble();
  return principal * (r * factor) / (factor - 1);
}
