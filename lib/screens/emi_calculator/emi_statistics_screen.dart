import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/emi_calculator.dart';

class EMIStatisticsScreen extends StatelessWidget {
  final double principal;
  final double interestRate;
  final int tenureMonths;
  final Map<String, double> emiData;

  const EMIStatisticsScreen({
    super.key,
    required this.principal,
    required this.interestRate,
    required this.tenureMonths,
    required this.emiData,
  });

  @override
  Widget build(BuildContext context) {
    final schedule = EMICalculator.calculateAmortizationSchedule(
      principal: principal,
      annualInterestRate: interestRate,
      tenureMonths: tenureMonths,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('EMI Statistics', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // Chart Section
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 70,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          color: const Color(0xFF1E88FF),
                          value: emiData['totalInterest']!,
                          title: '',
                          radius: 25,
                        ),
                        PieChartSectionData(
                          color: const Color(0xFF90CAF9),
                          value: emiData['principal']!,
                          title: '',
                          radius: 25,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Maturity Value:',
                        style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF1E88FF)),
                      ),
                      Text(
                        EMICalculator.formatCurrency(emiData['totalPayable']!),
                        style: AppTextStyles.heading4.copyWith(
                          color: const Color(0xFF1E88FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Legend Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLegendItem('Interest', emiData['totalInterest']!, const Color(0xFF1E88FF)),
                  _buildLegendItem('Loan Amount', emiData['principal']!, const Color(0xFF90CAF9)),
                ],
              ),
            ),

            // Amortization Table Headers
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
              decoration: const BoxDecoration(
                color: Color(0xFF1E88FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text('Month', style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text('Principal', style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                  Expanded(flex: 3, child: Text('Interest', style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                  Expanded(flex: 4, child: Text('Balance', style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                ],
              ),
            ),

            // Table Body
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: AppDimensions.paddingMedium, right: AppDimensions.paddingMedium, bottom: AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: ListView.builder(
                    itemCount: schedule.length,
                    itemBuilder: (context, index) {
                      final item = schedule[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                          color: index % 2 == 0 ? Colors.transparent : Colors.white.withValues(alpha: 0.02),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text('${item['month']!.toInt()}', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70))),
                            Expanded(flex: 3, child: Text(EMICalculator.formatCurrency(item['principal']!), style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), textAlign: TextAlign.right)),
                            Expanded(flex: 3, child: Text(EMICalculator.formatCurrency(item['interest']!), style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), textAlign: TextAlign.right)),
                            Expanded(flex: 4, child: Text(EMICalculator.formatCurrency(item['balance']!), style: AppTextStyles.bodyMedium.copyWith(color: Colors.white), textAlign: TextAlign.right)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            amount.toStringAsFixed(2),
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
