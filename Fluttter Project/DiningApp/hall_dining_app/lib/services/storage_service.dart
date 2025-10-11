import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Upload user profile image
  Future<String?> uploadUserProfileImage(String userId, String imagePath) async {
    try {
      Reference ref = _storage.ref().child('user_profiles/$userId/profile.jpg');
      UploadTask uploadTask = ref.putFile(File(imagePath));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Upload menu item image
  Future<String?> uploadMenuItemImage(String menuItemId, String imagePath) async {
    try {
      Reference ref = _storage.ref().child('menu_items/$menuItemId/image.jpg');
      UploadTask uploadTask = ref.putFile(File(imagePath));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading menu item image: $e');
      return null;
    }
  }

  // Upload event image
  Future<String?> uploadEventImage(String eventId, String imagePath) async {
    try {
      Reference ref = _storage.ref().child('events/$eventId/image.jpg');
      UploadTask uploadTask = ref.putFile(File(imagePath));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading event image: $e');
      return null;
    }
  }

  // Upload feedback image
  Future<String?> uploadFeedbackImage(String feedbackId, String imagePath) async {
    try {
      Reference ref = _storage.ref().child('feedback/$feedbackId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = ref.putFile(File(imagePath));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading feedback image: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image?.path;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Capture image from camera
  Future<String?> captureImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image?.path;
    } catch (e) {
      print('Error capturing image from camera: $e');
      return null;
    }
  }

  // Delete file from storage
  Future<void> deleteFile(String url) async {
    try {
      Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  // Get file download URL
  Future<String> getDownloadURL(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  // Upload multiple images for feedback
  Future<List<String>> uploadFeedbackImages(String feedbackId, List<String> imagePaths) async {
    try {
      List<String> uploadedUrls = [];
      
      for (int i = 0; i < imagePaths.length; i++) {
        Reference ref = _storage.ref().child('feedback/$feedbackId/image_$i.jpg');
        UploadTask uploadTask = ref.putFile(File(imagePaths[i]));
        TaskSnapshot snapshot = await uploadTask;
        String url = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(url);
      }
      
      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload feedback images: $e');
    }
  }

  // Generate QR code and upload to storage
  Future<String?> uploadQRCode(String bookingId, String qrData) async {
    try {
      // In a real app, you would generate QR code image here
      // For now, we'll just store the data
      Reference ref = _storage.ref().child('qr_codes/$bookingId.png');
      // You would generate QR code image and upload it
      // For demo purposes, we'll return a placeholder
      return 'https://api.qrserver.com/v1/create-qr-code/?data=${Uri.encodeComponent(qrData)}&size=200x200';
    } catch (e) {
      print('Error uploading QR code: $e');
      return null;
    }
  }
}