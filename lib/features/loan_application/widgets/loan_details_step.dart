import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/core/constants/app_strings.dart';
import 'package:aemo_loan_app/core/utils/formatters.dart';
import 'package:aemo_loan_app/shared/widgets/custom_text_field.dart';
import '../providers/loan_form_provider.dart';

class LoanDetailsStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final String countryCode;

  const LoanDetailsStep({
    super.key,
    required this.formKey,
    required this.countryCode,
  });

  @override
  ConsumerState<LoanDetailsStep> createState() => _LoanDetailsStepState();
}

class _LoanDetailsStepState extends ConsumerState<LoanDetailsStep> {
  late TextEditingController _loanAmountController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(loanFormProvider);
    _loanAmountController = TextEditingController(
      text: state.loanAmount > 0 ? state.loanAmount.toString() : '',
    );
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loanState = ref.watch(loanFormProvider);
    final notifier = ref.read(loanFormProvider.notifier);
    final currencyCode = Formatters.getCurrencyCode(widget.countryCode);
    
    // Determine available rates based on amount
    final availableRates = Map.fromEntries(
      AppStrings.loanRates.entries.where((entry) {
        final minimum = AppStrings.loanMinimums[entry.key] ?? 0;
        return loanState.loanAmount >= minimum;
      }),
    );

    final interestRate = AppStrings.loanRates[loanState.loanDuration] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Loan Details',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _buildStepDots(2),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Customize your loan to fit your needs and budget.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'HOW MUCH DO YOU NEED? ($currencyCode)',
                  controller: _loanAmountController,
                  hint: '0.00',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) {
                    final amount = double.tryParse(v) ?? 0.0;
                    notifier.updateLoanAmount(amount);
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Amount is required';
                    final amount = double.tryParse(v);
                    if (amount == null || amount <= 0) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('LOAN PURPOSE'),
                const SizedBox(height: 8),
                _buildDropdown<String>(
                  value: loanState.loanPurpose,
                  hint: 'Select purpose',
                  items: AppStrings.loanPurposes,
                  onChanged: (v) => notifier.updateLoanPurpose(v!),
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('REPAYMENT DURATION'),
                const SizedBox(height: 8),
                _buildDropdown<int>(
                  value: loanState.loanDuration,
                  hint: 'Select duration',
                  items: availableRates.keys.toList(),
                  itemLabelBuilder: (item) => '$item Months',
                  onChanged: (v) => notifier.updateLoanDuration(v!),
                ),
                const SizedBox(height: 32),
                if (loanState.monthlyPayment != null) _buildSummaryCard(loanState, interestRate),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(LoanFormState state, double interestRate) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Monthly Payment',
            Formatters.currency(state.monthlyPayment!, widget.countryCode),
            isHighlighted: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _buildSummaryRow(
            'Interest Rate',
            '$interestRate% / year',
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Total Repayment',
            Formatters.currency(state.totalPayment!, widget.countryCode),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlighted ? 14 : 13,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            color: isHighlighted ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 18 : 14,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required void Function(T?) onChanged,
    String Function(T)? itemLabelBuilder,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      hint: Text(hint),
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabelBuilder?.call(item) ?? item.toString()),
        );
      }).toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildStepDots(int activeIndex) {
    return Row(
      children: List.generate(
        4,
        (i) => Container(
          width: i == activeIndex ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: i == activeIndex ? AppColors.primaryDark : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
