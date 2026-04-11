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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: () => context.go(AppRoutes.apply),
          backgroundColor: AppColors.primaryDark,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        backgroundColor: AppColors.backgroundDark,
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
                                  AppColors.white),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),
                        // Stats row
                        // LayoutBuilder(
                        //   builder: (context, constraints) {
                        //     final isMobile = constraints.maxWidth < 600;
                        //     return GridView.count(
                        //       crossAxisSpacing:
                        //           16, // horizontal space between items
                        //       mainAxisSpacing: 16,
                        //       shrinkWrap: true,
                        //       physics: const NeverScrollableScrollPhysics(),
                        //       crossAxisCount: isMobile ? 2 : 1,
                        //       children: [
                        //         _buildStatCard('Approved', approved.toString(),
                        //             AppColors.primaryDark, AppColors.white),
                        //         _buildStatCard('Pending', pending.toString(),
                        //             AppColors.primaryDark, AppColors.white),

                        //         // _buildStatCard('Rejected', rejected.toString(),
                        //         //     AppColors.error, AppColors.errorLight),
                        //       ],
                        //     );
                        //   },
                        // ),

                        // const SizedBox(height: 50),

                        // Row(
                        //   children: [
                        //     CustomButton(
                        //       label: 'Calculator',
                        //       onPressed: () {
                        //         print('Calculator tapped');
                        //         context.push(AppRoutes.calculator);
                        //       },
                        //       isOutlined: true,
                        //       width: 130,
                        //     ),
                        //     const SizedBox(width: 12),
                        //     // CustomButton(
                        //     //   label: 'Apply ',
                        //     //   onPressed: () => context.go(AppRoutes.apply),
                        //     //   width: 120,
                        //     // ),
                        //   ],
                        // ),
                        const SizedBox(height: 30),
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
          // Logo
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset('assets/images/aemo-logo.png'),
              ),
              const SizedBox(width: 10),
              Text(userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      )),
            ],
          ),

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
              // const SizedBox(width: 16),
              // TextButton.icon(
              //   onPressed: _handleLogout,
              //   icon: const Icon(Icons.logout, size: 18),
              //   label: const Text('Logout'),
              //   style: TextButton.styleFrom(
              //     foregroundColor: AppColors.error,
              //   ),
              // ),
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
      elevation: 5,
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
          color: isSelected ? AppColors.primaryDark : Color(0xFFa7c8ff),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
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
