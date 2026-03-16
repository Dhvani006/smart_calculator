import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/calculator_logic.dart';
import '../../core/utils/ad_helper.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/calculator_button.dart';

class StandardCalculatorScreen extends StatefulWidget {
  const StandardCalculatorScreen({super.key});

  @override
  State<StandardCalculatorScreen> createState() => _StandardCalculatorScreenState();
}

class _StandardCalculatorScreenState extends State<StandardCalculatorScreen> {
  final CalculatorLogic _calculator = CalculatorLogic();
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('calculator_history') ?? [];
    });
  }

  Future<void> _saveToHistory(String calculation) async {
    final prefs = await SharedPreferences.getInstance();
    _history.insert(0, calculation); // Add to beginning
    
    // Keep only last 12 calculations
    if (_history.length > 12) {
      _history = _history.sublist(0, 12);
    }
    
    await prefs.setStringList('calculator_history', _history);
  }

  void _handleButtonPress(String value) {
    setState(() {
      switch (value) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
          _calculator.inputDigit(value);
          break;
        case '00':
          _calculator.inputDigit('0');
          _calculator.inputDigit('0');
          break;
        case '.':
          _calculator.inputDecimal();
          break;
        case '+':
        case '-':
        case '×':
        case '÷':
          _calculator.inputOperator(value);
          break;
        case '=':
          String expression = '${_calculator.expression} ${_calculator.display}';
          _calculator.calculate();
          String result = _calculator.display;
          _saveToHistory('$expression = $result');
          AdHelper.incrementCalculationCount(); // Increment calculation count
          break;
        case 'AC':
          _calculator.clear();
          break;
        case '⌫':
          _calculator.clearEntry();
          break;
        case '%':
          _calculator.percentage();
          break;
        case '√':
          _calculator.squareRoot();
          break;
        case 'M+':
          _calculator.memoryAdd();
          break;
        case 'M-':
          _calculator.memorySubtract();
          break;
        case 'MRC':
          _calculator.memoryRecall();
          break;
        case '+/-':
          _calculator.toggleSign();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),
              
              // Display Panel
              _buildDisplayPanel(),
              
              // Calculator Buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    children: [
                      // Special Functions Row
                      _buildSpecialFunctionsRow(),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      
                      // Main Keypad
                      Expanded(child: _buildKeypad()),
                    ],
                  ),
                ),
              ),
              
              // Bottom Ad Placeholder
              _buildAdPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              if (AdHelper.shouldShowInterstitial()) {
                AdHelper.showInterstitialAd(onAdClosed: () {
                  Navigator.pop(context);
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const Spacer(),
          Text(
            'CITIZEN CALC',
            style: AppTextStyles.heading4,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.textSecondary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.cardBackground,
                  title: Text('History', style: AppTextStyles.heading4),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: _history.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No history yet',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  _history[index],
                                  style: AppTextStyles.bodyMedium,
                                ),
                              );
                            },
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayPanel() {
    return GlassmorphicCard(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small expression text at top
          if (_calculator.expression.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _calculator.expression,
                style: AppTextStyles.calculatorSteps,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          // Main display - show full expression or result
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _calculator.display,
              style: AppTextStyles.calculatorResult,
              textAlign: TextAlign.right,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSpecialFunctionsRow() {
    return Row(
      children: [
        Expanded(
          child: CalculatorButton(
            text: 'MRC',
            onPressed: () => _handleButtonPress('MRC'),
            isSpecial: true,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: CalculatorButton(
            text: 'M-',
            onPressed: () => _handleButtonPress('M-'),
            isSpecial: true,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: CalculatorButton(
            text: 'M+',
            onPressed: () => _handleButtonPress('M+'),
            isSpecial: true,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: CalculatorButton(
            text: '⌫',
            onPressed: () => _handleButtonPress('⌫'),
            isSpecial: true,
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildButton('AC', backgroundColor: AppColors.error),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('+/-'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('%', isOperator: true),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('÷', isOperator: true),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Expanded(
              child: Row(
                children: [
                  _buildButton('7'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('8'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('9'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('×', isOperator: true),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Expanded(
              child: Row(
                children: [
                  _buildButton('4'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('5'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('6'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('-', isOperator: true),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Expanded(
              child: Row(
                children: [
                  _buildButton('1'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('2'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('3'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('+', isOperator: true),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Expanded(
              child: Row(
                children: [
                  _buildButton('0'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('00'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('.'),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildButton('=', backgroundColor: AppColors.accentBlue),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(String text, {bool isOperator = false, Color? backgroundColor}) {
    return Expanded(
      child: CalculatorButton(
        text: text,
        onPressed: () => _handleButtonPress(text),
        isOperator: isOperator,
        backgroundColor: backgroundColor,
      ),
    );
  }

  Widget _buildAdPlaceholder() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      child: BannerAdWidget(showLabel: true),
    );
  }
}
