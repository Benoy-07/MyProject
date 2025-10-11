import 'package:flutter/material.dart';
import 'package:hall_dining_app/models/booking_model.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../core/widgets/custom_button.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  String _filterStatus = 'all';
  String _filterMealType = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadAllBookings();
    });
  }

  List<Booking> _getFilteredBookings(List<Booking> bookings) {
    return bookings.where((booking) {
      final statusMatch = _filterStatus == 'all' || booking.status.name == _filterStatus;
      final mealTypeMatch = _filterMealType == 'all' || booking.mealType == _filterMealType;
      return statusMatch && mealTypeMatch;
    }).toList();
  }

  void _updateBookingStatus(Booking booking, String newStatus) {
    final status = BookingStatus.values.firstWhere(
      (e) => e.name == newStatus,
      orElse: () => BookingStatus.pending,
    );
    Provider.of<BookingProvider>(context, listen: false)
        .updateBookingStatus(booking.id, status);
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User', booking.userName),
              _buildDetailRow('Meal Type', booking.mealType.toUpperCase()),
              _buildDetailRow('Date', _formatDate(booking.bookingDate)),
              _buildDetailRow('Time', _getMealTime(booking.mealType)),
              _buildDetailRow('Status', booking.status.name.toUpperCase()),
              _buildDetailRow('Total Amount', '৳${booking.totalAmount}'),
              const SizedBox(height: 16),
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...booking.items.map((item) => Text('• ${item.menuItemName} - ৳${item.unitPrice}')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final filteredBookings = _getFilteredBookings(bookingProvider.bookings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              bookingProvider.loadAllBookings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Filters:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      // Status Filter
                      DropdownButton<String>(
                        value: _filterStatus,
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All Status')),
                          ...BookingStatus.values.map((status) => DropdownMenuItem(
                                value: status.name,
                                child: Text(status.name[0].toUpperCase() + status.name.substring(1)),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() => _filterStatus = value!);
                        },
                      ),
                      const SizedBox(width: 16),
                      // Meal Type Filter
                      DropdownButton<String>(
                        value: _filterMealType,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Meals')),
                          DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                          DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                          DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                        ],
                        onChanged: (value) {
                          setState(() => _filterMealType = value!);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Showing ${filteredBookings.length} bookings',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Bookings List
          Expanded(
            child: bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBookings.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No bookings found'),
                            Text('Try changing your filters'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _getMealTypeColor(booking.mealType).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getMealIcon(booking.mealType),
                                  color: _getMealTypeColor(booking.mealType),
                                ),
                              ),
                              title: Text(booking.userName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${booking.mealType.toUpperCase()} • ${_formatDate(booking.bookingDate)}'),
                                  Text('${booking.items.length} items • ৳${booking.totalAmount}'),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(
                                      booking.status.name.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                    backgroundColor: _getStatusColor(booking.status),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => _buildPopupMenuItems(booking.status),
                                onSelected: (value) {
                                  _handlePopupAction(booking, value as String);
                                },
                              ),
                              onTap: () {
                                _showBookingDetails(booking);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuItem<String>> _buildPopupMenuItems(BookingStatus currentStatus) {
    final items = <PopupMenuItem<String>>[];

    if (currentStatus == BookingStatus.pending) {
      items.addAll([
        const PopupMenuItem(
          value: 'confirmed',
          child: ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Confirm'),
          ),
        ),
        const PopupMenuItem(
          value: 'cancelled',
          child: ListTile(
            leading: Icon(Icons.cancel, color: Colors.red),
            title: Text('Cancel'),
          ),
        ),
      ]);
    }

    if (currentStatus == BookingStatus.confirmed) {
      items.addAll([
        const PopupMenuItem(
          value: 'completed',
          child: ListTile(
            leading: Icon(Icons.done_all, color: Colors.blue),
            title: Text('Mark Complete'),
          ),
        ),
        const PopupMenuItem(
          value: 'cancelled',
          child: ListTile(
            leading: Icon(Icons.cancel, color: Colors.red),
            title: Text('Cancel'),
          ),
        ),
      ]);
    }

    items.add(const PopupMenuItem(
      value: 'details',
      child: ListTile(
        leading: Icon(Icons.info),
        title: Text('View Details'),
      ),
    ));

    return items;
  }

  void _handlePopupAction(Booking booking, String action) {
    switch (action) {
      case 'confirmed':
        _updateBookingStatus(booking, 'confirmed');
        break;
      case 'cancelled':
        _updateBookingStatus(booking, 'cancelled');
        break;
      case 'completed':
        _updateBookingStatus(booking, 'completed');
        break;
      case 'details':
        _showBookingDetails(booking);
        break;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.preparing:
        return Colors.blueAccent;
      case BookingStatus.ready:
        return Colors.teal;
      case BookingStatus.expired:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMealTime(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return '8:00 AM - 10:00 AM';
      case 'lunch':
        return '12:00 PM - 2:00 PM';
      case 'dinner':
        return '7:00 PM - 9:00 PM';
      default:
        return 'TBD';
    }
  }
}