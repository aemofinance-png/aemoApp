import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/loan_application_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../loan_application/providers/loan_provider.dart';
import '../../../app/router.dart';
import '../../../data/models/user_model.dart';

class UserDashboard extends ConsumerStatefulWidget {
  const UserDashboard({super.key});

  @override
  ConsumerState<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ConsumerState<UserDashboard>
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
        if (constraints.maxWidth < 600) {
          return _MobileDashboard(
            currentUser: currentUser,
            loanState: loanState,
            applications: applications,
            filtered: filtered,
            total: total,
            pending: pending,
            approved: approved,
            rejected: rejected,
            selectedFilter: _selectedFilter,
            onFilterChanged: (status) =>
                setState(() => _selectedFilter = status),
            listAnimationController: _listAnimationController,
            onLogout: _handleLogout,
          );
        }
        return _DesktopDashboard(
          currentUser: currentUser,
          loanState: loanState,
          applications: applications,
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

class _DesktopDashboard extends StatelessWidget {
  final UserModel? currentUser;
  final LoanState loanState;
  final List<LoanApplicationModel> applications;
  final List<LoanApplicationModel> filtered;
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final LoanStatus? selectedFilter;
  final Function(LoanStatus?) onFilterChanged;
  final VoidCallback onLogout;

  const _DesktopDashboard({
    required this.currentUser,
    required this.loanState,
    required this.applications,
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
        backgroundColor: const Color(0xFFF7F9FB),
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
                          horizontal: 32, vertical: 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWelcomeHeader(context),
                              const SizedBox(height: 40),
                              _buildStatsGrid(context),
                              const SizedBox(height: 48),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(0)),
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
                    child: currentUser?.selfieUrl == null
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
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.userApplications);
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
                    color: AppColors.textSecondary.withOpacity(0.7),
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
        color: Colors.white.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const SizedBox(width: 12),
          Text(
            'Dashboard',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => context.go(AppRoutes.withdrawals),
          ),
          const SizedBox(width: 16),
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
                            ? currentUser!.fullName[0]
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

  Widget _buildWelcomeHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${currentUser?.fullName.split(' ').first ?? ''}!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Review your application status and manage your financial profile.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: 140,
              child: _HeaderButton(
                label: 'Calculator',
                icon: Icons.calculate_outlined,
                onTap: () => context.go(AppRoutes.calculator),
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: _HeaderButton(
                label: 'Apply',
                icon: Icons.add_circle_outline_rounded,
                onTap: () => context.go(AppRoutes.apply),
                isPrimary: true,
              ),
            ),
          ],
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
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.6,
          children: [
            _StatCard(
              label: 'Total Applications',
              value: total.toString().padLeft(2, '0'),
              trend: '+1 this month',
              icon: Icons.description_rounded,
            ),
            _StatCard(
              label: 'Pending Approval',
              value: pending.toString().padLeft(2, '0'),
              icon: Icons.schedule_rounded,
              iconColor: const Color(0xFFD8885C),
            ),
            _StatCard(
              label: 'Approved Loans',
              value: approved.toString().padLeft(2, '0'),
              icon: Icons.verified_rounded,
              iconColor: AppColors.primary,
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Applications',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              _buildFilterTabs(),
            ],
          ),
          const SizedBox(height: 32),
          if (filtered.isEmpty)
            _buildEmptyState(context)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E3E5),
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
          Icon(Icons.description_outlined,
              size: 64, color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No applications yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Apply for your first loan to get started',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Apply for a Loan',
            onPressed: () => context.go(AppRoutes.apply),
            width: 200,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _MobileDashboard extends StatelessWidget {
  final UserModel? currentUser;
  final LoanState loanState;
  final List<LoanApplicationModel> applications;
  final List<LoanApplicationModel> filtered;
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final LoanStatus? selectedFilter;
  final Function(LoanStatus?) onFilterChanged;
  final AnimationController listAnimationController;
  final VoidCallback onLogout;

  const _MobileDashboard({
    required this.currentUser,
    required this.loanState,
    required this.applications,
    required this.filtered,
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.listAnimationController,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: loanState.isLoading,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: () => context.go(AppRoutes.apply),
          backgroundColor: AppColors.primaryShade2,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        backgroundColor: AppColors.backgroundDark,
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(0)),
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
                        child: currentUser?.selfieUrl == null
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
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 13)),
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
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.userApplications);
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
        ),
        body: Column(
          children: [
            _buildNavbar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Welcome back, ${currentUser?.fullName.split(' ').first ?? ''}!',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Here is a summary of your loan applications',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textPrimary)),
                        const SizedBox(height: 32),
                        _buildStatCard(
                            context,
                            'TOTAL APPLICATIONS',
                            total.toString(),
                            AppColors.white,
                            AppColors.primaryDark),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _buildStatCard(
                                    context,
                                    'APPROVED',
                                    approved.toString(),
                                    AppColors.primaryDark,
                                    AppColors.white)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildStatCard(
                                    context,
                                    'PENDING',
                                    pending.toString(),
                                    AppColors.primaryDark,
                                    AppColors.primaryLightShade2)),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text('Your Applications',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 26),
                        _buildFilterTabs(),
                        const SizedBox(height: 26),
                        filtered.isEmpty
                            ? _buildEmptyState(context)
                            : Column(children: [
                                ...filtered
                                    .asMap()
                                    .entries
                                    .take(5)
                                    .map((entry) {
                                  final index = entry.key;
                                  final app = entry.value;
                                  final slideAnimation = Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero)
                                      .animate(CurvedAnimation(
                                          parent: listAnimationController,
                                          curve: Interval(
                                              index * 0.15,
                                              (index * 0.15 + 0.6)
                                                  .clamp(0.0, 1.0),
                                              curve: Curves.easeOutCubic)));
                                  return SlideTransition(
                                      position: slideAnimation,
                                      child: _buildApplicationCard(context, app,
                                          currentUser?.countryCode ?? 'BZ'));
                                }).toList(),
                              ]),
                        Align(
                            alignment: Alignment.center,
                            child: TextButton(
                                onPressed: () =>
                                    context.go(AppRoutes.userApplications),
                                child: Text("Show More",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600)))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                  builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer())),
              const SizedBox(width: 10),
              Text(currentUser?.fullName ?? '',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.profile),
            child: CircleAvatar(
              radius: 20,
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
                          color: AppColors.primary))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      Color color, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: color, fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 45, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context,
      LoanApplicationModel application, String countryCode) {
    return GestureDetector(
      onTap: () => context.go('${AppRoutes.status}/${application.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(application.loanPurpose,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    StatusBadge(status: application.status)
                  ]),
                  const SizedBox(height: 4),
                  Text(Formatters.currency(application.loanAmount, countryCode),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 2),
                  Text('Applied ${Formatters.date(application.createdAt)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textHint)),
                ],
              ),
            ),
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.remove_red_eye_outlined,
                    color: AppColors.primaryDark, size: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E3E5),
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

  Widget _buildFilterTab(String label, LoanStatus? status) {
    final isSelected = selectedFilter == status;
    return GestureDetector(
      onTap: () => onFilterChanged(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primaryShade2 : AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                width: 1.5,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary)),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.white : AppColors.primaryDark)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.description_outlined,
                  color: AppColors.primary, size: 32)),
          const SizedBox(height: 16),
          const Text('No applications yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Apply for your first loan to get started',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          CustomButton(
              label: 'Apply for a Loan',
              onPressed: () => context.go(AppRoutes.apply),
              width: 180),
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

  const _SidebarItem(
      {required this.icon,
      required this.label,
      this.isActive = false,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              border: isActive
                  ? const Border(
                      left: BorderSide(color: AppColors.primary, width: 4))
                  : null),
          child: Row(
            children: [
              Icon(icon,
                  color: color ??
                      (isActive ? AppColors.primary : AppColors.textSecondary),
                  size: 20),
              const SizedBox(width: 12),
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      color: color ??
                          (isActive
                              ? AppColors.primary
                              : AppColors.textSecondary))),
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

  const _DrawerItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      title: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.textPrimary)),
      onTap: onTap,
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
        backgroundColor:
            isPrimary ? AppColors.primary : const Color(0xFFD6E3FE),
        foregroundColor: isPrimary ? Colors.white : AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 48), // Use a flexible minimum width
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 32,
                offset: const Offset(0, 16))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1)),
            Icon(icon, color: iconColor ?? AppColors.primary, size: 20)
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
              if (trend != null)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(trend!,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary))),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : null),
        child: Text(label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                letterSpacing: 1)),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
                left: BorderSide(
                    color: _getStatusColor(application.status), width: 4))),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(_getPurposeIcon(application.loanPurpose),
                    color: AppColors.primary)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application.loanPurpose,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  Text('Applied ${Formatters.date(application.createdAt)}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(Formatters.currency(application.loanAmount, countryCode),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
              StatusBadge(status: application.status)
            ]),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.approved:
        return AppColors.primary;
      case LoanStatus.pending:
        return const Color(0xFFD8885C);
      case LoanStatus.rejected:
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
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
