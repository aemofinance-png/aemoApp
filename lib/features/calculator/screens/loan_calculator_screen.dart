import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../app/router.dart';
import 'dart:math';

class LoanCalculatorScreen extends ConsumerStatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  ConsumerState<LoanCalculatorScreen> createState() =>
      _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends ConsumerState<LoanCalculatorScreen> {
  // Controllers
  final _amountController = TextEditingController();
  // final _interestRateController = TextEditingController(text: '12');
  double get _interestRate => AppStrings.loanRates[_selectedDuration] ?? 0.0;

  // Selected duration
  int _selectedDuration = AppStrings.loanRates.keys.first;

  // Results
  double? _monthlyPayment;
  double? _totalPayment;
  double? _totalInterest;

  @override
  void dispose() {
    _amountController.dispose();
    // _interestRateController.dispose();
    super.dispose();
  }

  Map<int, double> get _availableRates {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    return Map.fromEntries(
      AppStrings.loanRates.entries.where((entry) {
        final minimum = AppStrings.loanMinimums[entry.key] ?? 0;
        return amount >= minimum;
      }),
    );
  }

  // Calculate repayment
  void _calculate() {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid loan amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final monthlyRate = _interestRate / 12 / 100;
    final months = _selectedDuration;

    final monthly = amount *
        (monthlyRate * pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);

    setState(() {
      _monthlyPayment = monthly.toDouble();
      _totalPayment = monthly * months;
      _totalInterest = (monthly * months) - amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'USD';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        title: const Text(
          'Loan Calculator',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Estimate your repayment',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter your loan details to see an estimate',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // Input card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Loan amount
                      CustomTextField(
                        label: 'Loan Amount ',
                        hint: 'Enter loan amount',
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.attach_money),
                        onChanged: (_) {
                          setState(() {
                            // Reset duration if it's no longer available
                            final available = _availableRates;
                            if (!available.containsKey(_selectedDuration)) {
                              _selectedDuration = available.keys.first;
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Interest rate
                      // CustomTextField(
                      //   label: 'Annual Interest Rate (%)',
                      //   hint: 'e.g. 12',
                      //   controller: _interestRateController,
                      //   keyboardType: TextInputType.number,
                      //   prefixIcon: const Icon(Icons.percent),
                      // ),

                      const SizedBox(height: 16),

                      // Duration dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Loan Duration',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value:
                                _availableRates.containsKey(_selectedDuration)
                                    ? _selectedDuration
                                    : _availableRates.keys.first,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                            ),
                            items: _availableRates.keys.map((months) {
                              return DropdownMenuItem<int>(
                                value: months,
                                child: Text(
                                  '${Formatters.duration(months)} — ${AppStrings.loanRates[months]}% p.a.',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedDuration = value!),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: AppColors.primary, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Interest rate: $_interestRate% per annum',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Calculate button
                      CustomButton(
                        label: 'Calculate',
                        onPressed: _calculate,
                      ),
                    ],
                  ),
                ),

                // Results section
                if (_monthlyPayment != null) ...[
                  const SizedBox(height: 24),

                  // Summary cards
                  Row(
                    children: [
                      _buildResultCard(
                        'Monthly Payment',
                        Formatters.currency(_monthlyPayment!, countryCode),
                        AppColors.primary,
                        AppColors.primaryLight,
                      ),
                      const SizedBox(width: 16),
                      _buildResultCard(
                        'Total Interest',
                        Formatters.currency(_totalInterest!, countryCode),
                        AppColors.warning,
                        AppColors.warningLight,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Total repayment card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Repayment',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          Formatters.currency(_totalPayment!, countryCode),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Repayment breakdown table
                  // Container(
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: AppColors.border),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const Text(
                  //         'Repayment Breakdown',
                  //         style: TextStyle(
                  //           fontSize: 15,
                  //           fontWeight: FontWeight.w600,
                  //           color: AppColors.textPrimary,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 16),

                  //       // Table header
                  //       _buildTableRow(
                  //         'Month',
                  //         'Payment',
                  //         'Principal',
                  //         'Interest',
                  //         'Balance',
                  //         isHeader: true,
                  //       ),

                  //       const Divider(),

                  //       // Table rows
                  //       ..._buildAmortizationTable(
                  //         double.parse(_amountController.text.trim()),
                  //         _interestRate,
                  //         _selectedDuration,
                  //         countryCode,
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 50),

                  // Apply now button
                  CustomButton(
                    label: 'Apply for this Loan',
                    onPressed: () => context.go(AppRoutes.apply),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Result card
  Widget _buildResultCard(
      String label, String value, Color color, Color bgColor) {
    return Expanded(
      child: Container(
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
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Table row
  Widget _buildTableRow(
    String month,
    String payment,
    String principal,
    String interest,
    String balance, {
    bool isHeader = false,
  }) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
      color: isHeader ? AppColors.textPrimary : AppColors.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(month, style: style)),
          Expanded(
              child: Text(payment, style: style, textAlign: TextAlign.right)),
          Expanded(
              child: Text(principal, style: style, textAlign: TextAlign.right)),
          Expanded(
              child: Text(interest, style: style, textAlign: TextAlign.right)),
          Expanded(
              child: Text(balance, style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // Build amortization table rows
  List<Widget> _buildAmortizationTable(
    double principal,
    double annualRate,
    int months,
    String countryCode,
  ) {
    final rows = <Widget>[];
    final monthly = _monthlyPayment!;
    final rate = annualRate / 12 / 100;
    var balance = principal;

    for (int i = 1; i <= months; i++) {
      final interestPayment = balance * rate;
      final principalPayment = monthly - interestPayment;
      balance = balance - principalPayment;

      rows.add(_buildTableRow(
        '$i',
        Formatters.currency(monthly, countryCode),
        Formatters.currency(principalPayment, countryCode),
        Formatters.currency(interestPayment, countryCode),
        Formatters.currency(balance < 0 ? 0 : balance, countryCode),
      ));

      // Only show first 12 rows to keep it clean
      if (i == 12 && months > 12) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '... ${months - 12} more months',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
        break;
      }
    }

    return rows;
  }
}
