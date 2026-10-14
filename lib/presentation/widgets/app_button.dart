import 'package:flutter/material.dart';
import '../../app/theme/color_palette.dart';
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
    Color getBackgroundColor() {
      if (onPressed == null && !isLoading) return ColorPalette.subtleBorder;
      switch (variant) {
        case ButtonVariant.primary:
          return ColorPalette.indigoAccent;
        case ButtonVariant.secondary:
          return ColorPalette.elevatedCard;
        case ButtonVariant.outline:
        case ButtonVariant.text:
          return Colors.transparent;
        case ButtonVariant.danger:
          return ColorPalette.error;
      }
    }

    Color getTextColor() {
      if (onPressed == null && !isLoading) return ColorPalette.textMuted;
      switch (variant) {
        case ButtonVariant.primary:
        case ButtonVariant.danger:
          return Colors.white;
        case ButtonVariant.secondary:
        case ButtonVariant.text:
          return ColorPalette.textPrimary;
        case ButtonVariant.outline:
          return ColorPalette.indigoAccent;
      }
    }

    BorderSide getBorderSide() {
      if (variant == ButtonVariant.outline) {
        return const BorderSide(color: ColorPalette.indigoAccent, width: 1.5);
      }
      if (variant == ButtonVariant.secondary) {
        return const BorderSide(color: ColorPalette.subtleBorder, width: 1);
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
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
