import 'dart:math';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // OTP storage
  final Map<String, String> _otpStorage = {};
  final Map<String, Map<String, String>> _pendingUsers = {};
  
  bool _isLoading = false;

  // Getters
  User? get currentFirebaseUser => _auth.currentUser;
  Map<String, dynamic>? get currentUser {
    if (_auth.currentUser == null) return null;
    return {
      'uid': _auth.currentUser!.uid,
      'email': _auth.currentUser!.email,
      'displayName': _auth.currentUser!.displayName,
    };
  }
  
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _auth.currentUser != null;

  // Get complete user data from Firestore for orders
  Future<Map<String, dynamic>?> getUserDataForOrder() async {
    try {
      if (_auth.currentUser == null) return null;
      
      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        return {
          'uid': _auth.currentUser!.uid,
          'email': _auth.currentUser!.email ?? data['email'],
          'displayName': data['name'] ?? _auth.currentUser!.displayName ?? 'Customer',
          'hall': data['hall'] ?? 'Unknown Hall',
          'firstName': data['name']?.split(' ').first ?? 'Customer',
        };
      }
      
      // Fallback if user document doesn't exist
      return {
        'uid': _auth.currentUser!.uid,
        'email': _auth.currentUser!.email ?? 'No Email',
        'displayName': _auth.currentUser!.displayName ?? 'Customer',
        'hall': 'Unknown Hall',
        'firstName': _auth.currentUser!.displayName?.split(' ').first ?? 'Customer',
      };
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // Strong Password Validation
  bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  // Generate OTP
  String generateOTP() {
    Random random = Random();
    return List.generate(6, (index) => random.nextInt(10)).join('');
  }

  // Validate Email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Send OTP via Email (Simulated)
  Future<bool> sendOTPEmail(String email) async {
    try {
      _setLoading(true);
      String otp = generateOTP();
      _otpStorage[email] = otp;

      debugPrint('╔════════════════════════════════════════════╗');
      debugPrint('║        📧 OTP SENT (DEMO MODE)            ║');
      debugPrint('╠════════════════════════════════════════════╣');
      debugPrint('║ Email: $email');
      debugPrint('║ OTP: $otp');
      debugPrint('║ Valid for: 10 minutes');
      debugPrint('╚════════════════════════════════════════════╝');

      await Future.delayed(const Duration(seconds: 2));
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint('Error sending OTP: $e');
      return false;
    }
  }

  // Verify OTP
  bool verifyOTP(String email, String enteredOTP) {
    if (!_otpStorage.containsKey(email)) return false;
    return _otpStorage[email] == enteredOTP;
  }

  // Store pending user data
  void storePendingUser(String email, String firstName, {String hall = '', String password = ''}) {
    _pendingUsers[email] = {
      'firstName': firstName,
      'email': email,
      'hall': hall,
      'password': password,
    };
    notifyListeners();
  }

  // Get pending user
  Map<String, String>? getPendingUser(String email) {
    return _pendingUsers[email];
  }

  // Get all pending users
  Map<String, Map<String, String>> getAllPendingUsers() {
    return Map<String, Map<String, String>>.from(_pendingUsers);
  }

  // Remove pending user
  void removePendingUser(String email) {
    _pendingUsers.remove(email);
    notifyListeners();
  }

  // Complete signup with Firebase Auth
  Future<bool> completeSignup({
    required String email,
    required String password,
    required String firstName,
    required String hall,
    required String phone,
  }) async {
    try {
      _setLoading(true);

      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user!.updateDisplayName(firstName);

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': firstName,
        'email': email,
        'hall': hall,
        'phone': phone,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      });

      _pendingUsers.remove(email);
      _otpStorage.remove(email);
      
      _setLoading(false);
      notifyListeners();
      debugPrint('User registered successfully: $email');
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint('Error completing signup: $e');
      return false;
    }
  }

  // Login with Firebase Auth
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _setLoading(false);
      notifyListeners();
      debugPrint('Login successful for: $email');
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint('Error logging in: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
    debugPrint('User logged out');
  }

  // Get user data for UI (compatible with your existing code)
  String get userDisplayName {
    if (_auth.currentUser == null) return 'Customer';
    return _auth.currentUser!.displayName ?? 'Customer';
  }
  
  String get userEmail {
    if (_auth.currentUser == null) return 'No Email';
    return _auth.currentUser!.email ?? 'No Email';
  }
  
  // Get hall from Firestore (async)
  Future<String> getUserHall() async {
    if (_auth.currentUser == null) return 'Unknown Hall';
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      return userDoc.data()?['hall'] ?? 'Unknown Hall';
    } catch (e) {
      return 'Unknown Hall';
    }
  }

  // Update user profile
  Future<bool> updateProfile({String? firstName, String? hall}) async {
    try {
      if (_auth.currentUser == null) return false;

      final updateData = <String, dynamic>{};
      if (firstName != null) {
        updateData['name'] = firstName;
        await _auth.currentUser!.updateDisplayName(firstName);
      }
      if (hall != null) {
        updateData['hall'] = hall;
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update(updateData);
      }

      notifyListeners();
      debugPrint('Profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  // Check if user is admin
  Future<bool> isUserAdmin() async {
    if (_auth.currentUser == null) return false;
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      return userDoc.data()?['isAdmin'] == true;
    } catch (e) {
      return false;
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear all data (for testing)
  void clearAllData() {
    _otpStorage.clear();
    _pendingUsers.clear();
    notifyListeners();
  }

  // Get user by ID (for admin purposes)
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }
}