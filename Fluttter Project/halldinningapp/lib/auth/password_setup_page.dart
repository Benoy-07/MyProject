// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';

class PasswordSetupPage extends StatefulWidget {
  final String email;

  const PasswordSetupPage({
    super.key,
    required this.email,
  });

  @override
  State<PasswordSetupPage> createState() => _PasswordSetupPageState();
}

class _PasswordSetupPageState extends State<PasswordSetupPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _passwordStrength = '';
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      int strengthCount = [
        _hasMinLength,
        _hasUpperCase,
        _hasLowerCase,
        _hasNumber,
        _hasSpecialChar,
      ].where((element) => element).length;

      if (strengthCount < 3) {
        _passwordStrength = 'Weak';
      } else if (strengthCount < 5) {
        _passwordStrength = 'Good';
      } else {
        _passwordStrength = 'Strong';
      }
    });
  }

  void _completeSignup() async {
    if (_passwordController.text.isEmpty) {
      _showError('Please enter password');
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _showError('Please confirm password');
      return;
    }

    final auth = context.read<AuthService>();

    if (!auth.isStrongPassword(_passwordController.text)) {
      _showError('Password does not meet security requirements');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      var pendingUser = auth.getPendingUser(widget.email);
      if (pendingUser != null) {
        // Update stored pending user with password collected in this step
        auth.storePendingUser(widget.email, pendingUser['firstName'] ?? '', password: _passwordController.text);

        bool success = await auth.completeSignup(email: widget.email, password: _passwordController.text, firstName: pendingUser['firstName'] ?? '', hall: pendingUser['hall'] ?? '', phone: pendingUser['phone'] ?? '');

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signup Successful! 🎉'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to login page
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _passwordRequirement(bool isMet, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet ? Colors.green : Colors.grey.shade300,
          ),
          child: Icon(
            isMet ? Icons.check : Icons.close,
            size: 12,
            color: isMet ? Colors.white : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isMet ? Colors.green : Colors.grey.shade600,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.purple.shade600],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  const Text(
                    'Create Password',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Step 3: Set a Strong Password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Password Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Password Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      onChanged: _checkPasswordStrength,
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(
                              () =>
                                  _isPasswordVisible = !_isPasswordVisible,
                            );
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Strength Indicator
                  if (_passwordController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Password Strength',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _passwordStrength == 'Strong'
                                      ? Colors.green
                                      : _passwordStrength == 'Good'
                                          ? Colors.orange
                                          : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _passwordStrength,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _passwordRequirement(
                            _hasMinLength,
                            'At least 8 characters',
                          ),
                          const SizedBox(height: 8),
                          _passwordRequirement(
                            _hasUpperCase,
                            'At least one uppercase letter (A-Z)',
                          ),
                          const SizedBox(height: 8),
                          _passwordRequirement(
                            _hasLowerCase,
                            'At least one lowercase letter (a-z)',
                          ),
                          const SizedBox(height: 8),
                          _passwordRequirement(
                            _hasNumber,
                            'At least one number (0-9)',
                          ),
                          const SizedBox(height: 8),
                          _passwordRequirement(
                            _hasSpecialChar,
                            'At least one special character (!@#\$%^&*)',
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Confirm Password Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(
                              () => _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible,
                            );
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Complete Signup Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.shade400,
                          Colors.indigo.shade600,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _completeSignup,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Complete Signup',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
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
}
