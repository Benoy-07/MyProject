import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_button.dart';

class ErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onRetry;
  final IconData icon;
  final Color iconColor;

  const ErrorWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor = AppColors.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: buttonText,
              onPressed: onRetry,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}

// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorWidget({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      title: 'Connection Error',
      message: 'Please check your internet connection and try again.',
      buttonText: 'Retry',
      onRetry: onRetry,
      icon: Icons.wifi_off,
      iconColor: AppColors.warning,
    );
  }
}

// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.message,
    this.buttonText = 'Refresh',
    this.onAction,
    this.icon = Icons.inbox_outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: buttonText,
                onPressed: onAction!,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Specific empty states
class NoMenuItemsWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const NoMenuItemsWidget({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Menu Items',
      message: 'There are no menu items available at the moment. Please check back later.',
      buttonText: 'Refresh',
      onAction: onRefresh,
      icon: Icons.restaurant_menu_outlined,
    );
  }
}

class NoOrdersWidget extends StatelessWidget {
  final VoidCallback onBrowseMenu;

  const NoOrdersWidget({
    Key? key,
    required this.onBrowseMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Orders',
      message: 'You haven\'t placed any orders yet. Browse our menu and place your first order!',
      buttonText: 'Browse Menu',
      onAction: onBrowseMenu,
      icon: Icons.shopping_bag_outlined,
    );
  }
}

// Error dialog
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      ],
    );
  }
}