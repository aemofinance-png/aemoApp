import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<void> _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final loanState = ref.watch(loanNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    final application = loanState.applications
        .where((a) => a.id == widget.applicationId)
        .firstOrNull;

    if (application == null) {
      if (loanState.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Application not found')),
        body: const Center(
          child: Text('Application not found',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1024) {
          return _MobileStatusView(
            application: application,
            currentUser: currentUser,
            isLoading: _isLoading,
            isLoading2: _isLoading2,
            calculateMonthlyRepayment: _calculateMonthlyRepayment,
            generateAgreement: _generateAgreement,
          );
        }
        return _DesktopStatusView(
          application: application,
          currentUser: currentUser,
          isLoading: _isLoading,
          isLoading2: _isLoading2,
          calculateMonthlyRepayment: _calculateMonthlyRepayment,
          generateAgreement: _generateAgreement,
          onLogout: _handleLogout,
        );
      },
    );
  }

  Future<void> _generateAgreement(
    BuildContext context,
    LoanApplicationModel application,
    UserModel currentUser,
  ) async {
    setState(() => _isLoading = true);

    final firstPayment = application.reviewedAt?.add(const Duration(days: 60)) ??
        DateTime.now().add(const Duration(days: 60));
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

    try {
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
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _DesktopStatusView extends StatelessWidget {
  final LoanApplicationModel application;
  final UserModel? currentUser;
  final bool isLoading;
  final bool isLoading2;
  final double Function(LoanApplicationModel) calculateMonthlyRepayment;
  final Function(BuildContext, LoanApplicationModel, UserModel) generateAgreement;
  final VoidCallback onLogout;

  const _DesktopStatusView({
    required this.application,
    required this.currentUser,
    required this.isLoading,
    required this.isLoading2,
    required this.calculateMonthlyRepayment,
    required this.generateAgreement,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final countryCode = currentUser?.countryCode ?? 'BZ';
    final canVerify = application.status == LoanStatus.approved &&
        currentUser?.verificationStatus == VerificationStatus.unverified;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      drawer: _buildSharedDrawer(context, currentUser, onLogout),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildTopNavBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 48),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column: Main Info
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildMainLoanInfoCard(context, countryCode),
                                      const SizedBox(height: 32),
                                      _buildDocumentsSection(context),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 40),
                                // Right Column: Actions & Roadmap
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _buildAssistanceCard(context),
                                      const SizedBox(height: 32),
                                      _buildRoadmapCard(context),
                                      if (canVerify || application.status == LoanStatus.approved) ...[
                                        const SizedBox(height: 32),
                                        _buildActionsCard(context, canVerify),
                                      ],
                                      const SizedBox(height: 32),
                                      _buildProTipCard(context),
                                    ],
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
              ],
            ),
          ),
        ],
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
                  'ENTERPRISE LEDGER',
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
            onTap: () => context.go(AppRoutes.dashboard),
          ),
          _SidebarItem(
            icon: Icons.description_outlined,
            label: 'Apply for Loan',
            onTap: () => context.go(AppRoutes.apply),
          ),
          _SidebarItem(
            icon: Icons.summarize_outlined,
            label: 'Applications',
            isActive: true,
            onTap: () => context.go(AppRoutes.userApplications),
          ),
          _SidebarItem(
            icon: Icons.calculate_outlined,
            label: 'Calculator',
            onTap: () => context.go(AppRoutes.calculator),
          ),
          _SidebarItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Withdrawals',
            onTap: () => context.go(AppRoutes.withdrawals),
          ),
          _SidebarItem(
            icon: Icons.person_outlined,
            label: 'Profile',
            onTap: () => context.go(AppRoutes.profile),
          ),
          const Spacer(),
          const Divider(),
          _SidebarItem(
            icon: Icons.logout,
            label: 'Log Out',
            color: AppColors.error,
            onTap: onLogout,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                image: currentUser?.selfieUrl != null &&
                        currentUser!.selfieUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(currentUser!.selfieUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: currentUser?.selfieUrl == null ||
                      currentUser!.selfieUrl!.isEmpty
                  ? Center(
                      child: Text(
                        currentUser?.fullName.isNotEmpty ?? false
                            ? currentUser!.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    String statusTitle;
    Color phaseColor;

    switch (application.status) {
      case LoanStatus.pending:
        statusTitle = 'Pending Review';
        phaseColor = AppColors.warning;
        break;
      case LoanStatus.approved:
        statusTitle = 'Approved';
        phaseColor = AppColors.success;
        break;
      case LoanStatus.rejected:
        statusTitle = 'Rejected';
        phaseColor = AppColors.error;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LOAN APPLICATION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '#${application.id.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Loan Status',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your application is currently under internal review.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: phaseColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CURRENT PHASE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHint,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    statusTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainLoanInfoCard(BuildContext context, String countryCode) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOAN DETAILS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Edit Details',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              _buildLargeStat('REQUESTED AMOUNT', Formatters.currency(application.loanAmount, countryCode)),
              const SizedBox(width: 80),
              _buildLargeStat('TERM LENGTH', '${application.loanDuration} Months'),
              const SizedBox(width: 80),
              _buildLargeStat('INTEREST (APR)', '${AppStrings.loanRates[application.loanDuration]}%'),
            ],
          ),
          const SizedBox(height: 64),
          const Divider(color: AppColors.border),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMPLOYMENT INFORMATION',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHint,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.business_center_outlined, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                application.employer,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                application.employmentStatus,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINANCIAL INSTITUTION',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHint,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                application.bankName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'Account ending in •••• ${application.accountNumber.length >= 4 ? application.accountNumber.substring(application.accountNumber.length - 4) : application.accountNumber}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildLargeStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.textHint,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUBMITTED DOCUMENTS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          if (application.documentUrls.isEmpty)
            Text('No documents submitted', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary))
          else
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: application.documentUrls.asMap().entries.map((entry) {
                return _buildDocumentTile(context, entry.key, entry.value);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(BuildContext context, int index, String url) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document_${index + 1}.pdf',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'VIEW DOCUMENT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textSecondary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DocumentViewerScreen(
                  imageUrl: url,
                  title: 'Document ${index + 1}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need assistance?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your dedicated loan officer can help clarify terms or assist with additional documentation requirements.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.headset_mic_outlined, size: 18),
            label: const Text('Speak with a Loan Officer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sarah Henderson',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Senior Underwriting Liaison',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APPLICATION ROADMAP',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textHint,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 32),
          _buildRoadmapStep(
            'Application Submitted',
            Formatters.date(application.createdAt),
            isCompleted: true,
          ),
          _buildRoadmapStep(
            'Pending Internal Review',
            'Estimated completion in 48h',
            isActive: application.status == LoanStatus.pending,
            isCompleted: application.status != LoanStatus.pending,
          ),
          _buildRoadmapStep(
            'Credit Committee Approval',
            'Awaiting previous steps',
            isActive: application.status == LoanStatus.approved,
            isCompleted: application.status == LoanStatus.approved,
          ),
          _buildRoadmapStep(
            'Final Documentation',
            'Awaiting previous steps',
            isLast: true,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapStep(String title, String subtitle, {bool isCompleted = false, bool isActive = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.success : (isActive ? AppColors.primary : const Color(0xFFF2F4F6)),
                  shape: BoxShape.circle,
                  border: isCompleted || isActive ? null : Border.all(color: AppColors.border),
                ),
                child: Icon(
                  isCompleted ? Icons.check : (isActive ? Icons.access_time : Icons.lock_outline),
                  color: isCompleted || isActive ? Colors.white : AppColors.textHint,
                  size: 16,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isCompleted || isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isCompleted || isActive ? AppColors.primary : AppColors.textHint,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, bool canVerify) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          if (canVerify)
            _buildActionBtn('PROCEED TO KYC', Icons.perm_identity, () => context.go(AppRoutes.kyc)),
          if (application.status == LoanStatus.approved) ...[
            if (canVerify) const SizedBox(height: 16),
            _buildActionBtn(
              isLoading ? 'PREPARING AGREEMENT...' : 'VIEW LOAN AGREEMENT',
              Icons.picture_as_pdf,
              () => generateAgreement(context, application, currentUser!),
              loading: isLoading,
            ),
            const SizedBox(height: 16),
            _buildActionBtn(
              isLoading2 ? 'LOADING...' : 'PROCEED TO WITHDRAWAL',
              Icons.account_balance_outlined,
              () => context.go('${AppRoutes.withdrawal}/${application.id}', extra: application),
              loading: isLoading2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, VoidCallback onPressed, {bool loading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildProTipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                children: [
                  TextSpan(text: 'Pro Tip: ', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const TextSpan(text: 'Keeping your linked bank accounts active helps speed up the final automated verification phase.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileStatusView extends StatelessWidget {
  final LoanApplicationModel application;
  final UserModel? currentUser;
  final bool isLoading;
  final bool isLoading2;
  final double Function(LoanApplicationModel) calculateMonthlyRepayment;
  final Function(BuildContext, LoanApplicationModel, UserModel) generateAgreement;

  const _MobileStatusView({
    required this.application,
    required this.currentUser,
    required this.isLoading,
    required this.isLoading2,
    required this.calculateMonthlyRepayment,
    required this.generateAgreement,
  });

  @override
  Widget build(BuildContext context) {
    final countryCode = currentUser?.countryCode ?? 'BZ';
    final canVerify = application.status == LoanStatus.approved &&
        currentUser?.verificationStatus == VerificationStatus.unverified;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(application),
            const SizedBox(height: 24),
            _buildSectionLabel('LOAN DETAILS'),
            const SizedBox(height: 8),
            _buildLoanDetailsCard(application, countryCode),
            const SizedBox(height: 24),
            _buildSectionLabel('EMPLOYMENT DETAILS'),
            const SizedBox(height: 8),
            _buildEmploymentCard(application, countryCode),
            const SizedBox(height: 24),
            _buildSectionLabel('BANK DETAILS'),
            const SizedBox(height: 8),
            _buildBankCard(application),
            const SizedBox(height: 24),
            _buildSectionLabel('SUBMITTED DOCUMENTS'),
            const SizedBox(height: 8),
            _buildDocumentsCard(context, application),
            if (application.status != LoanStatus.pending) ...[
              const SizedBox(height: 24),
              _buildSectionLabel('REVIEW DETAILS'),
              const SizedBox(height: 8),
              _buildReviewCard(application),
            ],
            const SizedBox(height: 32),
            if (canVerify)
              _buildActionButton(
                label: 'Proceed to KYC',
                icon: Icons.perm_identity,
                onPressed: () => context.go(AppRoutes.kyc),
              ),
            if (application.status == LoanStatus.approved) ...[
              const SizedBox(height: 12),
              _buildActionButton(
                label: isLoading ? 'Preparing...' : 'View Loan Agreement',
                icon: Icons.picture_as_pdf,
                isLoading: isLoading,
                onPressed: () => generateAgreement(context, application, currentUser!),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: isLoading2 ? 'Loading...' : 'Proceed to Withdrawal',
                icon: Icons.account_balance_outlined,
                isLoading: isLoading2,
                onPressed: () => context.go('${AppRoutes.withdrawal}/${application.id}', extra: application),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(LoanApplicationModel application) {
    String statusTitle;
    String statusMessage;

    switch (application.status) {
      case LoanStatus.pending:
        statusTitle = 'Pending Review';
        statusMessage = 'Our team is currently reviewing your application. Estimated completion: 1-3 business days.';
        break;
      case LoanStatus.approved:
        statusTitle = 'Approved!';
        statusMessage = 'Congratulations! Your loan has been approved. View your agreement below.';
        break;
      case LoanStatus.rejected:
        statusTitle = 'Not Approved';
        statusMessage = 'Unfortunately your application was not approved at this time.';
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
            style: const TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(statusTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(statusMessage, style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.4));
  }

  Widget _buildLoanDetailsCard(LoanApplicationModel application, String countryCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _detailRow('Requested Amount', Formatters.currency(application.loanAmount, countryCode), isBold: true),
          const Divider(height: 24),
          _detailRow('Loan Term', Formatters.duration(application.loanDuration), isBold: true),
          const Divider(height: 24),
          _detailRow('Interest Rate (Est.)', '${AppStrings.loanRates[application.loanDuration]}% APR', isBold: true),
          const Divider(height: 24),
          _detailRow('Monthly Repayment', Formatters.currency(calculateMonthlyRepayment(application), countryCode), isBold: true),
          const Divider(height: 24),
          _detailRow('Applied On', Formatters.date(application.createdAt)),
        ],
      ),
    );
  }

  Widget _buildEmploymentCard(LoanApplicationModel application, String countryCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(application.employer, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(application.employmentStatus, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text('MONTHLY INCOME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(Formatters.currency(application.monthlyIncome, countryCode), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildBankCard(LoanApplicationModel application) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(application.bankName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('Ending in •••• ${application.accountNumber.length >= 4 ? application.accountNumber.substring(application.accountNumber.length - 4) : application.accountNumber}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(BuildContext context, LoanApplicationModel application) {
    if (application.documentUrls.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        children: application.documentUrls.asMap().entries.map((entry) {
          final isLast = entry.key == application.documentUrls.length - 1;
          return Column(
            children: [
              ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentViewerScreen(imageUrl: entry.value, title: 'Document ${entry.key + 1}'))),
                leading: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary, size: 18),
                title: Text('Document ${entry.key + 1}.pdf', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.download_outlined, color: AppColors.textSecondary, size: 20),
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(LoanApplicationModel application) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _detailRow('Decision', application.status == LoanStatus.approved ? 'Approved' : 'Rejected', isBold: true),
          if (application.reviewedAt != null) ...[
            const Divider(height: 24),
            _detailRow('Reviewed On', Formatters.date(application.reviewedAt!)),
          ],
          if (application.adminNote != null && application.adminNote!.isNotEmpty) ...[
            const Divider(height: 24),
            _detailRow('Note', application.adminNote!),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onPressed, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border));
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarItem({required this.icon, required this.label, this.isActive = false, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: color ?? (isActive ? AppColors.primary : AppColors.textSecondary), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: color ?? (isActive ? AppColors.primary : AppColors.textSecondary),
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isActive;

  const _DrawerItem({required this.icon, required this.label, required this.onTap, this.color, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? (isActive ? AppColors.primary : AppColors.textPrimary), size: 22),
      title: Text(label, style: TextStyle(fontSize: 15, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: color ?? (isActive ? AppColors.primary : AppColors.textPrimary))),
      onTap: onTap,
    );
  }
}

Widget _buildSharedDrawer(BuildContext context, UserModel? user, VoidCallback onLogout) {
  return Drawer(
    child: SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: AppColors.primaryDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: user?.selfieUrl != null && user!.selfieUrl!.isNotEmpty
                      ? NetworkImage(user.selfieUrl!)
                      : null,
                  child: user?.selfieUrl == null || user!.selfieUrl!.isEmpty
                      ? Text(user?.fullName.isNotEmpty ?? false ? user!.fullName[0].toUpperCase() : '?', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary))
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user?.fullName ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                Text(user?.email ?? '', style: const TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard', onTap: () { Navigator.pop(context); context.go(AppRoutes.dashboard); }),
          _DrawerItem(icon: Icons.description_outlined, label: 'Apply for Loan', onTap: () { Navigator.pop(context); context.go(AppRoutes.apply); }),
          _DrawerItem(icon: Icons.summarize_outlined, label: 'Applications', onTap: () { Navigator.pop(context); context.go(AppRoutes.userApplications); }),
          _DrawerItem(icon: Icons.calculate_outlined, label: 'Calculator', onTap: () { Navigator.pop(context); context.go(AppRoutes.calculator); }),
          _DrawerItem(icon: Icons.account_balance_wallet_outlined, label: 'Withdrawals', onTap: () { Navigator.pop(context); context.go(AppRoutes.withdrawals); }),
          _DrawerItem(icon: Icons.person_outlined, label: 'Profile', onTap: () { Navigator.pop(context); context.go(AppRoutes.profile); }),
          const Spacer(),
          const Divider(),
          _DrawerItem(icon: Icons.logout, label: 'Log Out', color: AppColors.error, onTap: onLogout),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

Widget _buildSharedDataField(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
