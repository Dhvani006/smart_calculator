import 'dart:math';

/// Calculator logic for standard calculator operations
class CalculatorLogic {
  String _display = '0';
  String _expression = '';
  double _memory = 0;
  String _previousOperator = '';
  double _previousValue = 0;
  bool _shouldResetDisplay = false;

  String get display => _formatNumber(_display);
  String get expression => _expression;
  double get memory => _memory;

  /// Format number with commas for Indian numbering system
  String _formatNumber(String number) {
    if (number.isEmpty || number == '0') return '0';
    
    // Handle decimal numbers
    List<String> parts = number.split('.');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? '.${parts[1]}' : '';
    
    // Remove existing commas
    intPart = intPart.replaceAll(',', '');
    
    // Add commas (Indian style: last 3 digits, then groups of 2)
    if (intPart.length > 3) {
      String last3 = intPart.substring(intPart.length - 3);
      String remaining = intPart.substring(0, intPart.length - 3);
      
      // Add commas every 2 digits for the remaining part
      String formatted = '';
      for (int i = remaining.length - 1; i >= 0; i--) {
        formatted = remaining[i] + formatted;
        if (((remaining.length - i) % 2 == 0) && i != 0) {
          formatted = ',$formatted';
        }
      }
      intPart = formatted + ',' + last3;
    }
    
    return intPart + decPart;
  }

  /// Input a digit
  void inputDigit(String digit) {
    if (_shouldResetDisplay) {
      _display = digit;
      _shouldResetDisplay = false;
    } else {
      if (_display == '0' && digit != '.') {
        _display = digit;
      } else {
        _display += digit;
      }
    }
  }

  /// Input decimal point
  void inputDecimal() {
    if (_shouldResetDisplay) {
      _display = '0.';
      _shouldResetDisplay = false;
    } else if (!_display.contains('.')) {
      _display += '.';
    }
  }

  /// Input operator
  void inputOperator(String operator) {
    if (_previousOperator.isNotEmpty) {
      calculate();
    }
    _previousValue = double.tryParse(_display.replaceAll(',', '')) ?? 0;
    _previousOperator = operator;
    _expression = '${_formatNumber(_display)} $operator';
    _shouldResetDisplay = true;
  }

  /// Calculate result
  void calculate() {
    if (_previousOperator.isEmpty) return;
    
    double currentValue = double.tryParse(_display.replaceAll(',', '')) ?? 0;
    double result = 0;
    
    switch (_previousOperator) {
      case '+':
        result = _previousValue + currentValue;
        break;
      case '-':
        result = _previousValue - currentValue;
        break;
      case '×':
      case '*':
        result = _previousValue * currentValue;
        break;
      case '÷':
      case '/':
        if (currentValue != 0) {
          result = _previousValue / currentValue;
        } else {
          clear();
          return;
        }
        break;
      default:
        return;
    }
    
    _expression = '';
    _display = result.toString();
    _previousOperator = '';
    _previousValue = 0;
    _shouldResetDisplay = true;
  }

  /// Calculate percentage
  void percentage() {
    double value = double.tryParse(_display.replaceAll(',', '')) ?? 0;
    _display = (value / 100).toString();
  }

  /// Calculate square root
  void squareRoot() {
    double value = double.tryParse(_display.replaceAll(',', '')) ?? 0;
    if (value >= 0) {
      _display = sqrt(value).toString();
      _shouldResetDisplay = true;
    }
  }

  /// Clear all
  void clear() {
    _display = '0';
    _expression = '';
    _previousOperator = '';
    _previousValue = 0;
    _shouldResetDisplay = false;
  }

  /// Clear entry (backspace)
  void clearEntry() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
  }

  /// Memory operations
  void memoryAdd() {
    double value = double.tryParse(_display.replaceAll(',', '')) ?? 0;
    _memory += value;
  }

  void memorySubtract() {
    double value = double.tryParse(_display.replaceAll(',', '')) ?? 0;
    _memory -= value;
  }

  void memoryRecall() {
    if (_memory != 0) {
      _display = _memory.toString();
      _shouldResetDisplay = true;
    }
  }

  void memoryClear() {
    _memory = 0;
  }

  /// Toggle sign
  void toggleSign() {
    double value = double.tryParse(_display.replaceAll(',', '')) ?? 0;
    _display = (-value).toString();
  }
}
