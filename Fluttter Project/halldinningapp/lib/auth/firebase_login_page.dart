// firebase_login_page.dart
import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import '../services/prefs_service.dart';
import 'firebase_signup_page.dart';
import '../admin/admin_dashboard.dart'; // Import your Admin Dashboard
// import 'your_home_page.dart'; // Replace with your actual HomePage path if needed

class FirebaseLoginPage extends StatefulWidget {
  const FirebaseLoginPage({super.key});

  @override
  State<FirebaseLoginPage> createState() => _FirebaseLoginPageState();
}

class _FirebaseLoginPageState extends State<FirebaseLoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;

  // Admin Credentials (You can move this to secure storage later if needed)
  final String _adminEmail = "admin@gmail.com";
  final String _adminPassword = "admin123";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }
    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email');
      return;
    }
    if (password.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Special Case: Admin Login (Hardcoded for simplicity & security in demo)
      if (email == _adminEmail && password == _adminPassword) {
        await PrefsService.setBool('user_logged_in', true);
        await PrefsService.setBool('is_admin', true); // Optional: mark as admin

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/admin-dashboard', // Make sure this route is added in main.dart
            (route) => false,
          );
        }
        return;
      }

      // Regular User Login via Firebase Auth
      await FirebaseAuthService.loginWithEmail(email, password);

      bool isVerified = FirebaseAuthService.isEmailVerified();

      if (!isVerified) {
        if (mounted) {
          _showInfo('Please verify your email first');
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pushNamed(
              context,
              '/email-verification',
              arguments: email,
            );
          }
        }
        return;
      }

      // Normal User - Logged in successfully
      if (mounted) {
        await PrefsService.setBool('user_logged_in', true);
        await PrefsService.setBool('is_admin', false);

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/firebase-home', // Your regular user homepage
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed';
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'No account found with this email';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Incorrect password';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Invalid email address';
        } else if (e.toString().contains('user-disabled')) {
          errorMessage = 'This account has been disabled';
        }
        _showError(errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: const Duration(seconds: 3),
      ),
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
              Colors.blue.shade300,
              Colors.cyan.shade400,
              Colors.teal.shade600,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
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
                            Icons.lock_person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  ScaleTransition(
                    scale: Tween(begin: 0.5, end: 1.0).animate(
                      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                    ),
                    child: const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: Tween(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                      ),
                    ),
                    child: Text(
                      'Sign in to your account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email Address',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _showInfo('Password reset coming soon');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildLoginButton(),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const FirebaseSignupPage()),
                          );
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Rest of your beautiful UI methods remain unchanged
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        cursorColor: Colors.white,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _hidePassword,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _hidePassword = !_hidePassword),
            child: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        cursorColor: Colors.white,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: [Colors.cyan.shade400, Colors.teal.shade600]),
          boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: _isLoading ? null : _login,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}