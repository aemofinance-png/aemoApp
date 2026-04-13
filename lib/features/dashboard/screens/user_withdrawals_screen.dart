import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/withdrawal_model.dart';
import '../../../data/providers/service_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../app/router.dart';

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
        _listAnimationController.reset(); // Reset to start
        _listAnimationController.forward(); // Play
      }
    });
    // ref is available globally within the State class
    final withdrawalsAsync = ref.watch(userWithdrawalsProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';

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
          'Withdrawals',
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
      body: withdrawalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (withdrawals) {
          final processing = withdrawals
              .where((w) => w.status == WithdrawalStatus.processing)
              .length;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userWithdrawalsProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MONTHLY ACTIVITY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Transfer Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D1B3E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (processing > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFF0D1B3E), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '$processing PROCESSING WITHDRAWAL${processing > 1 ? 'S' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0D1B3E),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (withdrawals.isEmpty)
                    _buildEmptyState()
                  else
                    ...withdrawals.asMap().entries.map((w) {
                      final index = w.key;
                      final app = w.value;

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
                        child: _buildWithdrawalCard(context, app, countryCode),
                      );
                    }).toList(),

                  // ...withdrawals.map(
                  //     (w) => _buildWithdrawalCard(context, w, countryCode)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWithdrawalCard(
      BuildContext context, WithdrawalModel w, String countryCode) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 48,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B3E),
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
                      Formatters.currency(w.amount, countryCode),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1B3E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 0.5, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Text(
                      Formatters.date(w.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(w.status),
              ],
            ),
          ],
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
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        label = 'PENDING';
        break;
      case WithdrawalStatus.processing:
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF4F46E5);
        label = 'PROCESSING';
        break;
      case WithdrawalStatus.completed:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        label = 'COMPLETED';
        break;
      case WithdrawalStatus.failed:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'FAILED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
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
        return const Color(0xFF94A3B8);
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
              'Your withdrawal history will appear here',
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
