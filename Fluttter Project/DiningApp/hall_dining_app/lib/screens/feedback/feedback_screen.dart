import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hall_dining_app/models/feedback_model.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import 'feedback_list_screen.dart';

class FeedbackScreen extends StatefulWidget {
  final String? bookingId;
  final String? menuItemId;
  final String? menuItemName;

  const FeedbackScreen({
    Key? key,
    this.bookingId,
    this.menuItemId,
    this.menuItemName,
  }) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  String _selectedType = 'menu_item';
  List<String> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<FeedbackProvider>(context, listen: false).initialize(authProvider.user!.uid);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).isBengali
                ? 'অনুগ্রহ করে একটি রেটিং দিন'
                : 'Please provide a rating',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    final result = await feedbackProvider.submitFeedback(
      userId: authProvider.user!.uid,
      userName: authProvider.user!.name,
      userEmail: authProvider.user!.email!,
      type: _parseFeedbackType(_selectedType),
      rating: _rating,
      comment: _commentController.text,
      bookingId: widget.bookingId,
      menuItemId: widget.menuItemId,
      menuItemName: widget.menuItemName,
    );

    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.isBengali
                  ? 'ফিডব্যাক জমা দেওয়া হয়েছে!'
                  : 'Feedback submitted successfully!',
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
            content: Text(result.message ?? 'Failed to submit feedback'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  FeedbackType _parseFeedbackType(String type) {
    switch (type) {
      case 'menu_item':
        return FeedbackType.menuItem;
      case 'service':
        return FeedbackType.service;
      case 'facility':
        return FeedbackType.facility;
      case 'staff':
        return FeedbackType.staff;
      default:
        return FeedbackType.general;
    }
  }

  void _addImage() async {
    // Implement image picker logic
    // final imagePath = await Provider.of<StorageService>(context, listen: false).pickImageFromGallery();
    // if (imagePath != null) {
    //   Provider.of<FeedbackProvider>(context, listen: false).addImage(imagePath);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = Provider.of<FeedbackProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isBengali ? 'ফিডব্যাক' : 'Feedback',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feedback Type
              Text(
                languageProvider.isBengali ? 'ফিডব্যাক的类型' : 'Feedback Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: [
                  DropdownMenuItem(
                    value: 'menu_item',
                    child: Text(languageProvider.isBengali ? 'মেনু আইটেম' : 'Menu Item'),
                  ),
                  DropdownMenuItem(
                    value: 'service',
                    child: Text(languageProvider.isBengali ? 'সেবা' : 'Service'),
                  ),
                  DropdownMenuItem(
                    value: 'facility',
                    child: Text(languageProvider.isBengali ? 'সুবিধা' : 'Facility'),
                  ),
                  DropdownMenuItem(
                    value: 'staff',
                    child: Text(languageProvider.isBengali ? 'স্টাফ' : 'Staff'),
                  ),
                  DropdownMenuItem(
                    value: 'general',
                    child: Text(languageProvider.isBengali ? 'সাধারণ' : 'General'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Rating
              Text(
                languageProvider.isBengali ? 'রেটিং' : 'Rating',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 40,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Comment
              CustomTextField(
                label: languageProvider.isBengali ? 'মন্তব্য' : 'Comment',
                controller: _commentController,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return languageProvider.isBengali
                        ? 'অনুগ্রহ করে একটি মন্তব্য লিখুন'
                        : 'Please enter a comment';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Images
              Text(
                languageProvider.isBengali ? 'ছবি' : 'Images',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._selectedImages.map((imagePath) => Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            final index = _selectedImages.indexOf(imagePath);
                            feedbackProvider.removeImage(index);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )).toList(),
                  GestureDetector(
                    onTap: _addImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, size: 40),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit Button
              // CustomButton(
              //   text: languageProvider.isBengali ? 'ফিডব্যাক জমা দিন' : 'Submit Feedback',
              //   onPressed: feedbackProvider.isLoading ? null : _submitFeedback,
              //   isLoading: feedbackProvider.isLoading,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}