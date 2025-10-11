import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/utils/validators.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      // Navigation is handled by auth state changes
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Header
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        languageProvider.isBengali ? 'হল ডাইনিং ব্যবস্থাপনা' : 'Hall Dining Management',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageProvider.isBengali ? 'আপনার অ্যাকাউন্টে সাইন ইন করুন' : 'Sign in to your account',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Email Field
                CustomTextField(
                  label: languageProvider.isBengali ? 'ইমেইল' : 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                CustomTextField(
                  label: languageProvider.isBengali ? 'পাসওয়ার্ড' : 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      languageProvider.isBengali ? 'পাসওয়ার্ড ভুলে গেছেন?' : 'Forgot Password?',
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login Button
                // CustomButton(
                //   text: languageProvider.isBengali ? 'সাইন ইন' : 'Sign In',
                //   onPressed: authProvider.isLoading ? null : _login,
                //   isLoading: authProvider.isLoading,
                // ),
                
                const SizedBox(height: 16),
                
                // Google Sign In
                // CustomButton(
                //   text: languageProvider.isBengali ? 'Google দিয়ে সাইন ইন করুন' : 'Sign in with Google',
                //   onPressed: authProvider.isLoading ? null : _loginWithGoogle,
                //   type: ButtonType.outline,
                //   icon: Icons.g_mobiledata,
                // ),
                
                const SizedBox(height: 32),
                
                // Register Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        languageProvider.isBengali ? 'অ্যাকাউন্ট নেই?' : 'Don\'t have an account?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          languageProvider.isBengali ? 'নিবন্ধন করুন' : 'Sign Up',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
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