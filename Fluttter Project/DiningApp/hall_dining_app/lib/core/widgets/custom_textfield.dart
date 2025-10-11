import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final bool readOnly;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool isRequired;
  final bool autoFocus;
  final String? errorText;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.initialValue,
    this.isRequired = false,
    this.autoFocus = false,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          readOnly: readOnly,
          textInputAction: textInputAction,
          focusNode: focusNode,
          initialValue: initialValue,
          autofocus: autoFocus,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: enabled ? theme.colorScheme.onSurface : AppColors.textDisabled,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : AppColors.background,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textDisabled,
            ),
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

// Specialized text field for search
class SearchTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function()? onClear;

  const SearchTextField({
    Key? key,
    this.hintText = 'Search...',
    this.controller,
    this.onChanged,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: '',
      hintText: hintText,
      controller: controller,
      onChanged: onChanged,
      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
              onPressed: onClear,
            )
          : null,
    );
  }
}

// Specialized text field for price input
class PriceTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String currency;

  const PriceTextField({
    Key? key,
    required this.label,
    this.controller,
    this.onChanged,
    this.validator,
    this.currency = '৳',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      controller: controller,
      keyboardType: TextInputType.number,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Text(
          currency,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}