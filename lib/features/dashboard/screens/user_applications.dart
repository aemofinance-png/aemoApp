import 'package:aemo_loan_app/data/models/loan_application_model.dart';
import 'package:aemo_loan_app/features/loan_application/providers/loan_provider.dart';
import 'package:aemo_loan_app/shared/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '/../../data/models/withdrawal_model.dart';
import '../../../data/providers/service_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../app/router.dart';

final userWithdrawalsProvider =
    FutureProvider.autoDispose<List<WithdrawalModel>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  return ref.read(firestoreServiceProvider).getUserWithdrawals(user.id);
});

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

    return Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F6F9),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0D1B3E)),
            onPressed: () => context.go(AppRoutes.dashboard),
          ),
          title: const Text(
            'Applications',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B3E),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF0D1B3E)),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                filtered.isEmpty
                    ? _buildEmptyState()
                    : Column(children: [
                        _buildFilterTabs(),
                        const SizedBox(height: 16),
                        ...filtered.asMap().entries.map((entry) {
                          final index = entry.key;
                          final app = entry.value;

                          final slideAnimation = Tween<Offset>(
                            begin: const Offset(1, 0), // starts from the right
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
              ],
            ),
          ),
        ));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF0D1B3E),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Applications yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1B3E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your application history will appear here',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
