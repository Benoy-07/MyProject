import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _numberOfGuests = 1;
  final _specialRequirementsController = TextEditingController();

  @override
  void dispose() {
    _specialRequirementsController.dispose();
    super.dispose();
  }

  Future<void> _bookEvent() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final result = await eventProvider.bookEvent(
      eventId: widget.event.id,
      userId: authProvider.user!.uid,
      userName: authProvider.user!.name,
      userEmail: authProvider.user!.email!,
      numberOfGuests: _numberOfGuests,
      paymentMethod: PaymentMethod.stripe,
      specialRequirements: _specialRequirementsController.text.isNotEmpty
          ? _specialRequirementsController.text
          : null,
    );

    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.isBengali
                  ? 'ইভেন্ট সফলভাবে বুক করা হয়েছে!'
                  : 'Event booked successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to book event'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    final hasUserBooked = eventProvider.hasUserBookedEvent(widget.event.id, authProvider.user?.uid ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            if (widget.event.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(widget.event.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),

            const SizedBox(height: 16),

            // Event Title and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  widget.event.priceDisplay,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Event Date and Time
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(widget.event.startDate)} - ${_formatDate(widget.event.endDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Event Location
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  widget.event.location,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Event Description
            Text(
              widget.event.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // Event Type and Attendees
            Row(
              children: [
                Chip(
                  label: Text(widget.event.displayType),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
                const Spacer(),
                Text(
                  '${widget.event.currentAttendees}/${widget.event.maxAttendees} ${languageProvider.isBengali ? 'অংশগ্রহণকারী' : 'attendees'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Special Menu
            if (widget.event.specialMenu.isNotEmpty) ...[
              Text(
                languageProvider.isBengali ? 'বিশেষ মেনু' : 'Special Menu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.event.specialMenu.map((menuItem) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(menuItem.name),
                  subtitle: Text(menuItem.description),
                  trailing: menuItem.price != null
                      ? Text('৳${menuItem.price!.toStringAsFixed(2)}')
                      : null,
                ),
              )).toList(),
              const SizedBox(height: 24),
            ],

            // Booking Section
            if (widget.event.requiresBooking && widget.event.canBook && !hasUserBooked) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageProvider.isBengali ? 'ইভেন্ট বুকিং' : 'Event Booking',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Number of Guests
                      Text(
                        languageProvider.isBengali ? 'অতিথির সংখ্যা' : 'Number of Guests',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _numberOfGuests > 1
                                ? () {
                                    setState(() {
                                      _numberOfGuests--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            '$_numberOfGuests',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _numberOfGuests < widget.event.availableSpots
                                ? () {
                                    setState(() {
                                      _numberOfGuests++;
                                    });
                                  }
                                : null,
                          ),
                          const Spacer(),
                          Text(
                            '${languageProvider.isBengali ? 'সর্বোচ্চ' : 'Max'}: ${widget.event.availableSpots}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Special Requirements
                      TextField(
                        controller: _specialRequirementsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: languageProvider.isBengali
                              ? 'কোন বিশেষ প্রয়োজনীয়তা...'
                              : 'Any special requirements...',
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Total Amount
                      if (widget.event.price != null && widget.event.price! > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languageProvider.isBengali ? 'মোট Amount' : 'Total Amount',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '৳${(widget.event.price! * _numberOfGuests).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Book Button
                      // CustomButton(
                      //   text: languageProvider.isBengali ? 'ইভেন্ট বুক করুন' : 'Book Event',
                      //   onPressed: eventProvider.isLoading ? null : _bookEvent,
                      //   isLoading: eventProvider.isLoading,
                      // ),
                    ],
                  ),
                ),
              ),
            ] else if (hasUserBooked) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      languageProvider.isBengali
                          ? 'আপনি ইতিমধ্যেই এই ইভেন্টের জন্য বুক করেছেন'
                          : 'You have already booked this event',
                      style: TextStyle(color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ] else if (!widget.event.canBook) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        languageProvider.isBengali
                            ? 'এই ইভেন্ট বুক করা যাবে না'
                            : 'This event cannot be booked',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}