import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  LoanStatus? _selectedFilter; // null = show all

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(adminNotifierProvider.notifier).fetchAllApplications());
  }

  Future<void> _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final applications = adminState.applications;

    // Apply filter
    final filtered = _selectedFilter == null
        ? applications
        : applications.where((a) => a.status == _selectedFilter).toList();

    // Stats
    final total = applications.length;
    final pending =
        applications.where((a) => a.status == LoanStatus.pending).length;
    final approved =
        applications.where((a) => a.status == LoanStatus.approved).length;
    final rejected =
        applications.where((a) => a.status == LoanStatus.rejected).length;

    return LoadingOverlay(
      isLoading: adminState.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Navbar
            _buildNavbar(currentUser?.fullName ?? 'Admin'),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const Text(
                          'Applications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Review and manage loan applications',
                          style: TextStyle(
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

                        const SizedBox(height: 32),

                        // Filter tabs
                        _buildFilterTabs(),

                        const SizedBox(height: 16),

                        // Applications list
                        filtered.isEmpty
                            ? _buildEmptyState()
                            : Column(
                                children: filtered
                                    .map((app) => _buildApplicationCard(app))
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
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
      child: GestureDetector(
        onTap: () {
          setState(() {
            // Click stat card to filter by that status
            if (label == 'Total') {
              _selectedFilter = null;
            } else if (label == 'Pending') {
              _selectedFilter = LoanStatus.pending;
            } else if (label == 'Approved') {
              _selectedFilter = LoanStatus.approved;
            } else if (label == 'Rejected') {
              _selectedFilter = LoanStatus.rejected;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedFilter == null && label == 'Total'
                  ? color
                  : _selectedFilter == LoanStatus.pending && label == 'Pending'
                      ? color
                      : _selectedFilter == LoanStatus.approved &&
                              label == 'Approved'
                          ? color
                          : _selectedFilter == LoanStatus.rejected &&
                                  label == 'Rejected'
                              ? color
                              : Colors.transparent,
              width: 2,
            ),
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
      ),
    );
  }

  // Filter tabs
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

  // Application card
  Widget _buildApplicationCard(LoanApplicationModel application) {
    return GestureDetector(
      onTap: () {
        ref.read(adminNotifierProvider.notifier).selectApplication(application);
        context.go('${AppRoutes.admin}/${application.id}');
      },
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
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  application.fullName.isNotEmpty
                      ? application.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.fullName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${application.loanPurpose} • ${Formatters.currency(application.loanAmount, application.countryCode)}',
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

            // Status + chevron
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
            'No applications found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Applications will appear here once submitted',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
