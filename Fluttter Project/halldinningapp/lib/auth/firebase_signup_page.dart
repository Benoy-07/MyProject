// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_auth_service.dart';
import '../firebase_options.dart';

class FirebaseSignupPage extends StatefulWidget {
  const FirebaseSignupPage({super.key});

  @override
  State<FirebaseSignupPage> createState() => _FirebaseSignupPageState();
}

class _FirebaseSignupPageState extends State<FirebaseSignupPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;

  String _passwordStrength = '';
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
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

  void _signup() async {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }
    // Validation
    if (_emailController.text.isEmpty) {
      _showError('Please enter email');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      _showError('Please enter valid email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Please enter password');
      return;
    }

    if (!_isStrongPassword(_passwordController.text)) {
      _showError('Password does not meet security requirements');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Firebase signup
      var user = await FirebaseAuthService.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null && mounted) {
        // Update displayName on Firebase user and Firestore users doc
        try {
          await FirebaseAuthService.updateProfile(displayName: _nameController.text.trim());
          // Update Firestore user document name (merge)
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': _nameController.text.trim(),
            'email': user.email ?? _emailController.text.trim(),
          }, SetOptions(merge: true));
        } catch (e) {
          // non-fatal: continue but log
          debugPrint('Failed to update user displayName/doc: $e');
        }

        _showSuccess('Account created! Check your email for verification.');

        // Navigate to verification page
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/email-verification',
            arguments: _emailController.text,
          );
        }
        return;
      }

      // If we get here, signup returned null — show helpful message
      if (mounted) {
        String message = 'Signup failed. Please check the console for details.';
        try {
          if (kIsWeb) {
              final proj = DefaultFirebaseOptions.currentPlatform.projectId;
              if (proj.contains('demo') || proj.contains('YOUR_PROJECT_ID') || proj.isEmpty) {
                message = 'Firebase web config not set. Open lib/firebase_options.dart and paste your web config.';
              }
            }
        } catch (_) {}
        _showError(message);
      }
    } catch (e) {
      if (mounted) {
        // Provide friendlier, actionable messages for common web issues
        final err = e.toString();
        if (err.contains('JavaScriptObject') || err.contains('TypeError')) {
          _showError('Signup failed (web interop). Check Firebase web config and enable Email/Password sign-in.');
        } else {
          _showError('Signup failed: $e');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    return _hasMinLength &&
        _hasUpperCase &&
        _hasLowerCase &&
        _hasNumber &&
        _hasSpecialChar;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
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
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
              Colors.purple.shade600,
              Colors.pink.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
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
                            Icons.person_add,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign up with Email & Password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  // Name Field
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 18),
                  // Password Field
                  Container(
                    decoration: BoxDecoration(
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
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      onChanged: _checkPasswordStrength,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 12),
                          child: Icon(Icons.lock_outline,
                              color: Colors.blue.shade600, size: 24),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blue.shade600,
                          ),
                          onPressed: () {
                            setState(() =>
                                _isPasswordVisible = !_isPasswordVisible);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password Strength
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
                          _passwordRequirement(_hasMinLength, '8+ characters'),
                          const SizedBox(height: 8),
                          _passwordRequirement(_hasUpperCase, 'Uppercase (A-Z)'),
                          const SizedBox(height: 8),
                          _passwordRequirement(_hasLowerCase, 'Lowercase (a-z)'),
                          const SizedBox(height: 8),
                          _passwordRequirement(_hasNumber, 'Number (0-9)'),
                          const SizedBox(height: 8),
                          _passwordRequirement(
                              _hasSpecialChar, 'Special char (!@#\$%)'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Confirm Password
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscureText: !_isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.blue.shade600,
                      ),
                      onPressed: () {
                        setState(() => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Signup Button
                  _buildButton(
                    onPressed: _isLoading ? null : _signup,
                    isLoading: _isLoading,
                    text: 'Sign Up',
                    color1: Colors.orange.shade400,
                    color2: Colors.orange.shade600,
                  ),
                  const SizedBox(height: 20),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have account? ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/firebase-login'),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
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
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, color: Colors.blue.shade600, size: 24),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      const Icon(Icons.person_add,
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
