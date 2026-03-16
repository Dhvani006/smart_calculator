import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/emi_calculator.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_slider.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../core/utils/ad_helper.dart';
import 'emi_statistics_screen.dart';

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  State<EMICalculatorScreen> createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
  double _loanAmount = 500000; // Default 5L
  double _interestRate = 10; // Default 10%
  double _tenure = 12; // Default 12 months
  bool _isYearsMode = false; // false = months, true = years

  Map<String, double>? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    setState(() {
      int tenureMonths = _isYearsMode ? (_tenure * 12).toInt() : _tenure.toInt();
      _result = EMICalculator.calculateEMI(
        principal: _loanAmount,
        annualInterestRate: _interestRate,
        tenureMonths: tenureMonths,
      );
    });
  }

  void _reset() {
    setState(() {
      _loanAmount = 500000;
      _interestRate = 10;
      _tenure = 12;
      _isYearsMode = false;
      _calculate();
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
                      // Loan Amount Slider
                      _buildLoanAmountSlider(),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Interest Rate Slider
                      _buildInterestRateSlider(),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Tenure Slider with Yr/Mo toggle
                      _buildTenureSlider(),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // EMI Result
                      if (_result != null) _buildEMIResult(),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      // Summary Cards
                      if (_result != null) _buildSummaryCards(),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // View Breakup Button
                      CustomButton(
                        text: 'View Breakup',
                        onPressed: () {
                          // Show interstitial ad before showing the breakup dialog
                          AdHelper.showInterstitialAd(onAdClosed: () {
                            if (_result != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EMIStatisticsScreen(
                                    principal: _loanAmount,
                                    interestRate: _interestRate,
                                    tenureMonths: _isYearsMode ? (_tenure * 12).toInt() : _tenure.toInt(),
                                    emiData: _result!,
                                  ),
                                ),
                              );
                            }
                          });
                        },
                        width: double.infinity,
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Bottom Banner Ad
                      const Center(child: BannerAdWidget()),
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
          const SizedBox(width: AppDimensions.paddingMedium),
          Text(
            'EMI Calculator',
            style: AppTextStyles.heading3,
          ),
          const Spacer(),
          TextButton(
            onPressed: _reset,
            child: Text(
              'Reset',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accentOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanAmountSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Loan Amount', style: AppTextStyles.labelLarge),
            Text(
              EMICalculator.formatCurrency(_loanAmount),
              style: AppTextStyles.heading4.copyWith(color: AppColors.accentOrange),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        CustomSlider(
          value: _loanAmount,
          min: 10000,
          max: 10000000,
          divisions: 999,
          onChanged: (value) {
            setState(() {
              _loanAmount = value;
              _calculate();
            });
          },
          minLabel: '10K',
          maxLabel: '1Cr',
        ),
      ],
    );
  }

  Widget _buildInterestRateSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Interest Rate', style: AppTextStyles.labelLarge),
            Text(
              '${_interestRate.toStringAsFixed(1)}%',
              style: AppTextStyles.heading4.copyWith(color: AppColors.accentOrange),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        CustomSlider(
          value: _interestRate,
          min: 1,
          max: 25,
          divisions: 240,
          onChanged: (value) {
            setState(() {
              _interestRate = value;
              _calculate();
            });
          },
          minLabel: '1%',
          maxLabel: '25%',
        ),
      ],
    );
  }

  Widget _buildTenureSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Loan Tenure', style: AppTextStyles.labelLarge),
            Row(
              children: [
                Text(
                  _isYearsMode
                      ? '${_tenure.toInt()} Yr'
                      : '${_tenure.toInt()} Mo',
                  style: AppTextStyles.heading4.copyWith(color: AppColors.accentOrange),
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                _buildTenureModeToggle(),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        CustomSlider(
          value: _tenure,
          min: _isYearsMode ? 1 : 1,
          max: _isYearsMode ? 30 : 360,
          divisions: _isYearsMode ? 29 : 359,
          onChanged: (value) {
            setState(() {
              _tenure = value;
              _calculate();
            });
          },
          minLabel: _isYearsMode ? '1 Yr' : '1 Mo',
          maxLabel: _isYearsMode ? '30 Yr' : '30 Yr',
        ),
      ],
    );
  }

  Widget _buildTenureModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        children: [
          _buildToggleButton('Mo', !_isYearsMode, () {
            if (_isYearsMode) {
              setState(() {
                _tenure = _tenure * 12;
                _isYearsMode = false;
                _calculate();
              });
            }
          }),
          _buildToggleButton('Yr', _isYearsMode, () {
            if (!_isYearsMode) {
              setState(() {
                _tenure = _tenure / 12;
                _isYearsMode = true;
                _calculate();
              });
            }
          }),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEMIResult() {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        children: [
          Text(
            'Your Monthly EMI',
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              EMICalculator.formatCurrency(_result!['emi']!),
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.accentOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: GlassmorphicCard(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Interest',
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  EMICalculator.formatCurrency(_result!['totalInterest']!),
                  style: AppTextStyles.heading4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: GlassmorphicCard(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Payable',
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  EMICalculator.formatCurrency(_result!['totalPayable']!),
                  style: AppTextStyles.heading4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
