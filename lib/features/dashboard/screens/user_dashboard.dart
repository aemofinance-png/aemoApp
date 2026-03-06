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

class UserDashboard extends ConsumerStatefulWidget {
  const UserDashboard({super.key});

  @override
  ConsumerState<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ConsumerState<UserDashboard> {
  LoanStatus? _selectedFilter;

  // @override
  // void initState() {
  //   super.initState();
  //   // Wait for user to load then fetch applications
  //   Future.microtask(() async {
  //     // Keep checking until user is available
  //     ref.listenManual(currentUserProvider, (previous, next) {
  //       final user = next.value;
  //       if (user != null) {
  //         ref.read(loanNotifierProvider.notifier).fetchApplications();
  //       }
  //     }, fireImmediately: true);
  //   });
  // }

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
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Navbar
            _buildNavbar(currentUser?.fullName ?? ''),

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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here is a summary of your loan applications',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Stats row
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 600;
                            return GridView.count(
                              crossAxisSpacing:
                                  16, // horizontal space between items
                              mainAxisSpacing: 16,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: isMobile ? 2 : 4,
                              children: [
                                _buildStatCard('Total', total.toString(),
                                    AppColors.primary, AppColors.primaryLight),
                                _buildStatCard('Pending', pending.toString(),
                                    AppColors.pending, AppColors.pendingLight),
                                _buildStatCard('Approved', approved.toString(),
                                    AppColors.success, AppColors.successLight),
                                _buildStatCard('Rejected', rejected.toString(),
                                    AppColors.error, AppColors.errorLight),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 50),

                        // filtered.isEmpty
                        //     ? _buildEmptyState()
                        //     : Column(
                        //         children: filtered
                        //             .map((app) => _buildApplicationCard(
                        //                 app, currentUser?.countryCode ?? 'BZ'))
                        //             .toList(),
                        //       ),
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
                            Row(
                              children: [
                                CustomButton(
                                  label: 'Calculator',
                                  onPressed: () {
                                    print('Calculator tapped');
                                    context.push(AppRoutes.calculator);
                                  },
                                  isOutlined: true,
                                  width: 130,
                                ),
                                const SizedBox(width: 12),
                                CustomButton(
                                  label: 'Apply ',
                                  onPressed: () => context.go(AppRoutes.apply),
                                  width: 120,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),
                        _buildFilterTabs(),
                        const SizedBox(height: 26),
                        // Applications list
                        filtered.isEmpty
                            ? _buildEmptyState()
                            : Column(
                                children: filtered
                                    .map((app) => _buildApplicationCard(
                                        app, currentUser?.countryCode ?? 'BZ'))
                                    .toList(),
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
    );
  }

  // Navbar
  Widget _buildNavbar(String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.appName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // User info + logout
          Row(
            children: [
              // Add this temporarily to user_dashboard.dart
// inside the _buildNavbar method, next to the logout button

              Text(
                userName,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
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
    return Expanded(
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Application card
  Widget _buildApplicationCard(
      LoanApplicationModel application, String countryCode) {
    return GestureDetector(
      onTap: () => context.go('${AppRoutes.status}/${application.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),

            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.loanPurpose,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.currency(application.loanAmount, countryCode)} • ${Formatters.duration(application.loanDuration)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
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

            // Status badge + chevron
            Row(
              children: [
                StatusBadge(status: application.status),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
              ],
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
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
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
