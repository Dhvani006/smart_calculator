import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Custom slider widget with styled track and thumb
class CustomSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String label;
  final ValueChanged<double> onChanged;
  final String? minLabel;
  final String? maxLabel;
  
  const CustomSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.label = '',
    required this.onChanged,
    this.minLabel,
    this.maxLabel,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.accentBlue,
            inactiveTrackColor: AppColors.cardBackground,
            thumbColor: AppColors.accentBlue,
            overlayColor: AppColors.accentBlue.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            trackHeight: 4,
            valueIndicatorColor: AppColors.accentBlue,
            valueIndicatorTextStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label,
            onChanged: onChanged,
          ),
        ),
        if (minLabel != null && maxLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(minLabel!, style: AppTextStyles.labelSmall),
                Text(maxLabel!, style: AppTextStyles.labelSmall),
              ],
            ),
          ),
      ],
    );
  }
}
