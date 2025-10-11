import 'package:intl/intl.dart';

class DateFormatter {
  // Format date to display (e.g., "12 Dec 2023")
  static String formatDisplayDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  // Format date with time (e.g., "12 Dec 2023, 10:30 AM")
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
  
  // Format time only (e.g., "10:30 AM")
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
  
  // Format date for API (e.g., "2023-12-12")
  static String formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Format date for display with day (e.g., "Monday, 12 Dec 2023")
  static String formatDateWithDay(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy').format(date);
  }
  
  // Format relative time (e.g., "2 hours ago", "Yesterday")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return formatDisplayDate(date);
    }
  }
  
  // Format meal time based on time of day
  static String formatMealTime(DateTime date) {
    final hour = date.hour;
    
    if (hour < 12) {
      return 'Breakfast';
    } else if (hour < 17) {
      return 'Lunch';
    } else {
      return 'Dinner';
    }
  }
  
  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
  
  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }
  
  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }
  
  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  // Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  // Parse date from string
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}