import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/withdrawal_model.dart';
import '../../../data/providers/service_providers.dart';
import '../../../app/router.dart';
import '../../auth/providers/auth_provider.dart';

class AdminWithdrawalsScreen extends ConsumerStatefulWidget {
  const AdminWithdrawalsScreen({super.key});

  @override
  ConsumerState<AdminWithdrawalsScreen> createState() =>
      _AdminWithdrawalsScreenState();
}

class _AdminWithdrawalsScreenState
    extends ConsumerState<AdminWithdrawalsScreen> {
  final adminWithdrawalsProvider =
      FutureProvider.autoDispose<List<WithdrawalModel>>((ref) async {
    return ref.read(firestoreServiceProvider).getAllWithdrawals();
  });

  Future<void> _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalsAsync = ref.watch(adminWithdrawalsProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: withdrawalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (withdrawals) {
          final pending = withdrawals
              .where((w) => w.status == WithdrawalStatus.pending)
              .length;
          final processing = withdrawals
              .where((w) => w.status == WithdrawalStatus.processing)
              .length;
          final totalVolume =
              withdrawals.fold<double>(0, (sum, item) => sum + item.amount);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1024;

              return Row(
                children: [
                  if (isDesktop) _buildSidebar(context),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTopAppBar(context, !isDesktop,
                            currentUser?.fullName ?? 'Admin'),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async =>
                                ref.invalidate(adminWithdrawalsProvider),
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              children: [
                                // Header Section
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: isDesktop ? 1000 : 500),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: _buildHeaderSection(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Summary Cards
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: isDesktop ? 1000 : 500),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: _buildSummarySection(totalVolume,
                                          pending, processing, isDesktop),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 48),
                                // Transaction List
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: isDesktop ? 1000 : 500),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildListHeader(),
                                          const SizedBox(height: 24),
                                          if (withdrawals.isEmpty)
                                            _buildEmptyState()
                                          else
                                            ...withdrawals
                                                .asMap()
                                                .entries
                                                .map((entry) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 16),
                                                      child:
                                                          _buildWithdrawalCard(
                                                              context,
                                                              entry.value,
                                                              entry.key),
                                                    )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
                  'Aemo Finance',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Withdrawal Management',
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
            onTap: () => context.go(AppRoutes.admin),
          ),
          _SidebarItem(
            icon: Icons.payments_outlined,
            label: 'Withdrawals',
            isActive: true,
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.group_outlined,
            label: 'Users',
            onTap: () => context.go(AppRoutes.adminUsers),
          ),
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

  Widget _buildTopAppBar(BuildContext context, bool showLogo, String name) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showLogo) ...[
            IconButton(
              onPressed: () => context.go(AppRoutes.admin),
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF001E40)),
            ),
            const SizedBox(width: 8),
            Text(
              'Withdrawals',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF001E40),
                letterSpacing: -0.5,
              ),
            ),
          ] else ...[
            Text(
              'Architect Ledger',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF001E40),
                letterSpacing: -0.5,
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF001E40), size: 20),
            onPressed: () => ref.invalidate(adminWithdrawalsProvider),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBUmfAuZIfZTpsWDpOf6631nQzI2H5EdMTF8EXGzbhHNbwDSkpL0WIG1A9jCRr7um99F42GdX1AM5tStvCj8oD6AqwkUfJI4Z0ZmM8dCNO7zaOURKd8dnKTsxImB0Mh_QEi8RY0D-JdsfzABo1yPBt7Sdql46H1RiMfeOl5tdLbEazRgs6BehoRgutuen3uLke9ZB80nZwRDelgUDLdQSC8rZ8UYTjM2kEe_Gi4I8uXb7xgV_vOhUS4ceLKEtgKKwk00LXp4h6zmYMn'),
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
          'Withdrawals',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF001E40),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSummarySection(
      double volume, int pending, int processing, bool isDesktop) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 3 : 1,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      childAspectRatio: isDesktop ? 1.8 : 2.5,
      children: [
        _buildMetricCard('Total Withdrawals',
            '\$${(volume / 1000000).toStringAsFixed(1)}M', null),
        _buildMetricCard('Pending Approval', pending.toString(),
            Icons.hourglass_empty_rounded),
        _buildMetricCard(
            'In Processing', processing.toString(), Icons.sync_rounded),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData? icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFFC3C6D1).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 8)),
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
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF737780),
                  letterSpacing: 1.5,
                ),
              ),
              if (icon != null)
                Icon(icon,
                    size: 18,
                    color: const Color(0xFF737780).withValues(alpha: 0.5)),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF001E40),
              letterSpacing: -0.5,
            ),
          ),
          if (icon == null) ...[
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.7,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF001E40),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().scale(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'RECENT WITHDRAWALS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF737780),
            letterSpacing: 1.5,
          ),
        ),
        Row(
          children: [
            _buildSmallActionBtn('Filter', Icons.filter_list_rounded),
            const SizedBox(width: 12),
            _buildSmallActionBtn('Export', Icons.download_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallActionBtn(String label, IconData icon) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF737780)),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF737780),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalCard(
      BuildContext context, WithdrawalModel w, int index) {
    Color statusBg;
    Color statusText;
    String statusLabel;

    switch (w.status) {
      case WithdrawalStatus.pending:
        statusBg = const Color(0xFFFFDBCA).withValues(alpha: 0.3);
        statusText = const Color(0xFFD8885C);
        statusLabel = 'Pending';
        break;
      case WithdrawalStatus.processing:
        statusBg = const Color(0xFFD5E3FF).withValues(alpha: 0.3);
        statusText = const Color(0xFF1F477B);
        statusLabel = 'Processing';
        break;
      case WithdrawalStatus.completed:
        statusBg = const Color(0xFFDCFCE7).withValues(alpha: 0.3);
        statusText = const Color(0xFF16A34A);
        statusLabel = 'Complete';
        break;
      case WithdrawalStatus.failed:
        statusBg = const Color(0xFFFFDAD6).withValues(alpha: 0.3);
        statusText = const Color(0xFFBA1A1A);
        statusLabel = 'Failed';
        break;
    }

    final last4 = w.accountNumber.length >= 4
        ? w.accountNumber.substring(w.accountNumber.length - 4)
        : w.accountNumber;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: Color(0xFF001E40), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${w.bankName} ...$last4',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF001E40)),
                    ),
                    Text(
                      w.userName,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF737780),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(w.amount, w.countryCode),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF001E40),
                        letterSpacing: -0.5),
                  ),
                  Text(
                    w.countryCode.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF737780),
                        letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: Color(0xFF737780)),
              const SizedBox(width: 8),
              Text(
                Formatters.date(w.createdAt),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF737780),
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: statusText.withValues(alpha: 0.1)),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: statusText,
                      letterSpacing: 1),
                ),
              ),
            ],
          ),
          if (w.status == WithdrawalStatus.pending ||
              w.status == WithdrawalStatus.processing) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                if (w.status == WithdrawalStatus.pending)
                  Expanded(
                    child: _buildActionBtn(
                        'Process',
                        const Color(0xFF1F477B),
                        const Color(0xFFD5E3FF),
                        () => _updateStatus(w.id, WithdrawalStatus.processing)),
                  ),
                if (w.status == WithdrawalStatus.pending)
                  const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                      'Complete',
                      const Color(0xFF16A34A),
                      const Color(0xFFDCFCE7),
                      () => _updateStatus(w.id, WithdrawalStatus.completed)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                      'Reject',
                      const Color(0xFFBA1A1A),
                      const Color(0xFFFFDAD6),
                      () => _updateStatus(w.id, WithdrawalStatus.failed)),
                ),
              ],
            ),
          ],
        ],
      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0),
    );
  }

  Widget _buildActionBtn(String label, Color fg, Color bg, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: fg,
                letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(String id, WithdrawalStatus status) async {
    await ref.read(firestoreServiceProvider).updateWithdrawalStatus(id, status);
    ref.invalidate(adminWithdrawalsProvider);
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
          Icon(Icons.outbox_rounded,
              color: const Color(0xFF001E40).withValues(alpha: 0.1), size: 64),
          const SizedBox(height: 24),
          Text(
            'No withdrawals yet',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF001E40)),
          ),
          const SizedBox(height: 8),
          Text(
            'Requests will appear here once submitted',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF737780),
                fontWeight: FontWeight.w500),
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
