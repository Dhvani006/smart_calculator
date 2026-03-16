import 'dart:math';

/// EMI (Equated Monthly Installment) calculation utilities
class EMICalculator {
  /// Calculate EMI using the standard formula:
  /// EMI = [P x R x (1+R)^N] / [(1+R)^N-1]
  /// where P = Principal loan amount, R = Monthly interest rate, N = Tenure in months
  static Map<String, double> calculateEMI({
    required double principal,
    required double annualInterestRate,
    required int tenureMonths,
  }) {
    // Convert annual interest rate to monthly rate
    double monthlyRate = (annualInterestRate / 100) / 12;
    
    // Calculate EMI
    double emi;
    if (monthlyRate == 0) {
      // If interest rate is 0, simple division
      emi = principal / tenureMonths;
    } else {
      double numerator = principal * monthlyRate * pow(1 + monthlyRate, tenureMonths);
      double denominator = pow(1 + monthlyRate, tenureMonths) - 1;
      emi = numerator / denominator;
    }
    
    // Calculate total amount payable and total interest
    double totalPayable = emi * tenureMonths;
    double totalInterest = totalPayable - principal;
    
    return {
      'emi': emi,
      'totalInterest': totalInterest,
      'totalPayable': totalPayable,
      'principal': principal,
    };
  }

  /// Format currency for display (Indian rupee format)
  static String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(0);
    
    // Add commas (Indian style: last 3 digits, then groups of 2)
    if (amountStr.length > 3) {
      String last3 = amountStr.substring(amountStr.length - 3);
      String remaining = amountStr.substring(0, amountStr.length - 3);
      
      String formatted = '';
      for (int i = remaining.length - 1; i >= 0; i--) {
        formatted = remaining[i] + formatted;
        if (((remaining.length - i) % 2 == 0) && i != 0) {
          formatted = ',$formatted';
        }
      }
      amountStr = formatted + ',' + last3;
    }
    
    return '₹$amountStr';
  }

  /// Convert amount to display format (K, L, Cr)
  static String formatLargeAmount(double amount) {
    if (amount >= 10000000) {
      // Crore
      return '${(amount / 10000000).toStringAsFixed(1)} Cr';
    } else if (amount >= 100000) {
      // Lakh
      return '${(amount / 100000).toStringAsFixed(1)} L';
    } else if (amount >= 1000) {
      // Thousand
      return '${(amount / 1000).toStringAsFixed(0)} K';
    }
    return amount.toStringAsFixed(0);
  }

  /// Generate monthly amortization schedule
  static List<Map<String, double>> calculateAmortizationSchedule({
    required double principal,
    required double annualInterestRate,
    required int tenureMonths,
  }) {
    final emiData = calculateEMI(
      principal: principal,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
    );
    
    double emi = emiData['emi']!;
    double monthlyRate = (annualInterestRate / 100) / 12;
    double currentBalance = principal;
    List<Map<String, double>> schedule = [];

    for (int i = 1; i <= tenureMonths; i++) {
      double interestForMonth = currentBalance * monthlyRate;
      double principalForMonth = emi - interestForMonth;
      
      // Handle the last month to ensure balance goes to zero
      if (i == tenureMonths) {
        principalForMonth = currentBalance;
        interestForMonth = emi - principalForMonth;
        currentBalance = 0;
      } else {
        currentBalance -= principalForMonth;
      }

      schedule.add({
        'month': i.toDouble(),
        'principal': principalForMonth,
        'interest': interestForMonth,
        'balance': currentBalance > 0 ? currentBalance : 0,
      });
    }

    return schedule;
  }
}
