import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:hall_dining_app/models/feedback_model.dart';
import 'package:hall_dining_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<FeedbackProvider>(context, listen: false).initialize(authProvider.user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = Provider.of<FeedbackProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isBengali ? 'আমার ফিডব্যাক' : 'My Feedback',
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    languageProvider.isBengali ? 'সব' : 'All',
                    'all',
                    languageProvider,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    languageProvider.isBengali ? 'মেনু আইটেম' : 'Menu Items',
                    'menu_item',
                    languageProvider,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    languageProvider.isBengali ? 'সেবা' : 'Service',
                    'service',
                    languageProvider,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    languageProvider.isBengali ? 'সমাধান' : 'Resolved',
                    'resolved',
                    languageProvider,
                  ),
                ],
              ),
            ),
          ),

          // Feedback List
          Expanded(
            child: feedbackProvider.isLoading
                ? const LoadingWidget(message: 'Loading feedback...')
                : feedbackProvider.error.isNotEmpty
                    ? ErrorWidget(
                        title: 'Error',
                        message: feedbackProvider.error,
                        buttonText: 'Retry',
                        onRetry: () {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          feedbackProvider.refreshFeedback(authProvider.user!.uid);
                        },
                      )
                    : _buildFeedbackList(feedbackProvider, languageProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, LanguageProvider languageProvider) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: _selectedFilter == value ? Colors.white : null,
      ),
    );
  }

  Widget _buildFeedbackList(FeedbackProvider feedbackProvider, LanguageProvider languageProvider) {
    List feedbacks = feedbackProvider.userFeedback;

    // Apply filters
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'menu_item':
          feedbacks = feedbacks.where((f) => f.type == FeedbackType.menuItem).toList();
          break;
        case 'service':
          feedbacks = feedbacks.where((f) => f.type == FeedbackType.service).toList();
          break;
        case 'resolved':
          feedbacks = feedbacks.where((f) => f.isResolved).toList();
          break;
      }
    }

    if (feedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feedback_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.isBengali ? 'কোন ফিডব্যাক নেই' : 'No feedback found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              languageProvider.isBengali
                  ? 'আপনার প্রথম ফিডব্যাক জমা দিন'
                  : 'Submit your first feedback',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: feedbacks.length,
      itemBuilder: (context, index) {
        final feedback = feedbacks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: _getTypeIcon(feedback.type),
            title: Text(feedback.comment),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (starIndex) => Icon(
                        Icons.star,
                        size: 16,
                        color: starIndex < feedback.rating ? Colors.amber : Colors.grey,
                      )),
                ),
                const SizedBox(height: 4),
                Text(
                  '${feedback.displayType} • ${_formatDate(feedback.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (feedback.hasAdminResponse) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${languageProvider.isBengali ? 'প্রশাসনের উত্তর' : 'Admin Response'}: ${feedback.adminResponse}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Chip(
              label: Text(
                feedback.displayStatus,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: _getStatusColor(feedback.status),
            ),
          ),
        );
      },
    );
  }

  Icon _getTypeIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.menuItem:
        return const Icon(Icons.restaurant, color: Colors.orange);
      case FeedbackType.service:
        return const Icon(Icons.room_service, color: Colors.blue);
      case FeedbackType.facility:
        return const Icon(Icons.business, color: Colors.green);
      case FeedbackType.staff:
        return const Icon(Icons.people, color: Colors.purple);
      case FeedbackType.general:
        return const Icon(Icons.chat, color: Colors.grey);
    }
  }

  Color _getStatusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return Colors.orange;
      case FeedbackStatus.reviewed:
        return Colors.blue;
      case FeedbackStatus.resolved:
        return Colors.green;
      case FeedbackStatus.closed:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}