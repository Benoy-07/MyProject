import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/utils/validators.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hallController = TextEditingController();
  final _roomController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'student';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _hallController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole,
      phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      hall: _hallController.text.trim().isNotEmpty ? _hallController.text.trim() : null,
      roomNumber: _roomController.text.trim().isNotEmpty ? _roomController.text.trim() : null,
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
                
                const SizedBox(height: 20),
                
                // Header
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 60,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        languageProvider.isBengali ? 'নতুন অ্যাকাউন্ট তৈরি করুন' : 'Create New Account',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageProvider.isBengali ? 'আপনার তথ্য দিয়ে নিবন্ধন করুন' : 'Register with your information',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Name Field
                CustomTextField(
                  label: languageProvider.isBengali ? 'পুরো নাম' : 'Full Name',
                  controller: _nameController,
                  validator: (value) => Validators.validateName(value),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                
                const SizedBox(height: 16),
                
                // Email Field
                CustomTextField(
                  label: languageProvider.isBengali ? 'ইমেইল' : 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                
                const SizedBox(height: 16),
                
                // Phone Field
                CustomTextField(
                  label: languageProvider.isBengali ? 'ফোন নম্বর' : 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) => Validators.validatePhone(value),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                
                const SizedBox(height: 16),
                
                // Role Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.isBengali ? 'ভূমিকা' : 'Role',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: [
                        DropdownMenuItem(
                          value: 'student',
                          child: Text(languageProvider.isBengali ? 'ছাত্র' : 'Student'),
                        ),
                        DropdownMenuItem(
                          value: 'staff',
                          child: Text(languageProvider.isBengali ? 'স্টাফ' : 'Staff'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Hall Field
                CustomTextField(
                  label: languageProvider.isBengali ? 'হল' : 'Hall',
                  controller: _hallController,
                  prefixIcon: const Icon(Icons.home_outlined),
                ),
                
                const SizedBox(height: 16),
                
                // Room Field
                CustomTextField(
                  label: languageProvider.isBengali ? 'রুম নম্বর' : 'Room Number',
                  controller: _roomController,
                  prefixIcon: const Icon(Icons.meeting_room_outlined),
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
                
                const SizedBox(height: 16),
                
                // Confirm Password Field
                CustomTextField(
                  label: languageProvider.isBengali ? 'পাসওয়ার্ড নিশ্চিত করুন' : 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Register Button
                // CustomButton(
                //   text: languageProvider.isBengali ? 'নিবন্ধন করুন' : 'Sign Up',
                //  // onPressed: authProvider.isLoading ? null : _register,
                //   isLoading: authProvider.isLoading,
                // ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        languageProvider.isBengali ? 'ইতিমধ্যে একটি অ্যাকাউন্ট আছে?' : 'Already have an account?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          languageProvider.isBengali ? 'সাইন ইন' : 'Sign In',
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