/// GST calculation utilities
class GSTCalculator {
  /// Calculate GST when adding to base amount
  static Map<String, double> calculateGSTAdd({
    required double baseAmount,
    required double gstRate,
  }) {
    double gstAmount = (baseAmount * gstRate) / 100;
    double cgst = gstAmount / 2;
    double sgst = gstAmount / 2;
    double totalAmount = baseAmount + gstAmount;
    
    return {
      'baseAmount': baseAmount,
      'gstRate': gstRate,
      'gstAmount': gstAmount,
      'cgst': cgst,
      'sgst': sgst,
      'totalAmount': totalAmount,
    };
  }

  /// Calculate GST when removing from total amount
  static Map<String, double> calculateGSTRemove({
    required double totalAmount,
    required double gstRate,
  }) {
    double baseAmount = (totalAmount * 100) / (100 + gstRate);
    double gstAmount = totalAmount - baseAmount;
    double cgst = gstAmount / 2;
    double sgst = gstAmount / 2;
    
    return {
      'baseAmount': baseAmount,
      'gstRate': gstRate,
      'gstAmount': gstAmount,
      'cgst': cgst,
      'sgst': sgst,
      'totalAmount': totalAmount,
    };
  }

  /// Format currency for display (Indian rupee format)
  static String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(2);
    List<String> parts = amountStr.split('.');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? '.${parts[1]}' : '';
    
    // Add commas (Indian style: last 3 digits, then groups of 2)
    if (intPart.length > 3) {
      String last3 = intPart.substring(intPart.length - 3);
      String remaining = intPart.substring(0, intPart.length - 3);
      
      String formatted = '';
      for (int i = remaining.length - 1; i >= 0; i--) {
        formatted = remaining[i] + formatted;
        if (((remaining.length - i) % 2 == 0) && i != 0) {
          formatted = ',$formatted';
        }
      }
      intPart = formatted + ',' + last3;
    }
    
    return '₹$intPart$decPart';
  }

  /// Common GST rates in India
  static List<double> _commonGSTRates = [3, 5, 12, 18, 28];
  
  static List<double> getCommonGSTRates() {
    return _commonGSTRates;
  }
  
  /// Update common GST rates with custom values
  static void updateCommonGSTRates(List<double> newRates) {
    _commonGSTRates = newRates;
  }
}
