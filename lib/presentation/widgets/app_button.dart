import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/haptic_utils.dart';

enum ButtonVariant { primary, secondary, outline, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final ButtonVariant variant;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = 48,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color getBackgroundColor() {
      if (onPressed == null && !isLoading) return colors.borderSubtle;
      switch (variant) {
        case ButtonVariant.primary:
          return colors.primary;
        case ButtonVariant.secondary:
          return colors.surface;
        case ButtonVariant.outline:
        case ButtonVariant.text:
          return Colors.transparent;
        case ButtonVariant.danger:
          return colors.error;
      }
    }

    Color getTextColor() {
      if (onPressed == null && !isLoading) return colors.textMuted;
      switch (variant) {
        case ButtonVariant.primary:
          return colors.onPrimary;
        case ButtonVariant.danger:
          return Colors.white;
        case ButtonVariant.secondary:
        case ButtonVariant.text:
        case ButtonVariant.outline:
          return colors.textPrimary;
      }
    }

    BorderSide getBorderSide() {
      if (variant == ButtonVariant.outline) {
        return BorderSide(color: colors.border, width: 1.5);
      }
      if (variant == ButtonVariant.secondary) {
        return BorderSide(color: colors.border, width: 1);
      }
      return BorderSide.none;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: getBackgroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: getBorderSide(),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: (onPressed != null && !isLoading)
              ? () {
                  HapticUtils.lightImpact();
                  onPressed!();
                }
              : null,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: getTextColor(),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
