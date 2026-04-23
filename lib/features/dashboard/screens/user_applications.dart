import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/loan_application_model.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../loan_application/providers/loan_provider.dart';
import '../../../app/router.dart';
import '../../../data/models/user_model.dart';
import '../widgets/applications_mobile.dart';

class UserApplications extends ConsumerStatefulWidget {
  const UserApplications({super.key});

  @override
  ConsumerState<UserApplications> createState() => _UserApplicationsState();
}

class _UserApplicationsState extends ConsumerState<UserApplications>
    with SingleTickerProviderStateMixin {
  LoanStatus? _selectedFilter;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final loanState = ref.watch(loanNotifierProvider);
    final applications = loanState.applications;

    final filtered = _selectedFilter == null
        ? applications
        : applications.where((a) => a.status == _selectedFilter).toList();

    final total = applications.length;
    final pending =
        applications.where((a) => a.status == LoanStatus.pending).length;
    final approved =
        applications.where((a) => a.status == LoanStatus.approved).length;
    final rejected =
        applications.where((a) => a.status == LoanStatus.rejected).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1024) {
          return ApplicationsMobile(
            currentUser: currentUser,
            applications: applications,
            filtered: filtered,
            selectedFilter: _selectedFilter,
            onFilterChanged: (status) =>
                setState(() => _selectedFilter = status),
            listAnimationController: _listAnimationController,
            onLogout: _handleLogout,
          );
        }
        return _DesktopApplicationsView(
          currentUser: currentUser,
          loanState: loanState,
          filtered: filtered,
          total: total,
          pending: pending,
          approved: approved,
          rejected: rejected,
          selectedFilter: _selectedFilter,
          onFilterChanged: (status) => setState(() => _selectedFilter = status),
          onLogout: _handleLogout,
        );
      },
    );
  }
}

class _DesktopApplicationsView extends StatelessWidget {
  final UserModel? currentUser;
  final LoanState loanState;
  final List<LoanApplicationModel> filtered;
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final LoanStatus? selectedFilter;
  final Function(LoanStatus?) onFilterChanged;
  final VoidCallback onLogout;

  const _DesktopApplicationsView({
    required this.currentUser,
    required this.loanState,
    required this.filtered,
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: loanState.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: _buildDrawer(context),
        body: Row(
          children: [
            _buildSidebar(context),
            Expanded(
              child: Column(
                children: [
                  _buildTopNavBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 40),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context),
                              const SizedBox(height: 48),
                              _buildStatsGrid(context),
                              const SizedBox(height: 56),
                              _buildApplicationsSection(context),
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
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
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
                  ? Center(
                      child: Text(
                        currentUser?.fullName.isNotEmpty ?? false
                            ? currentUser!.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.primary),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applications History',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track and manage all your credit requests in one place.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 200,
          child: _HeaderButton(
            label: 'New Application',
            icon: Icons.add_circle_outline_rounded,
            onTap: () => context.go(AppRoutes.apply),
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 900 ? 2 : 4;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 32,
          mainAxisSpacing: 32,
          childAspectRatio: 1.8,
          children: [
            _StatCard(
              label: 'Total',
              value: total.toString().padLeft(2, '0'),
              icon: Icons.description_rounded,
            ),
            _StatCard(
              label: 'Pending',
              value: pending.toString().padLeft(2, '0'),
              icon: Icons.schedule_rounded,
              iconColor: const Color(0xFFD8885C),
            ),
            _StatCard(
              label: 'Approved',
              value: approved.toString().padLeft(2, '0'),
              icon: Icons.verified_rounded,
              iconColor: AppColors.success,
            ),
            _StatCard(
              label: 'Rejected',
              value: rejected.toString().padLeft(2, '0'),
              icon: Icons.cancel_rounded,
              iconColor: AppColors.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildApplicationsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              _buildFilterTabs(),
            ],
          ),
          const SizedBox(height: 40),
          if (filtered.isEmpty)
            _buildEmptyState(context)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) => _ApplicationListItem(
                application: filtered[index],
                countryCode: currentUser?.countryCode ?? 'BZ',
                onTap: () =>
                    context.go('${AppRoutes.status}/${filtered[index].id}'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilterTab(
              label: 'All',
              isSelected: selectedFilter == null,
              onTap: () => onFilterChanged(null)),
          _FilterTab(
              label: 'Pending',
              isSelected: selectedFilter == LoanStatus.pending,
              onTap: () => onFilterChanged(LoanStatus.pending)),
          _FilterTab(
              label: 'Approved',
              isSelected: selectedFilter == LoanStatus.approved,
              onTap: () => onFilterChanged(LoanStatus.approved)),
          _FilterTab(
              label: 'Rejected',
              isSelected: selectedFilter == LoanStatus.rejected,
              onTap: () => onFilterChanged(LoanStatus.rejected)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.description_outlined,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'No applications found',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'Adjust your filters to see more results',
            style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 40),
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
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarItem(
      {required this.icon,
      required this.label,
      this.isActive = false,
      required this.onTap,
      this.color});

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
              Icon(icon,
                  color: color ??
                      (isActive ? AppColors.primary : AppColors.textSecondary),
                  size: 20),
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
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: color ??
                  (isActive ? AppColors.primary : AppColors.textPrimary))),
      onTap: onTap,
      selected: isActive,
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _HeaderButton(
      {required this.label,
      required this.icon,
      required this.onTap,
      required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label.toUpperCase()),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : AppColors.primaryLight,
        foregroundColor: isPrimary ? Colors.white : AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final IconData icon;
  final Color? iconColor;

  const _StatCard(
      {required this.label,
      required this.value,
      this.trend,
      required this.icon,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary)
                        .withValues(alpha: 0.08),
                    shape: BoxShape.circle),
                child:
                    Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
              if (trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(trend!,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              letterSpacing: 1),
        ),
      ),
    );
  }
}

class _ApplicationListItem extends StatelessWidget {
  final LoanApplicationModel application;
  final String countryCode;
  final VoidCallback onTap;

  const _ApplicationListItem(
      {required this.application,
      required this.countryCode,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(_getPurposeIcon(application.loanPurpose),
                  color: AppColors.primary),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application.loanPurpose,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('Applied ${Formatters.date(application.createdAt)}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Formatters.currency(application.loanAmount, countryCode),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                StatusBadge(status: application.status),
              ],
            ),
            const SizedBox(width: 24),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  IconData _getPurposeIcon(String purpose) {
    final p = purpose.toLowerCase();
    if (p.contains('personal')) return Icons.person_rounded;
    if (p.contains('vehicle') || p.contains('car'))
      return Icons.directions_car_rounded;
    if (p.contains('business')) return Icons.business_center_rounded;
    return Icons.account_balance_rounded;
  }
}
