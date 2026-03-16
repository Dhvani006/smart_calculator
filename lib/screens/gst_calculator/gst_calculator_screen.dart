import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/gst_calculator.dart';
import '../../core/utils/calculator_logic.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/native_ad_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GSTCalculatorScreen extends StatefulWidget {
  const GSTCalculatorScreen({super.key});

  @override
  State<GSTCalculatorScreen> createState() => _GSTCalculatorScreenState();
}

class _GSTCalculatorScreenState extends State<GSTCalculatorScreen> {
  final CalculatorLogic _calc = CalculatorLogic();
  final ScreenshotController _screenshotController = ScreenshotController();
  
  bool _isIntraState = true;
  bool _isAddMode = true; // true for GST Add, false for GST Remove
  
  double _gstRate = 18;
  Map<String, double>? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    // Remove commas for parsing
    double amount = double.tryParse(_calc.display.replaceAll(',', '')) ?? 0;
    setState(() {
      if (_isAddMode) {
        _result = GSTCalculator.calculateGSTAdd(
          baseAmount: amount,
          gstRate: _gstRate,
        );
      } else {
        _result = GSTCalculator.calculateGSTRemove(
          totalAmount: amount,
          gstRate: _gstRate,
        );
      }
    });
  }

  void _handleKeyPress(String key) {
    setState(() {
      switch (key) {
        case 'AC':
          _calc.clear();
          break;
        case 'DEL':
          _calc.clearEntry();
          break;
        case '.':
          _calc.inputDecimal();
          break;
        case '00':
          _calc.inputDigit('0');
          _calc.inputDigit('0');
          break;
        case '+':
        case '-':
        case '×':
        case '÷':
          _calc.inputOperator(key);
          break;
        case '=':
          _calc.calculate();
          break;
        case '%':
          _calc.percentage();
          break;
        default:
          if (RegExp(r'^\d$').hasMatch(key)) {
            _calc.inputDigit(key);
          }
      }
      _calculate();
    });
  }

  void _applyGSTRate(double rate, bool isAdd) {
    setState(() {
      _gstRate = rate;
      _isAddMode = isAdd;
      _calculate();
    });
  }

  void _copyToClipboard() {
    if (_result == null) return;
    final String text = _getFormattedCalculationText();
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to Clipboard'), backgroundColor: AppColors.accentGreen),
      );
    });
  }

  void _shareCalculation() {
    if (_result == null) return;
    final String text = _getFormattedCalculationText();
    Share.share(text, subject: 'GST Calculation');
  }

  Future<void> _takeScreenshot() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        await Gal.putImageBytes(image, name: "GST_Calculation_${DateTime.now().millisecondsSinceEpoch}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screenshot saved to Gallery'), backgroundColor: AppColors.accentGreen),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    }
  }

  String _getFormattedCalculationText() {
    if (_result == null) return '';
    final amount = _calc.display;
    final mode = _isAddMode ? 'Add GST' : 'Remove GST';
    final state = _isIntraState ? 'Intra State (CGST/SGST)' : 'Inter State (IGST)';
    
    return '''
GST Calculation Summary
Mode: $mode
State: $state
GST Rate: ${_gstRate.toStringAsFixed(0)}%

Net Amount: ${GSTCalculator.formatCurrency(_result!['baseAmount']!)}
GST Amount: ${GSTCalculator.formatCurrency(_result!['gstAmount']!)}
${_isIntraState ? 'CGST (50%): ${GSTCalculator.formatCurrency(_result!['cgst']!)}\nSGST (50%): ${GSTCalculator.formatCurrency(_result!['sgst']!)}' : 'IGST (100%): ${GSTCalculator.formatCurrency(_result!['gstAmount']!)}'}

Total Amount: ${GSTCalculator.formatCurrency(_result!['totalAmount']!)}

Calculated using Smart Calc
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                child: NativeAdWidget(templateType: TemplateType.small, height: 60),
              ),
              
              Expanded(
                child: Column(
                  children: [
                    // Display Panel
                    _buildDisplayPanel(),
                    
                    // Controls (Intra/Inter & Add/Remove Toggle)
                    _buildControlBar(),
                    
                    // GST Rate Shortcuts
                    _buildGSTRateGrid(),
                    
                    // Numeric Keypad
                    Expanded(child: _buildKeypad()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
      child: Screenshot(
        controller: _screenshotController,
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GST Amount (${_gstRate.toStringAsFixed(0)}%)', style: AppTextStyles.labelSmall),
                      Text(
                        _result != null ? GSTCalculator.formatCurrency(_result!['gstAmount']!) : '₹0.00',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('INPUT AMOUNT', style: AppTextStyles.labelSmall),
                      Text(
                        _calc.display,
                        style: AppTextStyles.heading4.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _isAddMode ? 'TOTAL AMOUNT' : 'NET AMOUNT',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                    ),
                    Text(
                      _result != null 
                          ? GSTCalculator.formatCurrency(_isAddMode ? _result!['totalAmount']! : _result!['baseAmount']!) 
                          : '₹0.00',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.accentGreen,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isIntraState) ...[
                      _buildMiniResult('CGST', _result!['cgst']!),
                      const SizedBox(width: 16),
                      _buildMiniResult('SGST', _result!['sgst']!),
                    ] else ...[
                      _buildMiniResult('IGST', _result!['gstAmount']!),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniResult(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
        Text(GSTCalculator.formatCurrency(amount), style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildControlBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium, vertical: 8),
      child: Row(
        children: [
          // Intra/Inter State
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildRadio('Intra', _isIntraState, () => setState(() => _isIntraState = true)),
                const SizedBox(width: 12),
                _buildRadio('Inter', !_isIntraState, () => setState(() => _isIntraState = false)),
              ],
            ),
          ),
          
          // Mode Toggle (Add/Remove)
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _isAddMode ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      width: 50,
                      height: 32,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _isAddMode = true; _calculate(); }),
                          child: Center(
                            child: Text(
                              '+ GST',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _isAddMode ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _isAddMode = false; _calculate(); }),
                          child: Center(
                            child: Text(
                              '- GST',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: !_isAddMode ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadio(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.accentOrange : AppColors.textMuted,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.accentOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelMedium.copyWith(color: isSelected ? AppColors.textPrimary : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildGSTRateGrid() {
    final rates = [3, 5, 12, 18, 28, 40];
    return Column(
      children: [
        // Plus rates
        _buildRateRow(rates, true),
        // Minus rates
        _buildRateRow(rates, false),
      ],
    );
  }

  Widget _buildRateRow(List<int> rates, bool isAdd) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: rates.map((rate) {
          final isSelected = _gstRate == rate && _isAddMode == isAdd;
          return Expanded(
            child: GestureDetector(
              onTap: () => _applyGSTRate(rate.toDouble(), isAdd),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
                  border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: Center(
                  child: Text(
                    '${isAdd ? '+' : '-'}${rate}%',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.accentGreen : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      color: Colors.black.withOpacity(0.2),
      child: Column(
        children: [
          Expanded(child: _buildKeypadRow(['7', '8', '9', '÷', 'DEL'])),
          Expanded(child: _buildKeypadRow(['4', '5', '6', '×', 'AC'])),
          Expanded(child: _buildKeypadRow(['1', '2', '3', '-', '%'])),
          Expanded(child: _buildKeypadRow(['0', '00', '.', '+', '='])),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKey(String key) {
    bool isOperator = ['÷', '×', '-', '+', '=', '%'].contains(key);
    bool isAction = ['DEL', 'AC'].contains(key);
    Color? textColor;
    if (isOperator) textColor = AppColors.accentOrange;
    if (isAction) textColor = AppColors.error;
    if (key == '=') textColor = Colors.white;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleKeyPress(key),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
            color: key == '=' ? AppColors.accentOrange : Colors.transparent,
          ),
          child: Center(
            child: Text(
              key,
              style: AppTextStyles.heading3.copyWith(
                color: textColor ?? AppColors.textPrimary,
                fontWeight: isOperator || isAction ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Placeholder for missing methods that were used in the old form layout or might be needed for the new one.
  void _showEditGSTRatesDialog(List<double> currentRates) {
    // Re-implement if needed for custom rates
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E88FF), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Text(
            'GST Calculator',
            style: AppTextStyles.heading4.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white, size: 20),
            onPressed: _copyToClipboard,
            tooltip: 'Copy text',
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
            onPressed: _takeScreenshot,
            tooltip: 'Save Screenshot',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 20),
            onPressed: _shareCalculation,
            tooltip: 'Share',
          ),
        ],
      ),
    );
  }
}
