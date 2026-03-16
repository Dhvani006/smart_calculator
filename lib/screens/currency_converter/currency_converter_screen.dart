import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_converter.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/calculator_button.dart';
import '../../widgets/banner_ad_widget.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String _fromCurrency = 'INR';
  String _toCurrency = 'USD';
  String _inputAmount = '1';
  double _convertedAmount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() => _isLoading = true);
    await CurrencyConverter.fetchLiveRates();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _convert();
      });
    }
  }

  void _convert() {
    setState(() {
      double amount = double.tryParse(_inputAmount) ?? 0;
      _convertedAmount = CurrencyConverter.convert(
        amount: amount,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );
    });
  }

  void _swapCurrencies() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _convert();
    });
  }

  void _handleNumberInput(String value) {
    setState(() {
      if (value == '⌫') {
        if (_inputAmount.length > 1) {
          _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
        } else {
          _inputAmount = '0';
        }
      } else if (value == '.') {
        if (!_inputAmount.contains('.')) {
          _inputAmount += value;
        }
      } else {
        if (_inputAmount == '0') {
          _inputAmount = value;
        } else {
          _inputAmount += value;
        }
      }
      _convert();
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
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From Currency
                      _buildCurrencySelector(
                        label: 'From',
                        selectedCurrency: _fromCurrency,
                        onChanged: (currency) {
                          setState(() {
                            _fromCurrency = currency;
                            _convert();
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      // Swap Button
                      Center(
                        child: GestureDetector(
                          onTap: _swapCurrencies,
                          child: Container(
                            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppColors.accentPurple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                            ),
                            child: const Icon(
                              Icons.swap_vert,
                              color: AppColors.accentPurple,
                              size: AppDimensions.iconLarge,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      // To Currency
                      _buildCurrencySelector(
                        label: 'To',
                        selectedCurrency: _toCurrency,
                        onChanged: (currency) {
                          setState(() {
                            _toCurrency = currency;
                            _convert();
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      // Live Status Banner
                      _buildUpgradeBanner(),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Amount Input Display
                      Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _inputAmount,
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      // Converted Amount Display
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                CurrencyConverter.formatAmount(_convertedAmount, _toCurrency),
                                style: AppTextStyles.displayLarge.copyWith(
                                  color: AppColors.accentPurple,
                                  fontSize: 48,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            Text(
                              '1 $_fromCurrency = ${CurrencyConverter.getExchangeRate(fromCurrency: _fromCurrency, toCurrency: _toCurrency).toStringAsFixed(4)} $_toCurrency',
                              style: AppTextStyles.labelMedium,
                            ),
                            Text(
                              'Last updated: ${CurrencyConverter.getLastUpdatedTime()}',
                              style: AppTextStyles.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Banner Ad
                      const Center(child: BannerAdWidget()),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      // Numeric Keypad
                      _isLoading 
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppDimensions.paddingLarge),
                                child: CircularProgressIndicator(color: AppColors.accentPurple),
                              ),
                            )
                          : _buildNumericKeypad(),
                    ],
                  ),
                ),
              ),
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
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Currency Converter',
            style: AppTextStyles.heading3,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _isLoading ? Icons.sync : Icons.refresh,
              color: AppColors.accentPurple,
            ),
            onPressed: _isLoading ? null : _fetchRates,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector({
    required String label,
    required String selectedCurrency,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppDimensions.paddingSmall),
        GlassmorphicCard(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCurrency,
              isExpanded: true,
              dropdownColor: AppColors.cardBackground,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.accentPurple),
              style: AppTextStyles.heading4,
              items: CurrencyConverter.getCurrencies().map((currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Row(
                    children: [
                      Text(
                        CurrencyConverter.getSymbol(currency),
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        '$currency - ${CurrencyConverter.getName(currency)}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericKeypad() {
    return Column(
      children: [
        Row(
          children: [
            _buildKeypadButton('1'),
            const SizedBox(width: AppDimensions.paddingSmall),
            _buildKeypadButton('2'),
            const SizedBox(width: AppDimensions.paddingSmall),
            _buildKeypadButton('3'),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: [
            _buildKeypadButton('4'),
            const SizedBox(width: AppDimensions.paddingSmall),
            _buildKeypadButton('5'),
            const SizedBox(width: AppDimensions.paddingSmall),
            _buildKeypadButton('6'),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: [
            _buildKeypadButton('7'),
            const SizedBox(width: AppDimensions.paddingSmall),
            _buildKeypadButton('8'),
            const SizedBox(width: AppDimensions.paddingSmall),
            _buildKeypadButton('9'),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: [
            _buildKeypadButton('.'),
            const SizedBox(width: AppDimensions.paddingSmall),
            _buildKeypadButton('0'),
            const SizedBox(width: AppDimensions.paddingSmall),
            _buildKeypadButton('⌫', backgroundColor: AppColors.buttonSecondary),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String value, {Color? backgroundColor}) {
    return Expanded(
      child: CalculatorButton(
        text: value,
        onPressed: () => _handleNumberInput(value),
        backgroundColor: backgroundColor,
        height: 60,
      ),
    );
  }

  Widget _buildUpgradeBanner() {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      backgroundColor: Colors.green.withOpacity(0.1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: AppDimensions.iconMedium,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Rates Active',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Using real-time exchange rate data',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
