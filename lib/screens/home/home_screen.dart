import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../core/services/app_rating_service.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/native_ad_widget.dart';
import '../standard_calculator/standard_calculator_screen.dart';
import '../gst_calculator/gst_calculator_screen.dart';
import '../emi_calculator/emi_calculator_screen.dart';
import '../currency_converter/currency_converter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _initAppRating();
  }

  Future<void> _initAppRating() async {
    await AppRatingService.incrementLaunchCount();
    if (await AppRatingService.isRatingRequired()) {
      // Small delay to ensure UI is ready
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          AppRatingService.requestReview();
        }
      });
    }
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
              // Top App Bar
              _buildAppBar(),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Calculator',
                        style: AppTextStyles.heading1,
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Text(
                        'Choose your calculator type',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Calculator Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.95,
                        children: [
                          _CalculatorCard(
                            icon: Icons.calculate_rounded,
                            title: 'Standard',
                            subtitle: 'Basic',
                            accentColor: AppColors.accentBlue,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StandardCalculatorScreen(),
                              ),
                            ),
                          ),
                          _CalculatorCard(
                            icon: Icons.receipt_long,
                            title: 'GST',
                            subtitle: 'Tax calculation',
                            accentColor: AppColors.accentGreen,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GSTCalculatorScreen(),
                              ),
                            ),
                          ),
                          _CalculatorCard(
                            icon: Icons.home_work,
                            title: 'EMI',
                            subtitle: 'Loan calculator',
                            accentColor: AppColors.accentOrange,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EMICalculatorScreen(),
                              ),
                            ),
                          ),
                          _CalculatorCard(
                            icon: Icons.currency_exchange,
                            title: 'Currency',
                            subtitle: 'Exchange rates',
                            accentColor: AppColors.accentPurple,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CurrencyConverterScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      // Native Ad
                      const NativeAdWidget(),
                      
                      const SizedBox(height: AppDimensions.paddingMedium),
                      
                      // Footer
                      Center(
                        child: Text(
                          'Offline • Made for India',
                          style: AppTextStyles.labelSmall,
                        ),
                      ),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Smart Calculator',
            style: AppTextStyles.heading3,
          ),
          IconButton(
            onPressed: () => AppRatingService.requestReview(),
            icon: const Icon(Icons.star_outline_rounded, color: Colors.white70),
            tooltip: 'Rate App',
          ),
        ],
      ),
    );
  }


}

class _CalculatorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _CalculatorCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.heading4,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.labelMedium,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
