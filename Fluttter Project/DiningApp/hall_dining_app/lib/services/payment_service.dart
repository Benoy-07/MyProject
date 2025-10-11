import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/payment_model.dart' hide PaymentMethod;
import '../models/booking_model.dart';

class PaymentService {
  static const String _stripeSecretKey = 'your_stripe_secret_key';
  static const String _stripePublishableKey = 'your_stripe_publishable_key';
  static const String _baseUrl = 'https://your-backend.com/api';

  // Initialize Stripe
  static void initializeStripe() {
    Stripe.publishableKey = _stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.flutter.hall_dining';
    Stripe.urlScheme = 'flutterstripe';
  }

  // Process Stripe payment
  static Future<PaymentResult> processStripePayment({
    required double amount,
    required String currency,
    required String bookingId,
    required String userId,
  }) async {
    try {
      // Create payment intent on your server
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: currency,
        bookingId: bookingId,
        userId: userId,
      );

      if (paymentIntent == null) {
        return PaymentResult.error(message: 'Failed to create payment intent');
      }

      // Configure payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Hall Dining Management',
          style: ThemeMode.light,
          // merchantCountryCode: 'BD',
          // testEnv: true, // Set to false in production
        ),
      );

      // Display payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      return PaymentResult.success(
        transactionId: paymentIntent['id'],
        paymentMethod: PaymentMethod.stripe,
      );
    } on StripeException catch (e) {
      return PaymentResult.error(message: _getStripeErrorMessage(e));
    } catch (e) {
      return PaymentResult.error(message: 'Payment failed: $e');
    }
  }

  // Process SSLCommerz payment
  static Future<PaymentResult> processSSLCommerzPayment({
    required double amount,
    required String bookingId,
    required String userId,
    required String customerEmail,
    required String customerPhone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/sslcommerz/initiate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'bookingId': bookingId,
          'userId': userId,
          'customerEmail': customerEmail,
          'customerPhone': customerPhone,
          'currency': 'BDT',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentResult.success(
          transactionId: data['transactionId'],
          paymentMethod: PaymentMethod.sslcommerz,
          gatewayUrl: data['gatewayURL'],
        );
      } else {
        return PaymentResult.error(message: 'Failed to initiate SSLCommerz payment');
      }
    } catch (e) {
      return PaymentResult.error(message: 'SSLCommerz payment failed: $e');
    }
  }

  // Process bKash payment
  static Future<PaymentResult> processBkashPayment({
    required double amount,
    required String bookingId,
    required String userId,
    required String customerPhone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/bkash/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'bookingId': bookingId,
          'userId': userId,
          'customerPhone': customerPhone,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentResult.success(
          transactionId: data['paymentID'],
          paymentMethod: PaymentMethod.bkash,
          paymentInstructions: data['instructions'],
        );
      } else {
        return PaymentResult.error(message: 'Failed to create bKash payment');
      }
    } catch (e) {
      return PaymentResult.error(message: 'bKash payment failed: $e');
    }
  }

  // Process Nagad payment
  static Future<PaymentResult> processNagadPayment({
    required double amount,
    required String bookingId,
    required String userId,
    required String customerPhone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/nagad/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'bookingId': bookingId,
          'userId': userId,
          'customerPhone': customerPhone,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentResult.success(
          transactionId: data['paymentReference'],
          paymentMethod: PaymentMethod.nagad,
          paymentInstructions: data['instructions'],
        );
      } else {
        return PaymentResult.error(message: 'Failed to create Nagad payment');
      }
    } catch (e) {
      return PaymentResult.error(message: 'Nagad payment failed: $e');
    }
  }

  // Verify payment status
  static Future<PaymentStatus> verifyPaymentStatus({
    required String transactionId,
    required PaymentMethod method,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/verify/$transactionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parsePaymentStatus(data['status']);
      } else {
        return PaymentStatus.failed;
      }
    } catch (e) {
      return PaymentStatus.failed;
    }
  }

  // Create payment intent (for Stripe)
  static Future<Map<String, dynamic>?> _createPaymentIntent({
    required double amount,
    required String currency,
    required String bookingId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/stripe/create-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (amount * 100).toInt(), // Convert to cents
          'currency': currency,
          'bookingId': bookingId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Refund payment
  static Future<bool> refundPayment({
    required String paymentId,
    required double amount,
    required PaymentMethod method,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/refund'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paymentId': paymentId,
          'amount': amount,
          'method': method.toString().split('.').last,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Helper method to get Stripe error messages
  static String _getStripeErrorMessage(StripeException e) {
    switch (e.error.code) {
      case FailureCode.Canceled:
        return 'Payment was cancelled';
      case FailureCode.Failed:
        return 'Payment failed';
      case FailureCode.Timeout:
        return 'Payment timeout';
      case FailureCode.InvalidSetupIntent:
        return 'Invalid payment setup';
      default:
        return 'Payment error: ${e.error.message}';
    }
  }

  // Helper method to parse payment status
  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'succeeded':
      case 'completed':
        return PaymentStatus.completed;
      case 'pending':
        return PaymentStatus.pending;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  // Calculate payment amount with tax
  static double calculateTotalAmount(double subtotal, double taxRate) {
    final taxAmount = subtotal * (taxRate / 100);
    return subtotal + taxAmount;
  }

  // Format amount for display
  static String formatAmount(double amount, {String currency = '৳'}) {
    return '$currency${amount.toStringAsFixed(2)}';
  }
}

class PaymentResult {
  final bool success;
  final String? message;
  final String? transactionId;
  final PaymentMethod? paymentMethod;
  final String? gatewayUrl;
  final String? paymentInstructions;

  PaymentResult({
    required this.success,
    this.message,
    this.transactionId,
    this.paymentMethod,
    this.gatewayUrl,
    this.paymentInstructions,
  });

  factory PaymentResult.success({
    String? transactionId,
    PaymentMethod? paymentMethod,
    String? gatewayUrl,
    String? paymentInstructions,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      paymentMethod: paymentMethod,
      gatewayUrl: gatewayUrl,
      paymentInstructions: paymentInstructions,
    );
  }

  factory PaymentResult.error({required String message}) {
    return PaymentResult(success: false, message: message);
  }
}