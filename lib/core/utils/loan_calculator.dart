import 'dart:math';

class LoanCalculator {
  /// Calculates the monthly payment for a loan using the standard mortgage formula.
  /// 
  /// Formula: P [ i(1 + i)^n ] / [ (1 + i)^n – 1 ]
  /// P = Loan Amount
  /// i = Monthly Interest Rate (Annual Rate / 12 / 100)
  /// n = Number of Months (Loan Term)
  static double calculateMonthlyPayment({
    required double loanAmount,
    required double annualInterestRate,
    required int termMonths,
  }) {
    if (loanAmount <= 0 || annualInterestRate < 0 || termMonths <= 0) {
      return 0.0;
    }

    if (annualInterestRate == 0) {
      return loanAmount / termMonths;
    }

    final double monthlyRate = annualInterestRate / 12 / 100;
    final num powerTerm = pow(1 + monthlyRate, termMonths);
    
    final double monthlyPayment = loanAmount * 
        (monthlyRate * powerTerm) / 
        (powerTerm - 1);

    return monthlyPayment;
  }

  /// Calculates the total repayment amount (Monthly Payment * Term).
  static double calculateTotalRepayment({
    required double monthlyPayment,
    required int termMonths,
  }) {
    return monthlyPayment * termMonths;
  }

  /// Calculates the total interest payable (Total Repayment - Loan Amount).
  static double calculateTotalInterest({
    required double totalRepayment,
    required double loanAmount,
  }) {
    return totalRepayment - loanAmount;
  }
}
