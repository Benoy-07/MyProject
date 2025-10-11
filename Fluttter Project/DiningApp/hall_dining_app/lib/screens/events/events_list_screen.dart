import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:hall_dining_app/models/event_model.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    Provider.of<EventProvider>(context, listen: false).initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isBengali ? 'ইভেন্টস' : 'Events',
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: languageProvider.isBengali ? 'ইভেন্ট খুঁজুন...' : 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    languageProvider.isBengali ? 'আসন্ন' : 'Upcoming',
                    'upcoming',
                    languageProvider,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    languageProvider.isBengali ? 'সাংস্কৃতিক' : 'Cultural',
                    'cultural',
                    languageProvider,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    languageProvider.isBengali ? 'ফ্রি' : 'Free',
                    'free',
                    languageProvider,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Events List
          Expanded(
            child: eventProvider.isLoading
                ? const LoadingWidget(message: 'Loading events...')
                : eventProvider.error.isNotEmpty
                    ? ErrorWidget(
                        title: 'Error',
                        message: eventProvider.error,
                        buttonText: 'Retry',
                        onRetry: () => eventProvider.refreshEvents(),
                      )
                    : _buildEventsList(eventProvider, languageProvider),
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

  Widget _buildEventsList(EventProvider eventProvider, LanguageProvider languageProvider) {
    List events = eventProvider.events;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      events = eventProvider.searchEvents(_searchQuery);
    }

    // Apply type filter
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'upcoming':
          events = events.where((event) => event.isUpcoming).toList();
          break;
        case 'cultural':
          events = events.where((event) => event.type == EventType.cultural).toList();
          break;
        case 'free':
          events = events.where((event) => event.price == null || event.price == 0).toList();
          break;
      }
    }

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.isBengali ? 'কোন ইভেন্ট নেই' : 'No events found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              languageProvider.isBengali
                  ? 'অনুগ্রহ করে পরে আবার চেক করুন'
                  : 'Please check back later',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: event.imageUrl != null
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(event.imageUrl!),
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.event,
                      color: AppColors.primary,
                    ),
                  ),
            title: Text(event.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(event.startDate)} • ${event.location}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.currentAttendees}/${event.maxAttendees}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      event.priceDisplay,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: event.price == null || event.price == 0
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: event),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}