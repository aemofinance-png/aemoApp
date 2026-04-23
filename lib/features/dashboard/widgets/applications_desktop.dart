import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/loan_application_model.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../app/router.dart';

class ApplicationsDesktop extends StatelessWidget {
  final UserModel? currentUser;
  final List<LoanApplicationModel> applications;
  final List<LoanApplicationModel> filtered;
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final LoanStatus? selectedFilter;
  final Function(LoanStatus?) onFilterChanged;
  final VoidCallback onLogout;
  final bool isLoading;

  const ApplicationsDesktop({
    super.key,
    required this.currentUser,
    required this.applications,
    required this.filtered,
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onLogout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: _buildDrawer(context),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSidebar(context),
            Expanded(
              child: Column(
                children: [
                  _buildTopNavBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 32),
                          _buildStatsGrid(context),
                          const SizedBox(height: 32),
                          const Text(
                            'Recent Activities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFilterTabs(),
                          const SizedBox(height: 20),
                          if (filtered.isEmpty)
                            _buildEmptyState()
                          else
                            Column(
                              children: filtered
                                  .map((app) =>
                                      _buildApplicationCard(context, app))
                                  .toList(),
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon:
                  const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loan Applications',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          const Icon(Icons.notifications_none_rounded,
              color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 20),
          const Icon(Icons.help_outline_rounded,
              color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: currentUser?.selfieUrl != null &&
                      currentUser!.selfieUrl!.isNotEmpty
                  ? NetworkImage(currentUser!.selfieUrl!)
                  : null,
              child: currentUser?.selfieUrl == null ||
                      currentUser!.selfieUrl!.isEmpty
                  ? Text(
                      currentUser?.fullName.isNotEmpty ?? false
                          ? currentUser!.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.backgroundDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aemo Finance',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'AEMO LOAN APP',
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
            onTap: () {},
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

  Widget _buildDrawer(BuildContext context) {
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
                    backgroundImage: currentUser?.selfieUrl != null &&
                            currentUser!.selfieUrl!.isNotEmpty
                        ? NetworkImage(currentUser!.selfieUrl!)
                        : null,
                    child: currentUser?.selfieUrl == null ||
                            currentUser!.selfieUrl!.isEmpty
                        ? Text(
                            currentUser?.fullName.isNotEmpty ?? false
                                ? currentUser!.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(currentUser?.fullName ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  Text(currentUser?.email ?? '',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.dashboard);
                }),
            _DrawerItem(
                icon: Icons.description_outlined,
                label: 'Apply for Loan',
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.apply);
                }),
            _DrawerItem(
                icon: Icons.summarize_outlined,
                label: 'Applications',
                isActive: true,
                onTap: () {
                  Navigator.pop(context);
                }),
            _DrawerItem(
                icon: Icons.calculate_outlined,
                label: 'Calculator',
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.calculator);
                }),
            _DrawerItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Withdrawals',
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.withdrawals);
                }),
            _DrawerItem(
                icon: Icons.person_outlined,
                label: 'Profile',
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.profile);
                }),
            const Spacer(),
            const Divider(),
            _DrawerItem(
                icon: Icons.logout,
                label: 'Log Out',
                color: AppColors.error,
                onTap: onLogout),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan Applications',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage and review your credit requests.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => context.go(AppRoutes.apply),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('NEW APPLICATION'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        _buildStatCard(
            context,
            'TOTAL VALUE',
            Formatters.currency(
              applications.fold(0.0, (sum, item) => sum + item.loanAmount),
              currentUser?.countryCode ?? 'BZ',
            ),
            AppColors.white,
            AppColors.primaryDark),
        const SizedBox(height: 16),
        // Use Wrap instead of Row to avoid layout issues in some browsers/emulators
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 250,
              child: _buildStatCard(context, 'APPROVED', approved.toString(),
                  AppColors.white, AppColors.primary),
            ),
            SizedBox(
              width: 250,
              child: _buildStatCard(context, 'PENDING', pending.toString(),
                  AppColors.primaryDark, AppColors.primaryLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      Color color, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, LoanApplicationModel app) {
    return GestureDetector(
      onTap: () => context.go('${AppRoutes.status}/${app.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        app.loanPurpose,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: app.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.currency(
                        app.loanAmount, currentUser?.countryCode ?? 'BZ'),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Applied ${Formatters.date(app.createdAt)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textHint, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterTab('All', null),
          const SizedBox(width: 10),
          _buildFilterTab('Pending', LoanStatus.pending),
          const SizedBox(width: 10),
          _buildFilterTab('Approved', LoanStatus.approved),
          const SizedBox(width: 10),
          _buildFilterTab('Rejected', LoanStatus.rejected),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, LoanStatus? status) {
    final isSelected = selectedFilter == status;
    return GestureDetector(
      onTap: () => onFilterChanged(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text(
          'No applications found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
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
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  color: color ??
                      (isActive ? AppColors.primary : AppColors.textSecondary),
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

  const _DrawerItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color,
      this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color:
              color ?? (isActive ? AppColors.primary : AppColors.textPrimary),
          size: 22),
      title: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      onTap: onTap,
    );
  }
}
