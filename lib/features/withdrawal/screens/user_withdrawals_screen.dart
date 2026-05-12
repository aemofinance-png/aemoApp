import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/core/utils/formatters.dart';
import 'package:aemo_loan_app/data/models/withdrawal_model.dart';
import 'package:aemo_loan_app/data/providers/service_providers.dart';
import 'package:aemo_loan_app/features/auth/providers/auth_provider.dart';
import 'package:aemo_loan_app/app/router.dart';
import 'package:aemo_loan_app/shared/widgets/skeleton.dart';

final userWithdrawalsProvider =
    FutureProvider.autoDispose<List<WithdrawalModel>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  return ref.read(firestoreServiceProvider).getUserWithdrawals(user.id);
});

class WithdrawalsScreen extends ConsumerStatefulWidget {
  const WithdrawalsScreen({super.key});

  @override
  ConsumerState<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends ConsumerState<WithdrawalsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _listAnimationController;
  WithdrawalStatus? _selectedFilter;

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
    ref.listen(userWithdrawalsProvider, (previous, next) {
      if (next is AsyncData && next.value!.isNotEmpty) {
        _listAnimationController.reset();
        _listAnimationController.forward();
      }
    });

    final withdrawalsAsync = ref.watch(userWithdrawalsProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        title: Text(
          'Withdrawals',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => ref.invalidate(userWithdrawalsProvider),
          ),
        ],
      ),
      body: withdrawalsAsync.when(
        loading: () => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: const WithdrawalListSkeleton(),
            ),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (withdrawals) {
          final filtered = _selectedFilter == null
              ? withdrawals
              : withdrawals.where((w) => w.status == _selectedFilter).toList();

          final totalAmount = withdrawals
              .where((w) => w.status == WithdrawalStatus.completed)
              .fold(0.0, (sum, w) => sum + w.amount);

          final processingCount = withdrawals
              .where((w) => w.status == WithdrawalStatus.processing)
              .length;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userWithdrawalsProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildStatsRow(totalAmount, processingCount, countryCode),
                      const SizedBox(height: 40),
                      _buildFilters(),
                      const SizedBox(height: 24),
                      if (filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final w = filtered[index];

                            final start = (index * 0.1).clamp(0.0, 1.0);
                            final end = (start + 0.6).clamp(0.0, 1.0);

                            final slideAnimation = Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _listAnimationController,
                              curve: Interval(
                                start,
                                end,
                                curve: Curves.easeOutCubic,
                              ),
                            ));

                            return SlideTransition(
                              position: slideAnimation,
                              child:
                                  _buildWithdrawalCard(context, w, countryCode),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transfer Portfolio',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Review your transfer history and withdrawal status.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
      double totalAmount, int processingCount, String countryCode) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Withdrawn',
            value: Formatters.currency(totalAmount, countryCode),
            icon: Icons.account_balance_wallet_rounded,
            bgColor: AppColors.primaryDark,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Processing',
            value: processingCount.toString().padLeft(2, '0'),
            icon: Icons.sync_rounded,
            bgColor: AppColors.primaryLightShade2,
            textColor: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FILTER BY STATUS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterTab(
                label: 'All',
                isSelected: _selectedFilter == null,
                onTap: () => setState(() => _selectedFilter = null),
              ),
              const SizedBox(width: 8),
              _FilterTab(
                label: 'Processing',
                isSelected: _selectedFilter == WithdrawalStatus.processing,
                onTap: () => setState(
                    () => _selectedFilter = WithdrawalStatus.processing),
              ),
              const SizedBox(width: 8),
              _FilterTab(
                label: 'Completed',
                isSelected: _selectedFilter == WithdrawalStatus.completed,
                onTap: () => setState(
                    () => _selectedFilter = WithdrawalStatus.completed),
              ),
              const SizedBox(width: 8),
              _FilterTab(
                label: 'Failed',
                isSelected: _selectedFilter == WithdrawalStatus.failed,
                onTap: () =>
                    setState(() => _selectedFilter = WithdrawalStatus.failed),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalCard(
      BuildContext context, WithdrawalModel w, String countryCode) {
    final last4 = w.accountNumber.length >= 4
        ? w.accountNumber.substring(w.accountNumber.length - 4)
        : w.accountNumber;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: _getStatusColor(w.status),
            width: 5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.bankName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Ending in •••• $last4',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.date(w.createdAt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(w.amount, countryCode),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              _buildStatusBadge(w.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(WithdrawalStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case WithdrawalStatus.pending:
        bg = AppColors.pendingLight;
        fg = AppColors.pending;
        label = 'PENDING';
        break;
      case WithdrawalStatus.processing:
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF4F46E5);
        label = 'PROCESSING';
        break;
      case WithdrawalStatus.completed:
        bg = AppColors.successLight;
        fg = AppColors.success;
        label = 'COMPLETED';
        break;
      case WithdrawalStatus.failed:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        label = 'FAILED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(WithdrawalStatus status) {
    switch (status) {
      case WithdrawalStatus.pending:
        return AppColors.pending;
      case WithdrawalStatus.processing:
        return const Color(0xFF4F46E5);
      case WithdrawalStatus.completed:
        return AppColors.success;
      case WithdrawalStatus.failed:
        return AppColors.error;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
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
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No withdrawals yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your withdrawal history will appear here',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
              Icon(icon, color: textColor.withValues(alpha: 0.7), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
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

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
          border: isSelected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
