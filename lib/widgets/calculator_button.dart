import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/constants/app_text_styles.dart';

/// Calculator button widget with custom styling
class CalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isOperator;
  final bool isSpecial;
  
  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.isOperator = false,
    this.isSpecial = false,
  });
  
  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _isPressed = false;
  
  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    if (widget.isOperator) return AppColors.accentBlue.withOpacity(0.2);
    if (widget.isSpecial) return AppColors.buttonSecondary;
    return AppColors.cardBackground;
  }
  
  Color _getTextColor() {
    if (widget.textColor != null) return widget.textColor!;
    if (widget.isOperator) return AppColors.accentBlue;
    return AppColors.textPrimary;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width ?? AppDimensions.calculatorButtonSize,
        height: widget.height ?? AppDimensions.calculatorButtonSize,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(-1, -1),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: AppTextStyles.buttonText.copyWith(
              color: _getTextColor(),
              fontSize: widget.text.length > 2 ? 14 : 20,
            ),
          ),
        ),
      ),
    );
  }
}
