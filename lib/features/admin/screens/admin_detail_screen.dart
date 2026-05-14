import 'dart:math';
import 'package:aemo_loan_app/core/constants/app_strings.dart';
import 'package:aemo_loan_app/core/utils/email_service.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:aemo_loan_app/features/admin/screens/admin_user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/loan_application_model.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/admin_provider.dart';
import '../screens/document_viewer_screen.dart';
import '../../../app/router.dart';
import '../../auth/providers/auth_provider.dart';

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
  final _rejectionReasonController = TextEditingController();
  bool _isApproving = false;
  bool _isRejecting = false;
  bool _isDeleting = false;
  bool _isLoggingOut = false;

  bool get _isActionLoading => _isApproving || _isRejecting || _isDeleting;

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminNotifierProvider.notifier).fetchAllApplications(),
    );
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) context.go(AppRoutes.login);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<void> _showRejectionDialog(
    BuildContext context,
    LoanApplicationModel app,
    UserModel applicant,
  ) async {
    _rejectionReasonController.clear();

    return showDialog(
      context: context,
      barrierDismissible: !_isRejecting,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Reject Application', 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for rejecting this application. This will be visible to the user.',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _rejectionReasonController,
              maxLines: 4,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final reason = _rejectionReasonController.text.trim();
                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a reason')),
                        );
                        return;
                      }

                      Navigator.pop(context);

                      setState(() => _isRejecting = true);
                      try {
                        final rejected = await ref
                            .read(adminNotifierProvider.notifier)
                            .rejectApplication(
                              applicationId: app.id,
                              adminNote: reason,
                            );

                        if (!rejected) return;

                        await EmailService.sendRejectionEmail(
                          duration: app.loanDuration,
                          repayment: Formatters.currency(
                            _calculateMonthlyRepayment(app),
                            applicant.countryCode,
                          ),
                          toEmail: applicant.email,
                          toName: applicant.fullName,
                          loanAmount: Formatters.currency(
                            app.loanAmount,
                            applicant.countryCode,
                          ),
                          referenceNo: app.id,
                        );

                        if (mounted) {
                          context.go(AppRoutes.admin);
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isRejecting = false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Reject', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);
    final application = adminState.applications
        .where((a) => a.id == widget.applicationId)
        .firstOrNull;
    
    if (application == null) {
      return const Scaffold(body: Center(child: Text('Application not found')));
    }

    final applicantAsync = ref.watch(userByIdProvider(application.userId));
    final applicant = applicantAsync.value;

    return LoadingOverlay(
      isLoading: (adminState.isLoading && !_isActionLoading) || _isLoggingOut,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          return Scaffold(
            backgroundColor: const Color(0xFFF7F9FB),
            body: Row(
              children: [
                if (isDesktop) _buildSidebar(context),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopNavBar(context, application, applicant, !isDesktop),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 64 : 20,
                            vertical: isDesktop ? 48 : 32,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1200),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(application, applicant),
                                  SizedBox(height: isDesktop ? 48 : 32),
                                  if (isDesktop)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: [
                                              _buildLoanDetailsCard(application, isDesktop),
                                              const SizedBox(height: 32),
                                              _buildEmploymentCard(application, isDesktop),
                                              const SizedBox(height: 32),
                                              _buildBankDetailsCard(application, isDesktop),
                                            ],
                                          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                                        ),
                                        const SizedBox(width: 40),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            children: [
                                              _buildApplicantQuickInfo(context, applicant, isDesktop),
                                              const SizedBox(height: 32),
                                              _buildDocumentsCard(context, application, isDesktop),
                                              const SizedBox(height: 32),
                                              if (application.status == LoanStatus.pending)
                                                _buildActionCard(context, application, applicant, isDesktop)
                                              else
                                                _buildReviewDetailsCard(application, isDesktop),
                                              const SizedBox(height: 32),
                                              _buildDangerZone(context, application, isDesktop),
                                            ],
                                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05),
                                        ),
                                      ],
                                    )
                                  else
                                    Column(
                                      children: [
                                        _buildLoanDetailsCard(application, isDesktop),
                                        const SizedBox(height: 24),
                                        _buildApplicantQuickInfo(context, applicant, isDesktop),
                                        const SizedBox(height: 24),
                                        _buildEmploymentCard(application, isDesktop),
                                        const SizedBox(height: 24),
                                        _buildBankDetailsCard(application, isDesktop),
                                        const SizedBox(height: 24),
                                        _buildDocumentsCard(context, application, isDesktop),
                                        const SizedBox(height: 24),
                                        if (application.status == LoanStatus.pending)
                                          _buildActionCard(context, application, applicant, isDesktop)
                                        else
                                          _buildReviewDetailsCard(application, isDesktop),
                                        const SizedBox(height: 24),
                                        _buildDangerZone(context, application, isDesktop),
                                      ],
                                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFFF2F4F6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loan Portal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'ADMIN CONSOLE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            onTap: () => context.go(AppRoutes.admin),
          ),
          _SidebarItem(
            icon: Icons.payments_outlined,
            label: 'Withdrawals',
            onTap: () => context.go(AppRoutes.adminWithdrawals),
          ),
          _SidebarItem(
            icon: Icons.group_outlined,
            label: 'Users',
            onTap: () => context.go(AppRoutes.adminUsers),
          ),
          const Spacer(),
          const Divider(),
          _SidebarItem(
            icon: Icons.logout_rounded,
            label: _isLoggingOut ? 'Logging Out...' : 'Log Out',
            color: AppColors.error,
            isLoading: _isLoggingOut,
            onTap: _handleLogout,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTopNavBar(BuildContext context, LoanApplicationModel app, UserModel? applicant, bool isMobile) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            if (isMobile) ...[
              IconButton(
                onPressed: () => context.go(AppRoutes.admin),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 16),
            ] else ...[
              const Icon(Icons.description_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 16),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Application Details',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Ref: ${app.id.toUpperCase().substring(0, 8)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            StatusBadge(status: app.status),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LoanApplicationModel app, UserModel? applicant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Formatters.currency(app.loanAmount, app.countryCode),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Loan for ${app.loanPurpose} • Requested by ${applicant?.fullName ?? '...'}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoanDetailsCard(LoanApplicationModel app, bool isDesktop) {
    return _buildThemeCard(
      title: 'LOAN SPECIFICATIONS',
      icon: Icons.analytics_outlined,
      isDesktop: isDesktop,
      child: Column(
        children: [
          _buildInfoRow('Amount Requested', Formatters.currency(app.loanAmount, app.countryCode)),
          _buildInfoRow('Duration', '${app.loanDuration} Months'),
          _buildInfoRow('Monthly Repayment', Formatters.currency(_calculateMonthlyRepayment(app), app.countryCode)),
          _buildInfoRow('Purpose of Loan', app.loanPurpose),
          _buildInfoRow('Application Date', Formatters.date(app.createdAt)),
        ],
      ),
    );
  }

  Widget _buildEmploymentCard(LoanApplicationModel app, bool isDesktop) {
    return _buildThemeCard(
      title: 'EMPLOYMENT & INCOME',
      icon: Icons.work_outline_rounded,
      isDesktop: isDesktop,
      child: Column(
        children: [
          _buildInfoRow('Current Employer', app.employer),
          _buildInfoRow('Employment Status', app.employmentStatus),
          _buildInfoRow('Monthly Net Income', Formatters.currency(app.monthlyIncome, app.countryCode)),
        ],
      ),
    );
  }

  Widget _buildBankDetailsCard(LoanApplicationModel app, bool isDesktop) {
    return _buildThemeCard(
      title: 'DISBURSEMENT BANKING',
      icon: Icons.account_balance_rounded,
      isDesktop: isDesktop,
      child: Column(
        children: [
          _buildInfoRow('Bank Name', app.bankName),
          _buildInfoRow('Account Number', app.accountNumber),
        ],
      ),
    );
  }

  Widget _buildApplicantQuickInfo(BuildContext context, UserModel? user, bool isDesktop) {
    if (user == null) return const SizedBox.shrink();
    return _buildThemeCard(
      title: 'APPLICANT INFORMATION',
      icon: Icons.person_search_rounded,
      isDesktop: isDesktop,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user.selfieUrl != null && user.selfieUrl!.isNotEmpty
                        ? NetworkImage(user.selfieUrl!)
                        : null,
                    child: user.selfieUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                  onPressed: () => context.go('${AppRoutes.adminUserProfile}/${user.id}'),
                  tooltip: 'View Full Profile',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Phone', user.phone),
          _buildInfoRow('KYC Status', user.verificationStatus.name.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(BuildContext context, LoanApplicationModel app, bool isDesktop) {
    return _buildThemeCard(
      title: 'SUPPORTING DOCUMENTS',
      icon: Icons.file_present_rounded,
      isDesktop: isDesktop,
      child: app.documentUrls.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No documents uploaded', style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 2 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: app.documentUrls.length,
              itemBuilder: (context, index) => _buildDocumentThumbnail(context, index + 1, app.documentUrls[index]),
            ),
    );
  }

  Widget _buildDocumentThumbnail(BuildContext context, int index, String url) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => DocumentViewerScreen(imageUrl: url, title: 'Document $index'),
      )),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 2),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            ),
          ),
          child: Text(
            'DOC #$index',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, LoanApplicationModel app, UserModel? applicant, bool isDesktop) {
    return _buildThemeCard(
      title: 'DECISION ACTIONS',
      icon: Icons.gavel_rounded,
      isDesktop: isDesktop,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isActionLoading ? null : () async {
                    setState(() => _isApproving = true);
                    try {
                      final approved = await ref.read(adminNotifierProvider.notifier).approveApplication(applicationId: app.id);
                      if (!approved) return;
                      await EmailService.sendApprovalEmail(
                        duration: app.loanDuration,
                        repayment: Formatters.currency(_calculateMonthlyRepayment(app), app.countryCode),
                        toEmail: applicant?.email ?? '',
                        toName: applicant?.fullName ?? 'Applicant',
                        loanAmount: Formatters.currency(app.loanAmount, app.countryCode),
                        referenceNo: app.id,
                      );
                      if (context.mounted) context.go(AppRoutes.admin);
                    } finally {
                      if (mounted) setState(() => _isApproving = false);
                    }
                  },
                  icon: _isApproving ? const SizedBox.shrink() : const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: _isApproving ? const _LoadingSpinner() : Text('APPROVE', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isActionLoading || applicant == null ? null : () => _showRejectionDialog(context, app, applicant),
                  icon: _isRejecting ? const SizedBox.shrink() : const Icon(Icons.cancel_outlined, size: 20),
                  label: _isRejecting ? const _LoadingSpinner() : Text('REJECT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewDetailsCard(LoanApplicationModel app, bool isDesktop) {
    return _buildThemeCard(
      title: 'REVIEW AUDIT',
      icon: Icons.fact_check_rounded,
      isDesktop: isDesktop,
      child: Column(
        children: [
          _buildInfoRow('Decision', app.status.name.toUpperCase()),
          if (app.reviewedAt != null) _buildInfoRow('Decision Date', Formatters.date(app.reviewedAt!)),
          if (app.adminNote != null && app.adminNote!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Internal Note',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    app.adminNote!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, LoanApplicationModel app, bool isDesktop) {
    return _buildThemeCard(
      title: 'DANGER ZONE',
      icon: Icons.warning_amber_rounded,
      isDesktop: isDesktop,
      child: OutlinedButton.icon(
        onPressed: _isActionLoading ? null : () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Delete Application?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
              content: Text('This action is permanent and cannot be undone.', style: GoogleFonts.plusJakartaSans()),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('CANCEL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold))),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('DELETE', style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          );
          if (confirm != true) return;

          setState(() => _isDeleting = true);
          try {
            await ref.read(adminNotifierProvider.notifier).deleteApplication(app.id);
            if (context.mounted) context.go(AppRoutes.admin);
          } finally {
            if (mounted) setState(() => _isDeleting = false);
          }
        },
        icon: const Icon(Icons.delete_forever_rounded, size: 20),
        label: Text(_isDeleting ? 'DELETING...' : 'DELETE APPLICATION', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isDesktop,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 40 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 32 : 24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 32 : 24),
          const Divider(height: 1),
          SizedBox(height: isDesktop ? 32 : 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;
  final bool isLoading;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Row(
            children: [
              isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          color ?? AppColors.error,
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: color ??
                          (isActive
                              ? AppColors.primary
                              : AppColors.textSecondary),
                      size: 20,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: color ??
                        (isActive
                            ? AppColors.primary
                            : AppColors.textSecondary),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingSpinner extends StatelessWidget {
  const _LoadingSpinner();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
  }
}

double _calculateMonthlyRepayment(LoanApplicationModel application) {
  final double principal = application.loanAmount;
  final double annualRate =
      AppStrings.getLoanRates(application.countryCode)[application.loanDuration] ?? 0;
  final int months = application.loanDuration;
  if (annualRate == 0) return principal / months;
  final double r = annualRate / 12 / 100;
  final double factor = pow(1 + r, months).toDouble();
  return principal * (r * factor) / (factor - 1);
}
