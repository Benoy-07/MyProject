import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/utils/validators.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hallController = TextEditingController();
  final _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber ?? '';
      _hallController.text = user.hall ?? '';
      _roomController.text = user.roomNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _hallController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      hall: _hallController.text.trim().isNotEmpty ? _hallController.text.trim() : null,
      roomNumber: _roomController.text.trim().isNotEmpty ? _roomController.text.trim() : null,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageProvider>(context, listen: false).isBengali
                  ? 'প্রোফাইল আপডেট করা হয়েছে'
                  : 'Profile updated successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
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

  Future<void> _updateProfilePicture() async {
    // Implement profile picture update logic
    // You can use image_picker to select an image
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isBengali ? 'প্রোফাইল সম্পাদনা' : 'Edit Profile',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _updateProfilePicture,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: authProvider.user?.profileImage != null
                          ? NetworkImage(authProvider.user!.profileImage!)
                          : null,
                      child: authProvider.user?.profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                      backgroundColor: AppColors.primary,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Name Field
              CustomTextField(
                label: languageProvider.isBengali ? 'পুরো নাম' : 'Full Name',
                controller: _nameController,
                validator: (value) => Validators.validateName(value),
                prefixIcon: const Icon(Icons.person_outline),
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

              const SizedBox(height: 32),

              // Update Button
              // CustomButton(
              //   text: languageProvider.isBengali ? 'আপডেট প্রোফাইল' : 'Update Profile',
              //   onPressed: authProvider.isLoading ? null : _updateProfile,
              //   isLoading: authProvider.isLoading,
              // ),

              const SizedBox(height: 16),

              // Change Password Button
              CustomButton(
                text: languageProvider.isBengali ? 'পাসওয়ার্ড পরিবর্তন করুন' : 'Change Password',
                onPressed: () {
                  _showChangePasswordDialog(context, languageProvider);
                },
                type: ButtonType.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, LanguageProvider languageProvider) {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageProvider.isBengali ? 'পাসওয়ার্ড পরিবর্তন করুন' : 'Change Password',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: languageProvider.isBengali ? 'বর্তমান পাসওয়ার্ড' : 'Current Password',
                controller: _currentPasswordController,
                obscureText: true,
                validator: (value) => Validators.validatePassword(value),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: languageProvider.isBengali ? 'নতুন পাসওয়ার্ড' : 'New Password',
                controller: _newPasswordController,
                obscureText: true,
                validator: (value) => Validators.validatePassword(value),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: languageProvider.isBengali ? 'নতুন পাসওয়ার্ড নিশ্চিত করুন' : 'Confirm New Password',
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) => Validators.validateConfirmPassword(value, _newPasswordController.text),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.isBengali ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_newPasswordController.text != _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      languageProvider.isBengali 
                          ? 'পাসওয়ার্ড মেলে না'
                          : 'Passwords do not match',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.changePassword(
                _currentPasswordController.text,
                _newPasswordController.text,
              );

              if (success) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        languageProvider.isBengali 
                            ? 'পাসওয়ার্ড পরিবর্তন করা হয়েছে'
                            : 'Password changed successfully',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
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
            },
            child: Text(languageProvider.isBengali ? 'পরিবর্তন করুন' : 'Change'),
          ),
        ],
      ),
    ).then((_) {
      _currentPasswordController.dispose();
      _newPasswordController.dispose();
      _confirmPasswordController.dispose();
    });
  }
}