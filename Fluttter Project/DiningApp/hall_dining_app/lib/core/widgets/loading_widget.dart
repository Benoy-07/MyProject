import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;
  final bool withBackground;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size = 40,
    this.color = AppColors.primary,
    this.withBackground = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (withBackground) {
      return Container(
        color: Colors.white.withOpacity(0.8),
        child: Center(child: child),
      );
    }

    return Center(child: child);
  }
}

// Loading widget for list items
class ShimmerLoading extends StatelessWidget {
  final int itemCount;
  final bool isGrid;

  const ShimmerLoading({
    Key? key,
    this.itemCount = 5,
    this.isGrid = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isGrid
        ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) => _buildShimmerCard(),
          )
        : ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) => _buildShimmerListItem(),
          );
  }

  Widget _buildShimmerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerListItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Button loading state
class LoadingButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isEnabled;

  const LoadingButton({
    Key? key,
    required this.text,
    required this.isLoading,
    required this.onPressed,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }
}