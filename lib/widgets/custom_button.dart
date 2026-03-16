import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/constants/app_text_styles.dart';

enum ButtonVariant { primary, secondary, danger, outlined }

/// Custom button widget with animations and variants
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isLoading;
  
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.icon,
    this.isLoading = false,
  });
  
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Color _getBackgroundColor() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.buttonPrimary;
      case ButtonVariant.secondary:
        return AppColors.buttonSecondary;
      case ButtonVariant.danger:
        return AppColors.buttonDanger;
      case ButtonVariant.outlined:
        return Colors.transparent;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: widget.variant == ButtonVariant.outlined
                ? Border.all(color: AppColors.accentBlue, width: 2)
                : null,
            boxShadow: widget.variant != ButtonVariant.outlined
                ? [
                    BoxShadow(
                      color: _getBackgroundColor().withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: AppColors.textPrimary,
                        size: AppDimensions.iconSmall,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                    ],
                    Text(
                      widget.text,
                      style: AppTextStyles.buttonText,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
