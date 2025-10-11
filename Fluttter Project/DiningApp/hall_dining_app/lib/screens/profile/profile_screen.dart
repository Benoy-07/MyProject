import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (authProvider.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = authProvider.user!;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.profileImage != null
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: user.profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                      backgroundColor: AppColors.primary,
                    ),

                    const SizedBox(height: 16),

                    // User Name
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // User Email
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // User Role
                    Chip(
                      label: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: AppColors.primary,
                    ),

                    const SizedBox(height: 16),

                    // Edit Profile Button
                    CustomButton(
                      text: languageProvider.isBengali ? 'প্রোফাইল সম্পাদনা' : 'Edit Profile',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      type: ButtonType.outline,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // User Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.isBengali ? 'ব্যবহারকারীর তথ্য' : 'User Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.phone,
                      languageProvider.isBengali ? 'ফোন নম্বর' : 'Phone Number',
                      user.phoneNumber ?? languageProvider.isBengali ? 'সংযোজন করা হয়নি' : 'Not provided',
                    ),
                    _buildInfoRow(
                      Icons.home,
                      languageProvider.isBengali ? 'হল' : 'Hall',
                      user.hall ?? languageProvider.isBengali ? 'সংযোজন করা হয়নি' : 'Not provided',
                    ),
                    _buildInfoRow(
                      Icons.meeting_room,
                      languageProvider.isBengali ? 'রুম নম্বর' : 'Room Number',
                      user.roomNumber ?? languageProvider.isBengali ? 'সংযোজন করা হয়নি' : 'Not provided',
                    ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      languageProvider.isBengali ? 'সদস্য since' : 'Member Since',
                      '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.isBengali ? 'পরিসংখ্যান' : 'Statistics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          user.totalBookings.toString(),
                          languageProvider.isBengali ? 'মোট বুকিং' : 'Total Bookings',
                          Icons.book_online,
                        ),
                        _buildStatItem(
                          '৳${user.totalSpent.toStringAsFixed(0)}',
                          languageProvider.isBengali ? 'মোট খরচ' : 'Total Spent',
                          Icons.attach_money,
                        ),
                        _buildStatItem(
                          user.loyaltyPoints.toString(),
                          languageProvider.isBengali ? 'লয়্যালটি পয়েন্ট' : 'Loyalty Points',
                          Icons.card_giftcard,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.isBengali ? 'অ্যাকশনস' : 'Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionTile(
                      Icons.settings,
                      languageProvider.isBengali ? 'সেটিংস' : 'Settings',
                      () {
                        // Navigate to settings
                      },
                    ),
                    _buildActionTile(
                      Icons.help_outline,
                      languageProvider.isBengali ? 'সাহায্য ও সমর্থন' : 'Help & Support',
                      () {
                        // Navigate to help
                      },
                    ),
                    _buildActionTile(
                      Icons.privacy_tip_outlined,
                      languageProvider.isBengali ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
                      () {
                        // Navigate to privacy policy
                      },
                    ),
                    _buildActionTile(
                      Icons.description_outlined,
                      languageProvider.isBengali ? 'শর্তাবলী' : 'Terms of Service',
                      () {
                        // Navigate to terms
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            CustomButton(
              text: languageProvider.isBengali ? 'লগআউট' : 'Logout',
              onPressed: () {
                _showLogoutDialog(context, languageProvider);
              },
              type: ButtonType.danger,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageProvider.isBengali ? 'লগআউট' : 'Logout',
        ),
        content: Text(
          languageProvider.isBengali 
              ? 'আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?'
              : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.isBengali ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(languageProvider.isBengali ? 'লগআউট' : 'Logout'),
          ),
        ],
      ),
    );
  }
}