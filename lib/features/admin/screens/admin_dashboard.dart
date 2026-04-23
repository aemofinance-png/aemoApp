import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/loan_application_model.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../../../app/router.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  LoanStatus? _selectedFilter;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.microtask(() async {
      await ref.read(adminNotifierProvider.notifier).fetchAllApplications();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AdminState>(adminNotifierProvider, (previous, next) {
      final finishedLoading =
          previous?.isLoading == true && next.isLoading == false;
      final initialDataArrival = previous == null &&
          next.isLoading == false &&
          next.applications.isNotEmpty;
      if (finishedLoading || initialDataArrival) {
        _animationController.reset();
        _animationController.forward();
      }
    });

    final adminState = ref.watch(adminNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final applications = adminState.applications;

    final filtered = _selectedFilter == null
        ? applications
        : applications.where((a) => a.status == _selectedFilter).toList();

    final totalVolume =
        applications.fold<double>(0, (sum, item) => sum + item.loanAmount);
    final pending =
        applications.where((a) => a.status == LoanStatus.pending).length;
    final approved =
        applications.where((a) => a.status == LoanStatus.approved).length;
    final rejected =
        applications.where((a) => a.status == LoanStatus.rejected).length;

    return LoadingOverlay(
      isLoading: adminState.isLoading,
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
                      _buildTopAppBar(
                          currentUser?.fullName ?? 'Admin', !isDesktop),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 48 : 20,
                              vertical: isDesktop ? 40 : 24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: isDesktop ? 1200 : 500),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeaderSection(),
                                  const SizedBox(height: 32),
                                  _buildSummaryMetrics(totalVolume, pending,
                                      approved, rejected, isDesktop),
                                  const SizedBox(height: 32),
                                  _buildQuickActions(isDesktop),
                                  const SizedBox(height: 32),
                                  _buildRecentApplicationsHeader(),
                                  const SizedBox(height: 16),
                                  _buildFilterTabs(),
                                  const SizedBox(height: 24),
                                  if (filtered.isEmpty)
                                    _buildEmptyState()
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 16),
                                      itemBuilder: (context, index) {
                                        final app = filtered[index];
                                        return _buildApplicationActivityCard(
                                            app, index);
                                      },
                                    ),
                                  const SizedBox(height: 40),
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
            isActive: true,
            onTap: () {},
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
          // _SidebarItem(
          //   icon: Icons.analytics_outlined,
          //   label: 'Reports',
          //   onTap: () {},
          // ),
          // _SidebarItem(
          //   icon: Icons.settings_outlined,
          //   label: 'Settings',
          //   onTap: () {},
          // ),
          const Spacer(),
          const Divider(),
          _SidebarItem(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            color: AppColors.error,
            onTap: _handleLogout,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(String name, bool showLogo) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (showLogo) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD5E3FF), width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDIDOdrZZ0PfNtfEq5E0gWtpAQY4CZh4v3RN5pE8X6aMNzdBvohTTHgvhWTLQRYGBkXCwSCDj6uEGjKqAotrVWWX-CXd-MVQ409twRnThfdDjNzgH3oXa_nYdFSSFoqc-ILBDp_L1fDbpcq3-Q5lw4zVlxuxUPpcjV63bMvcDqseD_0u7enU08KHF3QxHXjcDtIUFjSfUYtET2LLLLb3Lca3PekdsC05nuY9VwDPgHnW8nqID_ZkJbxi_5fYVYLHkPMSgbB3VsyjOxV'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Admin',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF001E40),
                letterSpacing: -0.5,
              ),
            ),
          ],
          const Spacer(),
          if (!showLogo) ...[
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
              image: const DecorationImage(
                image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDIDOdrZZ0PfNtfEq5E0gWtpAQY4CZh4v3RN5pE8X6aMNzdBvohTTHgvhWTLQRYGBkXCwSCDj6uEGjKqAotrVWWX-CXd-MVQ409twRnThfdDjNzgH3oXa_nYdFSSFoqc-ILBDp_L1fDbpcq3-Q5lw4zVlxuxUPpcjV63bMvcDqseD_0u7enU08KHF3QxHXjcDtIUFjSfUYtET2LLLLb3Lca3PekdsC05nuY9VwDPgHnW8nqID_ZkJbxi_5fYVYLHkPMSgbB3VsyjOxV'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (showLogo) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REVIEW CONSOLE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF525F75),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Admin Dashboard',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF001E40),
            letterSpacing: -1,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSummaryMetrics(
      double volume, int pending, int approved, int rejected, bool isDesktop) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      childAspectRatio: isDesktop ? 1.6 : 1.4,
      children: [
        _buildMetricCard(
            'Total Volume',
            '\$${(volume / 1000000).toStringAsFixed(1)}M',
            Icons.account_balance_wallet_outlined,
            const Color(0xFF003366)),
        _buildMetricCard('Pending', pending.toString(),
            Icons.pending_actions_rounded, const Color(0xFFD8885C)),
        _buildMetricCard('Approved', approved.toString(),
            Icons.verified_rounded, AppColors.primary),
        _buildMetricCard('Rejected', rejected.toString(), Icons.cancel_rounded,
            AppColors.error),
      ],
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: const Color(0xFFC3C6D1).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const Spacer(),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF737780),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF001E40),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildQuickActions(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF737780),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildActionButton(
                  'Withdrawals',
                  Icons.payments_outlined,
                  const Color(0xFF003366),
                  Colors.white,
                  () => context.go(AppRoutes.adminWithdrawals)),
              const SizedBox(width: 16),
              _buildActionButton(
                  'Registered Users',
                  Icons.group_outlined,
                  const Color(0xFFD6E3FE),
                  const Color(0xFF58657C),
                  () => context.go(AppRoutes.adminUsers)),
              // const SizedBox(width: 16),
              // _buildActionButton('Reports', Icons.analytics_outlined,
              //     const Color(0xFFE6E8EA), const Color(0xFF43474F), () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor,
      Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentApplicationsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'RECENT APPLICATIONS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF737780),
            letterSpacing: 1,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'View All',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF003366),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 12),
          _buildFilterChip('Pending', LoanStatus.pending),
          const SizedBox(width: 12),
          _buildFilterChip('Approved', LoanStatus.approved),
          const SizedBox(width: 12),
          _buildFilterChip('Rejected', LoanStatus.rejected),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, LoanStatus? status) {
    final isSelected = _selectedFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF001E40) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF001E40)
                  : const Color(0xFFC3C6D1)),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF737780),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationActivityCard(LoanApplicationModel app, int index) {
    Color statusBg;
    Color statusText;
    String statusLabel;

    switch (app.status) {
      case LoanStatus.pending:
        statusBg = const Color(0xFFFFF8E1);
        statusText = const Color(0xFF723610);
        statusLabel = 'Pending';
        break;
      case LoanStatus.approved:
        statusBg = const Color(0xFFD5E3FF);
        statusText = const Color(0xFF1F477B);
        statusLabel = 'Approved';
        break;
      case LoanStatus.rejected:
        statusBg = const Color(0xFFFFDAD6);
        statusText = const Color(0xFF93000A);
        statusLabel = 'Rejected';
        break;
    }

    return GestureDetector(
      onTap: () {
        ref.read(adminNotifierProvider.notifier).selectApplication(app);
        context.go('${AppRoutes.admin}/${app.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            if (app.status == LoanStatus.pending)
              Container(
                width: 4,
                height: 100,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF001E40),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.fullName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF001E40),
                              ),
                            ),
                            Text(
                              'ID: #${app.id.substring(0, 8).toUpperCase()}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFF737780),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: statusText,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LOAN TYPE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF737780),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              app.loanPurpose.isNotEmpty
                                  ? app.loanPurpose
                                  : 'General Loan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF191C1E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'AMOUNT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF737780),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            Formatters.currency(
                                app.loanAmount, app.countryCode),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF001E40),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: const Color(0xFFC3C6D1).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.description_outlined,
              color: const Color(0xFF001E40).withValues(alpha: 0.1), size: 64),
          const SizedBox(height: 24),
          Text(
            'No applications found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF001E40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your filters and try again',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF737780),
              fontWeight: FontWeight.w500,
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

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
    this.color,
  });

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
              Icon(
                icon,
                color: color ??
                    (isActive ? AppColors.primary : AppColors.textSecondary),
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
