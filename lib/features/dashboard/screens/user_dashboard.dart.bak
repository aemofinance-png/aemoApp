import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  // Handle logout
  Future<void> _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final loanState = ref.watch(loanNotifierProvider);
    final applications = loanState.applications;
    ref.listen<LoanState>(loanNotifierProvider, (previous, next) {
      if (next.applications.isNotEmpty &&
          previous?.applications.isEmpty == true) {
        _listAnimationController.reset();
        _listAnimationController.forward();
      }
    });
    final filtered = _selectedFilter == null
        ? applications
        : applications.where((a) => a.status == _selectedFilter).toList();

    // Compute stats
    final total = applications.length;
    final pending =
        applications.where((a) => a.status == LoanStatus.pending).length;
    final approved =
        applications.where((a) => a.status == LoanStatus.approved).length;
    final rejected =
        applications.where((a) => a.status == LoanStatus.rejected).length;

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
                // Header
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
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentUser?.fullName ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        currentUser?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Menu items
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.dashboard);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.description_outlined,
                  label: 'Apply for Loan',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.apply);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.summarize_outlined,
                  label: 'Applications',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.userApplications);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.calculate_outlined,
                  label: 'Calculator',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.calculator);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Withdrawals',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.withdrawals);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outlined,
                  label: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.profile);
                  },
                ),

                const Spacer(),

                const Divider(),

                // Logout
                _buildDrawerItem(
                  icon: Icons.logout,
                  label: 'Log Out',
                  color: AppColors.error,
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (mounted) context.go(AppRoutes.login);
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            // Navbar
            _buildNavbar(currentUser?.fullName ?? '', currentUser),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome
                        Text(
                          'Welcome back, ${currentUser?.fullName.split(' ').first ?? ''}!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here is a summary of your loan applications',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                        ),

                        const SizedBox(height: 32),
                        _buildStatCard('TOTAL APPLICATIONS', total.toString(),
                            AppColors.white, AppColors.primaryDark),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                  'APPROVED',
                                  approved.toString(),
                                  AppColors.primaryDark,
                                  AppColors.white),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                  'PENDING',
                                  pending.toString(),
                                  AppColors.primaryDark,
                                  AppColors.primaryLightShade2),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),
                        
                        const SizedBox(height: 30),
                        
                        // Applications header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Applications',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),
                        _buildFilterTabs(),
                        const SizedBox(height: 26),
                        // Applications list
                        filtered.isEmpty
                            ? _buildEmptyState()
                            : Column(children: [
                                ...filtered
                                    .asMap()
                                    .entries
                                    .take(5)
                                    .map((entry) {
                                  final index = entry.key;
                                  final app = entry.value;

                                  final slideAnimation = Tween<Offset>(
                                    begin: const Offset(
                                        1, 0), // starts from the right
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: _listAnimationController,
                                    curve: Interval(
                                      index *
                                          0.15, // stagger — each card starts slightly later
                                      (index * 0.15 + 0.6).clamp(0.0, 1.0),
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ));

                                  return SlideTransition(
                                    position: slideAnimation,
                                    child: _buildApplicationCard(
                                        app, currentUser?.countryCode ?? 'BZ'),
                                  );
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
                                        fontWeight: FontWeight.w600,
                                      )),
                            ))
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

  // Navbar
  Widget _buildNavbar(String userName, UserModel? currentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 10),
              Text(userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      )),
            ],
          ),
// In _buildNavbar, add to the leading side:

          // User info + logout
          Row(
            children: [
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
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stat card
  Widget _buildStatCard(
      String label, String value, Color color, Color bgColor) {
    return Material(
      // elevation: 5,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  // Application card
  Widget _buildApplicationCard(
      LoanApplicationModel application, String countryCode) {
    return GestureDetector(
      onTap: () => context.go('${AppRoutes.status}/${application.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Left accent border
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Purpose + status badge on same line
                  Row(
                    children: [
                      Text(
                        application.loanPurpose,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: application.status),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Large amount
                  Text(
                    Formatters.currency(application.loanAmount, countryCode),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Date
                  Text(
                    'Applied ${Formatters.date(application.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            // Eye icon button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.remove_red_eye_outlined,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildFilterTab('All', null),
        const SizedBox(width: 8),
        _buildFilterTab('Pending', LoanStatus.pending),
        const SizedBox(width: 8),
        _buildFilterTab('Approved', LoanStatus.approved),
        const SizedBox(width: 8),
        _buildFilterTab('Rejected', LoanStatus.rejected),
      ],
    );
  }

  Widget _buildFilterTab(String label, LoanStatus? status) {
    final isSelected = _selectedFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primaryShade2 : AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 1.5,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.white : AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No applications yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Apply for your first loan to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Apply for a Loan',
            onPressed: () => context.go(AppRoutes.apply),
            width: 180,
          ),
        ],
      ),
    );
  }
}
