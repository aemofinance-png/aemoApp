import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
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
  final _amountController = TextEditingController();
  int _selectedDuration = AppStrings.loanRates.keys.first;

  double? _monthlyPayment;
  double? _totalPayment;
  double? _totalInterest;

  double get _interestRate => AppStrings.loanRates[_selectedDuration] ?? 0.0;

  @override
  void initState() {
    super.initState();
    // Calculate automatically as user types
    _amountController.addListener(_calculate);
  }

  @override
  void dispose() {
    _amountController.removeListener(_calculate);
    _amountController.dispose();
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

  void _calculate() {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      if (_monthlyPayment != null) {
        setState(() {
          _monthlyPayment = null;
          _totalPayment = null;
          _totalInterest = null;
        });
      }
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

  Future<void> _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1024) {
          return _MobileCalculator(
            amountController: _amountController,
            selectedDuration: _selectedDuration,
            interestRate: _interestRate,
            availableRates: _availableRates,
            monthlyPayment: _monthlyPayment,
            totalPayment: _totalPayment,
            totalInterest: _totalInterest,
            onDurationChanged: (val) {
              setState(() => _selectedDuration = val);
              _calculate(); // Recalculate on duration change
            },
            onAmountChanged: _calculate,
            onCalculate: _calculate,
            currentUser: currentUser,
            onLogout: _handleLogout,
          );
        }
        return _DesktopCalculator(
          amountController: _amountController,
          selectedDuration: _selectedDuration,
          interestRate: _interestRate,
          availableRates: _availableRates,
          monthlyPayment: _monthlyPayment,
          totalPayment: _totalPayment,
          totalInterest: _totalInterest,
          onDurationChanged: (val) {
            setState(() => _selectedDuration = val);
            _calculate(); // Recalculate on duration change
          },
          onAmountChanged: _calculate,
          onCalculate: _calculate,
          currentUser: currentUser,
          onLogout: _handleLogout,
        );
      },
    );
  }
}

class _DesktopCalculator extends StatelessWidget {
  final TextEditingController amountController;
  final int selectedDuration;
  final double interestRate;
  final Map<int, double> availableRates;
  final double? monthlyPayment;
  final double? totalPayment;
  final double? totalInterest;
  final Function(int) onDurationChanged;
  final VoidCallback onAmountChanged;
  final VoidCallback onCalculate;
  final UserModel? currentUser;
  final VoidCallback onLogout;

  const _DesktopCalculator({
    required this.amountController,
    required this.selectedDuration,
    required this.interestRate,
    required this.availableRates,
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
    required this.onDurationChanged,
    required this.onAmountChanged,
    required this.onCalculate,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      drawer: _buildSharedDrawer(context, currentUser, onLogout),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildTopNavBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Loan Projection',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Simulate architectural lending scenarios with high-precision instruments.\nDefine your parameters to visualize capital commitments.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: _buildParameterCard(context),
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  flex: 6,
                                  child: _buildResultPanel(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 48),
                            _buildBottomGrid(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINANCIAL PARAMETERS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildInputLabel('PRINCIPAL AMOUNT'),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Loan Amount',
            controller: amountController,
            hint: 'e.g. 250000',
            prefixIcon: const Icon(Icons.attach_money_rounded,
                color: AppColors.primary),
            keyboardType: TextInputType.number,
            onChanged: (v) => onAmountChanged(),
          ),
          const SizedBox(height: 24),
          _buildInputLabel('AMORTIZATION PERIOD'),
          const SizedBox(height: 12),
          _buildDurationDropdown(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('INTEREST RATE'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            interestRate.toStringAsFixed(2),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '%',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('START DATE'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            Formatters.date(DateTime.now()),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_today_rounded,
                              size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.apply),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Application',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildResultPanel(BuildContext context) {
    if (monthlyPayment == null) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calculate_outlined,
                  size: 64, color: AppColors.primary.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text(
                'Enter an amount to see your projection',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final countryCode = currentUser?.countryCode ?? 'BZ';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'MONTHLY COMMITMENT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.currency(monthlyPayment!, countryCode),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 80,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                        letterSpacing: -4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your estimated monthly repayment based on current interest rates.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                const Divider(color: Colors.white12),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildResultMetric('TOTAL INTEREST',
                        Formatters.currency(totalInterest!, countryCode)),
                    _buildResultMetric('TOTAL PAYMENT',
                        Formatters.currency(totalPayment!, countryCode)),
                    _buildResultMetric(
                        'PAYOFF DATE',
                        Formatters.date(DateTime.now()
                            .add(Duration(days: selectedDuration * 30)))),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      NetworkImage('https://i.pravatar.cc/100?u=aemo1'),
                ),
                const SizedBox(width: 8),
                Text(
                  'Verified Specialists Available',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Lock in this rate',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildResultMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDurationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: availableRates.containsKey(selectedDuration)
              ? selectedDuration
              : availableRates.keys.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 16,
          ),
          items: availableRates.keys.map((months) {
            return DropdownMenuItem<int>(
              value: months,
              child: Text(
                '${Formatters.duration(months)} — ${AppStrings.loanRates[months]}% p.a.',
              ),
            );
          }).toList(),
          onChanged: (value) => onDurationChanged(value!),
        ),
      ),
    );
  }

  Widget _buildBottomGrid(BuildContext context) {
    return Row(
      children: [
        _buildInfoCard(
          'Market Benchmark',
          '3.85% APY',
          'Avg. rate for credit score 780+',
          Icons.show_chart_rounded,
        ),
        const SizedBox(width: 24),
        _buildInfoCard(
          'Capital Composition',
          'Principal accounts for 74%',
          'of your total loan lifecycle commitment.',
          Icons.pie_chart_outline_rounded,
        ),
        const SizedBox(width: 24),
        _buildInfoCard(
          'Accelerated Path',
          'Pay an extra \$200/mo',
          'to save \$24,102 in interest and finish early.',
          Icons.bolt_rounded,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String val, String sub, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
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
                  'Loan Portal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'ENTERPRISE LEDGER',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary.withOpacity(0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            onTap: () => context.go(AppRoutes.dashboard),
          ),
          _SidebarItem(
            icon: Icons.description_outlined,
            label: 'Apply for Loan',
            onTap: () => context.go(AppRoutes.apply),
          ),
          _SidebarItem(
            icon: Icons.calculate_rounded,
            label: 'Calculator',
            isActive: true,
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.person_outlined,
            label: 'Profile',
            onTap: () => context.go(AppRoutes.profile),
          ),
          const Spacer(),
          const Divider(),
          _SidebarItem(
            icon: Icons.logout,
            label: 'Log Out',
            color: AppColors.error,
            onTap: onLogout,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: currentUser?.selfieUrl != null &&
                    currentUser!.selfieUrl!.isNotEmpty
                ? NetworkImage(currentUser!.selfieUrl!)
                : null,
            child: currentUser?.selfieUrl == null ||
                    currentUser!.selfieUrl!.isEmpty
                ? Center(
                    child: Text(
                      currentUser?.fullName.isNotEmpty ?? false
                          ? currentUser!.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _MobileCalculator extends StatelessWidget {
  final TextEditingController amountController;
  final int selectedDuration;
  final double interestRate;
  final Map<int, double> availableRates;
  final double? monthlyPayment;
  final double? totalPayment;
  final double? totalInterest;
  final Function(int) onDurationChanged;
  final VoidCallback onAmountChanged;
  final VoidCallback onCalculate;
  final UserModel? currentUser;
  final VoidCallback onLogout;

  const _MobileCalculator({
    required this.amountController,
    required this.selectedDuration,
    required this.interestRate,
    required this.availableRates,
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
    required this.onDurationChanged,
    required this.onAmountChanged,
    required this.onCalculate,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final countryCode = currentUser?.countryCode ?? 'BZ';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        title: Text(
          'Loan Calculator',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMobileResultCard(context, countryCode),
                    const SizedBox(height: 40),
                    _buildMobileInputSection(context),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.apply),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Proceed to Application',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
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
    );
  }

  Widget _buildMobileResultCard(BuildContext context, String countryCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONTHLY REPAYMENT',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   Formatters.getCurrencySymbol(countryCode),
              //   style: GoogleFonts.plusJakartaSans(
              //     fontSize: 24,
              //     fontWeight: FontWeight.w400,
              //     color: Colors.white,
              //   ),
              // ),
              Text(
                monthlyPayment != null
                    ? Formatters.currency(monthlyPayment!, countryCode)
                    // .replaceAll(RegExp(r'[^\d,]'), '')
                    // .split('.')[0]
                    : '0',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 8, left: 4),
              //   child: Text(
              //     '.${monthlyPayment != null ? Formatters.currency(monthlyPayment!, countryCode).split('.')[1] : '00'}',
              //     style: GoogleFonts.plusJakartaSans(
              //       fontSize: 18,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.white.withOpacity(0.5),
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL INTEREST',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalInterest != null
                          ? Formatters.currency(totalInterest!, countryCode)
                          : Formatters.currency(0, countryCode),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PAYBACK',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalPayment != null
                          ? Formatters.currency(totalPayment!, countryCode)
                          : Formatters.currency(0, countryCode),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOAN AMOUNT',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: "Amount",
          controller: amountController,
          hint: 'e.g. 50000',
          prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          keyboardType: TextInputType.number,
          onChanged: (v) => onAmountChanged(),
        ),
        const SizedBox(height: 32),
        Text(
          'DURATION',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildDurationDropdown(),
        const SizedBox(height: 32),
        Text(
          'INTEREST RATE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.percent_rounded,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(
                interestRate.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: availableRates.containsKey(selectedDuration)
              ? selectedDuration
              : availableRates.keys.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: availableRates.keys.map((months) {
            return DropdownMenuItem<int>(
              value: months,
              child: Text(
                '${Formatters.duration(months)} — ${AppStrings.loanRates[months]}%',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) => onDurationChanged(value!),
        ),
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

  const _SidebarItem(
      {required this.icon,
      required this.label,
      this.isActive = false,
      required this.onTap,
      this.color});

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
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? AppColors.primary
                    : (color ?? AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive
                      ? AppColors.primary
                      : (color ?? AppColors.textSecondary),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSharedDrawer(
    BuildContext context, UserModel? user, VoidCallback onLogout) {
  return Drawer(
    child: SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: AppColors.primaryDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage:
                      user?.selfieUrl != null && user!.selfieUrl!.isNotEmpty
                          ? NetworkImage(user.selfieUrl!)
                          : null,
                  child: user?.selfieUrl == null || user!.selfieUrl!.isEmpty
                      ? Text(
                          user?.fullName.isNotEmpty ?? false
                              ? user!.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary))
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user?.fullName ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text(user?.email ?? '',
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () => context.go(AppRoutes.dashboard),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Apply for Loan'),
            onTap: () => context.go(AppRoutes.apply),
          ),
          ListTile(
            leading: const Icon(Icons.summarize_outlined),
            title: const Text('Applications'),
            onTap: () => context.go(AppRoutes.userApplications),
          ),
          ListTile(
            leading:
                const Icon(Icons.calculate_outlined, color: AppColors.primary),
            title: const Text('Calculator',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Withdrawals'),
            onTap: () => context.go(AppRoutes.withdrawals),
          ),
          ListTile(
            leading: const Icon(Icons.person_outlined),
            title: const Text('Profile'),
            onTap: () => context.go(AppRoutes.profile),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title:
                const Text('Log Out', style: TextStyle(color: AppColors.error)),
            onTap: onLogout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
