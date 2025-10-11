import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/utils/validators.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(_emailController.text.trim());

    if (success) {
      setState(() {
        _isEmailSent = true;
      });
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
                const SizedBox(height: 20),
                
                // Back Button
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                
                const SizedBox(height: 40),
                
                // Header
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        languageProvider.isBengali ? 'পাসওয়ার্ড রিসেট' : 'Reset Password',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageProvider.isBengali 
                            ? 'পাসওয়ার্ড রিসেট লিঙ্ক পেতে আপনার ইমেইল দিন'
                            : 'Enter your email to receive a password reset link',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                if (!_isEmailSent) ...[
                  // Email Field
                  CustomTextField(
                    label: languageProvider.isBengali ? 'ইমেইল' : 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Reset Button
                  // CustomButton(
                  //   text: languageProvider.isBengali ? 'রিসেট লিঙ্ক পাঠান' : 'Send Reset Link',
                  //   onPressed: authProvider.isLoading ? null : () => _resetPassword(),
                  //   isLoading: authProvider.isLoading,
                  // ),
                ] else ...[
                  // Success Message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 48,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          languageProvider.isBengali ? 'ইমেইল পাঠানো হয়েছে!' : 'Email Sent!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          languageProvider.isBengali
                              ? 'আমরা আপনার ইমেইলে একটি পাসওয়ার্ড রিসেট লিঙ্ক পাঠিয়েছি। আপনার ইমেইল চেক করুন।'
                              : 'We have sent a password reset link to your email. Please check your inbox.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Back to Login Button
                  CustomButton(
                    text: languageProvider.isBengali ? 'লগইনে ফিরে যান' : 'Back to Login',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}