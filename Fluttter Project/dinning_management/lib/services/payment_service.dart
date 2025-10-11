class PaymentService {
  /// Mock payment — return success after "processing".
  Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String currency,
    required String method,
  }) async {
    // insert real payment SDK logic here (Stripe / Flutterwave / etc.)
    await Future.delayed(Duration(seconds: 2));
    return {
      'status': 'success',
      'transactionId': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'currency': currency,
    };
  }
}
