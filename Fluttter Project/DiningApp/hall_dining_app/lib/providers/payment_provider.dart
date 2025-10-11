import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart' hide PaymentResult;
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Payment> _payments = [];
  List<Payment> _paymentHistory = [];
  Payment? _selectedPayment;
  bool _isProcessing = false;
  String _error = '';
  PaymentMethod _selectedMethod = PaymentMethod.stripe;
  String? _currentTransactionId;

  List<Payment> get payments => _payments;
  List<Payment> get paymentHistory => _paymentHistory;
  Payment? get selectedPayment => _selectedPayment;
  bool get isProcessing => _isProcessing;
  String get error => _error;
  PaymentMethod get selectedMethod => _selectedMethod;
  String? get currentTransactionId => _currentTransactionId;

  // Initialize provider
  void initialize(String userId) {
    _loadUserPayments(userId);
  }

  // Load user payments
  Future<void> _loadUserPayments(String userId) async {
    try {
      _firestoreService.getUserPaymentsStream(userId).listen((payments) {
        _payments = payments;
        _paymentHistory = payments.where((payment) => 
          payment.status == PaymentStatus.completed || 
          payment.status == PaymentStatus.failed
        ).toList();
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to load payments: $e';
      notifyListeners();
    }
  }

  // Process payment
  Future<PaymentResult> processPayment({
    required double amount,
    required String bookingId,
    required String userId,
    required String userEmail,
    required String userPhone,
    PaymentMethod method = PaymentMethod.stripe,
  }) async {
    _isProcessing = true;
    _error = '';
    _currentTransactionId = null;
    notifyListeners();

    try {
      PaymentResult result;

      switch (method) {
        case PaymentMethod.stripe:
          result = (await PaymentService.processStripePayment(
            amount: amount,
            currency: 'bdt',
            bookingId: bookingId,
            userId: userId,
          )) as PaymentResult;
          break;

        case PaymentMethod.sslcommerz:
          result = (await PaymentService.processSSLCommerzPayment(
            amount: amount,
            bookingId: bookingId,
            userId: userId,
            customerEmail: userEmail,
            customerPhone: userPhone,
          )) as PaymentResult;
          break;

        case PaymentMethod.bkash:
          result = (await PaymentService.processBkashPayment(
            amount: amount,
            bookingId: bookingId,
            userId: userId,
            customerPhone: userPhone,
          )) as PaymentResult;
          break;

        case PaymentMethod.nagad:
          result = (await PaymentService.processNagadPayment(
            amount: amount,
            bookingId: bookingId,
            userId: userId,
            customerPhone: userPhone,
          )) as PaymentResult;
          break;

        default:
          result = PaymentResult(
            success: false,
            status: PaymentStatus.failed,
            errorMessage: 'Payment method not supported',
          );
      }

      _isProcessing = false;

      if (result.success) {
        _currentTransactionId = result.transactionId;
        
        // Create payment record
        final payment = Payment(
          id: '', // Will be set by Firestore
          userId: userId,
          bookingId: bookingId,
          amount: amount,
          method: method,
          status: PaymentStatus.completed,
          transactionId: result.transactionId,
          paymentDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final paymentId = await _firestoreService.createPayment(payment);
        
        // Send notification
        await NotificationService.sendPaymentConfirmation(
          userId: userId,
          paymentId: paymentId,
          amount: amount,
        );

        notifyListeners();
        return PaymentResult(
          success: true,
          transactionId: result.transactionId,
          status: PaymentStatus.completed,
        );
      } else {
        _error = result.errorMessage ?? 'Payment failed';
        
        // Create failed payment record
        final payment = Payment(
          id: '', // Will be set by Firestore
          userId: userId,
          bookingId: bookingId,
          amount: amount,
          method: method,
          status: PaymentStatus.failed,
          failureReason: result.errorMessage,
          paymentDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await _firestoreService.createPayment(payment);
        
        notifyListeners();
        return PaymentResult(
          success: false,
          status: PaymentStatus.failed,
          errorMessage: _error,
        );
      }
    } catch (e) {
      _isProcessing = false;
      _error = 'Payment processing failed: $e';
      notifyListeners();
      return PaymentResult(
        success: false,
        status: PaymentStatus.failed,
        errorMessage: _error,
      );
    }
  }

  // Verify payment status
  Future<PaymentStatus> verifyPaymentStatus(String transactionId, PaymentMethod method) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final status = await PaymentService.verifyPaymentStatus(
        transactionId: transactionId,
        method: method,
      );

      _isProcessing = false;
      notifyListeners();
      return status;
    } catch (e) {
      _isProcessing = false;
      _error = 'Failed to verify payment: $e';
      notifyListeners();
      return PaymentStatus.failed;
    }
  }

  // Refund payment
  Future<bool> refundPayment(String paymentId, double amount) async {
    _isProcessing = true;
    _error = '';
    notifyListeners();

    try {
      // Get payment details
      final payment = _payments.firstWhere((p) => p.id == paymentId);
      
      final success = await PaymentService.refundPayment(
        paymentId: paymentId,
        amount: amount,
        method: payment.method,
      );

      _isProcessing = false;

      if (success) {
        // Update payment status
        await _firestoreService.updatePaymentStatus(
          paymentId, 
          amount == payment.amount ? PaymentStatus.refunded : PaymentStatus.partiallyRefunded
        );
        notifyListeners();
        return true;
      } else {
        _error = 'Refund failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isProcessing = false;
      _error = 'Refund failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Set selected payment method
  void setSelectedMethod(PaymentMethod method) {
    _selectedMethod = method;
    notifyListeners();
  }

  // Set selected payment
  void setSelectedPayment(Payment payment) {
    _selectedPayment = payment;
    notifyListeners();
  }

  // Clear selected payment
  void clearSelectedPayment() {
    _selectedPayment = null;
    notifyListeners();
  }

  // Get payments by status
  List<Payment> getPaymentsByStatus(PaymentStatus status) {
    return _payments.where((payment) => payment.status == status).toList();
  }

  // Get payments by date range
  List<Payment> getPaymentsByDateRange(DateTime startDate, DateTime endDate) {
    return _payments.where((payment) =>
      payment.paymentDate.isAfter(startDate) &&
      payment.paymentDate.isBefore(endDate)
    ).toList();
  }

  // Get total revenue
  double getTotalRevenue() {
    return _payments
        .where((payment) => payment.status == PaymentStatus.completed)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get today's revenue
  double getTodaysRevenue() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return _payments
        .where((payment) =>
          payment.status == PaymentStatus.completed &&
          payment.paymentDate.isAfter(todayStart) &&
          payment.paymentDate.isBefore(todayEnd))
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get payment statistics
  Map<String, dynamic> getPaymentStats() {
    final totalPayments = _payments.length;
    final completedPayments = _payments.where((p) => p.status == PaymentStatus.completed).length;
    final failedPayments = _payments.where((p) => p.status == PaymentStatus.failed).length;
    final pendingPayments = _payments.where((p) => p.status == PaymentStatus.pending).length;
    
    final totalRevenue = getTotalRevenue();
    final successRate = totalPayments > 0 ? (completedPayments / totalPayments) * 100 : 0;
    
    final methodDistribution = <String, int>{};
    for (final payment in _payments) {
      final method = payment.displayMethod;
      methodDistribution[method] = (methodDistribution[method] ?? 0) + 1;
    }
    
    return {
      'totalPayments': totalPayments,
      'completedPayments': completedPayments,
      'failedPayments': failedPayments,
      'pendingPayments': pendingPayments,
      'totalRevenue': totalRevenue,
      'successRate': successRate,
      'methodDistribution': methodDistribution,
    };
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Clear current transaction
  void clearCurrentTransaction() {
    _currentTransactionId = null;
    notifyListeners();
  }

  // Refresh payments
  Future<void> refreshPayments(String userId) async {
    _loadUserPayments(userId);
  }
}