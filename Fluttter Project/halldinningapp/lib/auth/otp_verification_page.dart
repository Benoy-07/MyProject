// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;

  const OTPVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  int _resendCounter = 60;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
    _startTimer();
  }

  void _startTimer() {
    _resendCounter = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _resendCounter--);
      }
      return _resendCounter > 0;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      _showSnackbar('Please enter OTP', Colors.red);
      return;
    }

    if (_otpController.text.length != 6) {
      _showSnackbar('OTP must be 6 digits', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthService>();
      bool isValid = auth.verifyOTP(widget.email, _otpController.text);

      if (isValid && mounted) {
        _showSnackbar('OTP Verified! ✓', Colors.green);

        // Navigate to password setup page
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/password',
            arguments: widget.email,
          );
        }
      } else if (mounted) {
        _showSnackbar('Invalid OTP. Please try again.', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resendOTP() async {
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthService>();
      bool success = await auth.sendOTPEmail(widget.email);

      if (success && mounted) {
        _showSnackbar('OTP resent! Check your email', Colors.green);
        _startTimer();
        _otpController.clear();
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color.withOpacity(0.8),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verify Email',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade400,
              Colors.purple.shade600,
              Colors.indigo.shade600,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Animated Icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mark_email_read_outlined,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  // Header
                  const Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Step 2 of 3',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Email Display
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mail, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.email,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // OTP Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 12,
                        color: Colors.purple,
                      ),
                      decoration: InputDecoration(
                        hintText: '000000',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 32,
                          letterSpacing: 12,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 20),
                      ),
                      onChanged: (value) {
                        if (value.length == 6) {
                          // Auto verify when 6 digits entered
                          _verifyOTP();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter 6-digit OTP sent to your email',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Verify Button
                  _buildButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    isLoading: _isLoading,
                    text: 'Verify OTP',
                    color1: Colors.green.shade400,
                    color2: Colors.green.shade600,
                  ),
                  const SizedBox(height: 20),
                  // Resend Section
                  if (_resendCounter > 0)
                    Text(
                      'Resend OTP in $_resendCounter seconds',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _resendOTP,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Resend OTP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String text,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
