import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/withdrawal_provider.dart';
import '../../../core/utils/formatters.dart';

class StepConfirmation extends ConsumerWidget {
  const StepConfirmation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(withdrawalProvider);
    final application = state.application;
    final account = state.selectedAccount;

    if (application == null || account == null) {
      return const Center(child: Text('Missing information'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Confirm Withdrawal',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B3E),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Review your withdrawal details and destination account carefully before confirming.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),

        // Summary Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL WITHDRAWAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.currency(
                          application.loanAmount, application.countryCode),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D1B3E),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildConfirmRow('Destination', account.bankName),
                    const SizedBox(height: 16),
                    _buildConfirmRow('Account Number',
                        '•••• ${account.accountNumber.length >= 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber}'),
                    const SizedBox(height: 16),
                    _buildConfirmRow('Reference',
                        '#${application.id.substring(0, 8).toUpperCase()}'),
                    const SizedBox(height: 16),
                    _buildConfirmRow('Processing Time', '2-5 Business Days'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFEDD5)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Color(0xFFC2410C), size: 18),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'By confirming, you agree to the terms of the withdrawal agreement and acknowledge that funds will be sent to the selected account.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC2410C),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D1B3E),
          ),
        ),
      ],
    );
  }
}
