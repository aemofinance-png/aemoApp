import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/withdrawal_model.dart';
import '../../../data/providers/service_providers.dart';
import '../../../app/router.dart';
import 'package:aemo_loan_app/features/admin/providers/admin_provider.dart';

class AdminWithdrawalsScreen extends ConsumerWidget {
  AdminWithdrawalsScreen({super.key});
  final adminWithdrawalsProvider =
      FutureProvider.autoDispose<List<WithdrawalModel>>((ref) async {
    return ref.read(firestoreServiceProvider).getAllWithdrawals();
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawalsAsync = ref.watch(adminWithdrawalsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D1B3E)),
          onPressed: () => context.go(AppRoutes.admin),
        ),
        title: const Text(
          'Withdrawals',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D1B3E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0D1B3E)),
            onPressed: () => ref.invalidate(adminWithdrawalsProvider),
          ),
        ],
      ),
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

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminWithdrawalsProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats row ─────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'TOTAL',
                          withdrawals.length.toString(),
                          const Color(0xFF0D1B3E),
                          const Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'PENDING',
                          pending.toString(),
                          const Color(0xFFCA8A04),
                          const Color(0xFFFEF9C3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'PROCESSING',
                          processing.toString(),
                          const Color(0xFF4F46E5),
                          const Color(0xFFEEF2FF),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'ALL WITHDRAWALS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (withdrawals.isEmpty)
                    _buildEmptyState()
                  else
                    ...withdrawals
                        .map((w) => _buildWithdrawalCard(context, ref, w)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: textColor.withOpacity(0.6),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalCard(
      BuildContext context, WidgetRef ref, WithdrawalModel w) {
    final last4 = w.accountNumber.length >= 4
        ? w.accountNumber.substring(w.accountNumber.length - 4)
        : w.accountNumber;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _statusAccentColor(w.status),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DESTINATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${w.bankName} ...$last4',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B3E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        w.userName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'AMOUNT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${w.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1B3E),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 0.5, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 14),

            // Bottom row: date + status + actions
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(
                  Formatters.date(w.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(w.status),
              ],
            ),

            // Action buttons for pending/processing
            if (w.status == WithdrawalStatus.pending ||
                w.status == WithdrawalStatus.processing) ...[
              const SizedBox(height: 14),
              const Divider(height: 0.5, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (w.status == WithdrawalStatus.pending)
                    Expanded(
                      child: _buildActionButton(
                        label: 'Mark Processing',
                        color: const Color(0xFF4F46E5),
                        bgColor: const Color(0xFFEEF2FF),
                        onTap: () async {
                          await ref
                              .read(firestoreServiceProvider)
                              .updateWithdrawalStatus(
                                w.id,
                                WithdrawalStatus.processing,
                              );
                          ref.invalidate(adminWithdrawalsProvider);
                        },
                      ),
                    ),
                  if (w.status == WithdrawalStatus.pending)
                    const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Mark Complete',
                      color: const Color(0xFF16A34A),
                      bgColor: const Color(0xFFDCFCE7),
                      onTap: () async {
                        await ref
                            .read(firestoreServiceProvider)
                            .updateWithdrawalStatus(
                              w.id,
                              WithdrawalStatus.completed,
                            );
                        ref.invalidate(adminWithdrawalsProvider);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Reject',
                      color: const Color(0xFFDC2626),
                      bgColor: const Color(0xFFFEE2E2),
                      onTap: () async {
                        await ref
                            .read(firestoreServiceProvider)
                            .updateWithdrawalStatus(
                              w.id,
                              WithdrawalStatus.failed,
                            );
                        ref.invalidate(adminWithdrawalsProvider);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(WithdrawalStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case WithdrawalStatus.pending:
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFFCA8A04);
        label = 'PENDING';
        break;
      case WithdrawalStatus.processing:
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF4F46E5);
        label = 'PROCESSING';
        break;
      case WithdrawalStatus.completed:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        label = 'COMPLETED';
        break;
      case WithdrawalStatus.failed:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'FAILED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _statusAccentColor(WithdrawalStatus status) {
    switch (status) {
      case WithdrawalStatus.pending:
        return const Color(0xFFCA8A04);
      case WithdrawalStatus.processing:
        return const Color(0xFF4F46E5);
      case WithdrawalStatus.completed:
        return const Color(0xFF16A34A);
      case WithdrawalStatus.failed:
        return const Color(0xFFDC2626);
    }
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
              'No withdrawals yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1B3E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Withdrawal requests will appear here',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
