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
import '../../admin/screens/document_viewer_screen.dart';
import 'package:web/web.dart' as web;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:js_interop';

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
  bool _isLoading = false;
  bool _isLoading2 = false;

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
  Widget build(BuildContext context) {
    final loanState = ref.watch(loanNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';

    final application = loanState.applications
        .where((a) => a.id == widget.applicationId)
        .firstOrNull;

    final canVerify = application?.status == LoanStatus.approved &&
        currentUser?.verificationStatus == VerificationStatus.unverified;

    if (application == null) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text('Application not found',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status Hero Card ──────────────────────
                _buildHeroCard(application),

                const SizedBox(height: 24),

                // ── Loan Details ──────────────────────────
                _buildSectionLabel('LOAN DETAILS'),
                const SizedBox(height: 8),
                _buildLoanDetailsCard(application, countryCode),

                const SizedBox(height: 24),

                // ── Employment Details ────────────────────
                _buildSectionLabel('EMPLOYMENT DETAILS'),
                const SizedBox(height: 8),
                _buildEmploymentCard(application, countryCode),

                const SizedBox(height: 24),

                // ── Bank Details ──────────────────────────
                _buildSectionLabel('BANK DETAILS'),
                const SizedBox(height: 8),
                _buildBankCard(application),

                const SizedBox(height: 24),

                // ── Documents ─────────────────────────────
                _buildSectionLabel('SUBMITTED DOCUMENTS'),
                const SizedBox(height: 8),
                _buildDocumentsCard(application),

                // ── Review Details ────────────────────────
                if (application.status != LoanStatus.pending) ...[
                  const SizedBox(height: 24),
                  _buildSectionLabel('REVIEW DETAILS'),
                  const SizedBox(height: 8),
                  _buildReviewCard(application),
                ],

                const SizedBox(height: 32),

                // ── Action Buttons ────────────────────────
                if (canVerify)
                  _buildActionButton(
                    label: 'Proceed to KYC',
                    icon: Icons.perm_identity,
                    onPressed: () => context.go(AppRoutes.kyc),
                  ),

                if (application.status == LoanStatus.approved) ...[
                  const SizedBox(height: 12),
                  _buildActionButton(
                    label: _isLoading ? 'Generating...' : 'View Loan Agreement',
                    icon: Icons.picture_as_pdf,
                    isLoading: _isLoading,
                    onPressed: () =>
                        _generateAgreement(context, application, currentUser!),
                  ),
                  if (application.status == LoanStatus.approved) ...[
                    const SizedBox(height: 12),
                    _buildActionButton(
                      label:
                          _isLoading2 ? 'Loading...' : 'Proceed to Withdrawal',
                      icon: Icons.account_balance_outlined,
                      isLoading: _isLoading2,
                      onPressed: () => context.go(
                        '${AppRoutes.withdrawal}/${application.id}',
                        extra: application,
                      ),
                    ),
                  ],
                ],

                // const SizedBox(height: 12),
                // _buildActionButton(
                //   label: 'Speak with a Loan Officer',
                //   icon: Icons.headset_mic_outlined,
                //   onPressed: () => context.go(AppRoutes.dashboard),
                // ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero Card ─────────────────────────────────────────────
  Widget _buildHeroCard(LoanApplicationModel application) {
    String statusTitle;
    String statusMessage;

    switch (application.status) {
      case LoanStatus.pending:
        statusTitle = 'Pending Review';
        statusMessage =
            'Our team is currently reviewing your application. Estimated completion: 1-3 business days.';
        break;
      case LoanStatus.approved:
        statusTitle = 'Approved!';
        statusMessage =
            'Congratulations! Your loan has been approved. View your agreement below.';
        break;
      case LoanStatus.rejected:
        statusTitle = 'Not Approved';
        statusMessage =
            'Unfortunately your application was not approved at this time.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APPLICATION REFERENCE: #${application.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusMessage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.4,
      ),
    );
  }

  // ── Loan Details Card ─────────────────────────────────────
  Widget _buildLoanDetailsCard(
      LoanApplicationModel application, String countryCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildDetailRowNew(
            'Requested Amount',
            Formatters.currency(application.loanAmount, countryCode),
            isBold: true,
          ),
          const Divider(height: 24),
          _buildDetailRowNew(
            'Loan Term',
            Formatters.duration(application.loanDuration),
            isBold: true,
          ),
          const Divider(height: 24),
          _buildDetailRowNew(
            'Interest Rate (Est.)',
            '${AppStrings.loanRates[application.loanDuration]}% APR',
            isBold: true,
          ),
          const Divider(height: 24),
          _buildDetailRowNew(
            'Monthly Repayment',
            Formatters.currency(
                _calculateMonthlyRepayment(application), countryCode),
            isBold: true,
          ),
          const Divider(height: 24),
          _buildDetailRowNew(
            'Applied On',
            Formatters.date(application.createdAt),
            isBold: false,
          ),
        ],
      ),
    );
  }

  // ── Employment Card ───────────────────────────────────────
  Widget _buildEmploymentCard(
      LoanApplicationModel application, String countryCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business_outlined,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.employer,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      application.employmentStatus,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MONTHLY INCOME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(
                          application.monthlyIncome, countryCode),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bank Card ─────────────────────────────────────────────
  Widget _buildBankCard(LoanApplicationModel application) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.bankName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Ending in •••• ${application.accountNumber.length >= 4 ? application.accountNumber.substring(application.accountNumber.length - 4) : application.accountNumber}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // const Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
    );
  }

  // ── Documents Card ────────────────────────────────────────
  Widget _buildDocumentsCard(LoanApplicationModel application) {
    if (application.documentUrls.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: const Text('No documents uploaded',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      );
    }

    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        children: application.documentUrls.asMap().entries.map((entry) {
          final index = entry.key;
          final url = entry.value;
          final isLast = index == application.documentUrls.length - 1;
          final fileName = 'Document_${index + 1}.pdf';

          return Column(
            children: [
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentViewerScreen(
                      imageUrl: url,
                      title: 'Document ${index + 1}',
                    ),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.insert_drive_file_outlined,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.download_outlined,
                          color: AppColors.textSecondary, size: 20),
                    ],
                  ),
                ),
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Review Card ───────────────────────────────────────────
  Widget _buildReviewCard(LoanApplicationModel application) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildDetailRowNew(
            'Decision',
            application.status == LoanStatus.approved ? 'Approved' : 'Rejected',
            isBold: true,
          ),
          if (application.reviewedAt != null) ...[
            const Divider(height: 24),
            _buildDetailRowNew(
              'Reviewed On',
              Formatters.date(application.reviewedAt!),
              isBold: false,
            ),
          ],
          if (application.adminNote != null &&
              application.adminNote!.isNotEmpty) ...[
            const Divider(height: 24),
            _buildDetailRowNew(
              'Note',
              application.adminNote!,
              isBold: false,
            ),
          ],
        ],
      ),
    );
  }

  // ── Detail Row ────────────────────────────────────────────
  Widget _buildDetailRowNew(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Action Button ─────────────────────────────────────────
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Card Decoration ───────────────────────────────────────
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    );
  }

  // ── App Bar ───────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(AppRoutes.dashboard),
      ),
      title: const Text(
        'Loan Status',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    );
  }

  Future<void> _generateAgreement(
    BuildContext context,
    LoanApplicationModel application,
    UserModel currentUser,
  ) async {
    setState(() => _isLoading = true);

    final firstPayment = application.reviewedAt!.add(const Duration(days: 60));
    final firstPaymentDate =
        '${firstPayment.year}-${firstPayment.month.toString().padLeft(2, '0')}-${firstPayment.day.toString().padLeft(2, '0')}';

    final now = DateTime.now();
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final agreementDate =
        '${monthNames[now.month - 1]} ${now.day}, ${now.year}';

    final response = await http.post(
      Uri.parse(
          'https://loan-agreement-script.onrender.com/generate-agreement'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'clientName': currentUser.fullName,
        'loanAmount': application.loanAmount,
        'annualRatePct': AppStrings.loanRates[application.loanDuration],
        'loanTermMonths': application.loanDuration,
        'monthlyPayment': _calculateMonthlyRepayment(application),
        'firstPaymentDate': firstPaymentDate,
        'agreementDate': agreementDate,
        'referenceNo': application.id,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final blob = web.Blob([response.bodyBytes.toJS].toJS,
          web.BlobPropertyBag(type: 'application/pdf'));
      final url = web.URL.createObjectURL(blob);
      web.window.open(url, '_blank', '');
      web.URL.revokeObjectURL(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate agreement')),
        );
      }
    }
  }
}
