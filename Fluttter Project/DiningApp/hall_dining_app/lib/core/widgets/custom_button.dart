import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonType type;
  final double width;
  final double height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = ButtonType.primary,
    this.width = double.infinity,
    this.height = 48,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color btnBackgroundColor;
    Color btnTextColor;
    Color disabledBackgroundColor;
    
    switch (type) {
      case ButtonType.primary:
        btnBackgroundColor = backgroundColor ?? AppColors.primary;
        btnTextColor = textColor ?? Colors.white;
        disabledBackgroundColor = AppColors.textDisabled;
        break;
      case ButtonType.secondary:
        btnBackgroundColor = backgroundColor ?? Colors.transparent;
        btnTextColor = textColor ?? AppColors.primary;
        disabledBackgroundColor = Colors.transparent;
        break;
      case ButtonType.outline:
        btnBackgroundColor = Colors.transparent;
        btnTextColor = textColor ?? AppColors.primary;
        disabledBackgroundColor = Colors.transparent;
        break;
      case ButtonType.danger:
        btnBackgroundColor = backgroundColor ?? AppColors.error;
        btnTextColor = textColor ?? Colors.white;
        disabledBackgroundColor = AppColors.textDisabled;
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: type == ButtonType.outline
          ? OutlinedButton(
              onPressed: isEnabled && !isLoading ? onPressed : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: btnTextColor,
                side: BorderSide(
                  color: isEnabled ? btnTextColor : AppColors.textDisabled,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                backgroundColor: btnBackgroundColor,
              ),
              child: _buildButtonContent(theme),
            )
          : ElevatedButton(
              onPressed: isEnabled && !isLoading ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnabled ? btnBackgroundColor : disabledBackgroundColor,
                foregroundColor: btnTextColor,
                elevation: type == ButtonType.primary ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(theme),
            ),
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.outline ? AppColors.primary : Colors.white,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: type == ButtonType.outline && isEnabled
                ? AppColors.primary
                : textColor ?? Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

enum ButtonType {
  primary,
  secondary,
  outline,
  danger,
}