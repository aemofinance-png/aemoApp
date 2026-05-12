import 'package:flutter_test/flutter_test.dart';
import 'package:aemo_loan_app/core/utils/loan_calculator.dart';

void main() {
  group('LoanCalculator Tests', () {
    test('calculateMonthlyPayment handles standard values correctly', () {
      // Example: $5,000 at 12% for 12 months
      // Expected: ~$444.24
      final monthly = LoanCalculator.calculateMonthlyPayment(
        loanAmount: 5000.0,
        annualInterestRate: 12.0,
        termMonths: 12,
      );
      expect(monthly, closeTo(444.24, 0.01));
    });

    test('calculateMonthlyPayment handles zero interest correctly', () {
      final monthly = LoanCalculator.calculateMonthlyPayment(
        loanAmount: 1200.0,
        annualInterestRate: 0.0,
        termMonths: 12,
      );
      expect(monthly, equals(100.0));
    });

    test('calculateMonthlyPayment returns 0 for zero loan amount', () {
      final monthly = LoanCalculator.calculateMonthlyPayment(
        loanAmount: 0.0,
        annualInterestRate: 10.0,
        termMonths: 12,
      );
      expect(monthly, equals(0.0));
    });

    test('calculateTotalRepayment returns correct sum', () {
      final total = LoanCalculator.calculateTotalRepayment(
        monthlyPayment: 100.0,
        termMonths: 12,
      );
      expect(total, equals(1200.0));
    });

    test('calculateTotalInterest returns correct difference', () {
      final interest = LoanCalculator.calculateTotalInterest(
        totalRepayment: 1200.0,
        loanAmount: 1000.0,
      );
      expect(interest, equals(200.0));
    });
  });
}
