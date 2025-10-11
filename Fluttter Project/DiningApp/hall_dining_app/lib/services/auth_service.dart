import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final StorageService _storageService = StorageService();

  // Stream for auth state changes
  Stream<AppUser?> get user {
    return _auth.authStateChanges().asyncMap((User? firebaseUser) {
      if (firebaseUser != null) {
        return _getUserData(firebaseUser.uid);
      }
      return null;
    });
  }

  // Get current user
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user != null ? AppUser.fromMap({'uid': user.uid, 'email': user.email}) : null;
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      AppUser? user = await _getUserData(result.user!.uid);
      return AuthResult.success(user: user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error(message: 'An unexpected error occurred');
    }
  }

  // Register with email and password
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phoneNumber,
    String? hall,
    String? roomNumber,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user document in Firestore
      AppUser user = AppUser(
        uid: result.user!.uid,
        email: email.trim(),
        name: name,
        role: role,
        phoneNumber: phoneNumber,
        hall: hall,
        roomNumber: roomNumber,
        createdAt: DateTime.now(),
        loyaltyPoints: 0,
        isActive: true,
        dietaryRestrictions: [],
        totalSpent: 0.0,
        totalBookings: 0,
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(user.toMap());

      return AuthResult.success(user: user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error(message: 'Registration failed: $e');
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.error(message: 'Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      
      // Check if user exists in Firestore
      AppUser? existingUser = await _getUserData(result.user!.uid);
      
      if (existingUser == null) {
        // Create new user document
        AppUser newUser = AppUser(
          uid: result.user!.uid,
          email: result.user!.email!,
          name: result.user!.displayName ?? 'User',
          role: 'student',
          profileImage: result.user!.photoURL,
          createdAt: DateTime.now(),
          loyaltyPoints: 0,
          isActive: true,
          dietaryRestrictions: [],
          totalSpent: 0.0,
          totalBookings: 0,
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());

        return AuthResult.success(user: newUser);
      } else {
        return AuthResult.success(user: existingUser);
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error(message: 'Google sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error(message: 'Password reset failed: $e');
    }
  }

  // Update user profile
  Future<AuthResult> updateProfile({
    required String uid,
    String? name,
    String? phoneNumber,
    String? hall,
    String? roomNumber,
    List<String>? dietaryRestrictions,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (hall != null) updates['hall'] = hall;
      if (roomNumber != null) updates['roomNumber'] = roomNumber;
      if (dietaryRestrictions != null) updates['dietaryRestrictions'] = dietaryRestrictions;

      await _firestore.collection('users').doc(uid).update(updates);

      // Get updated user data
      AppUser? updatedUser = await _getUserData(uid);
      return AuthResult.success(user: updatedUser);
    } catch (e) {
      return AuthResult.error(message: 'Profile update failed: $e');
    }
  }

  // Update profile picture
  Future<AuthResult> updateProfilePicture(String uid, String imagePath) async {
    try {
      // Upload image to storage
      String? imageUrl = await _storageService.uploadUserProfileImage(uid, imagePath);
      
      if (imageUrl != null) {
        await _firestore.collection('users').doc(uid).update({
          'profileImage': imageUrl,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });

        AppUser? updatedUser = await _getUserData(uid);
        return AuthResult.success(user: updatedUser);
      } else {
        return AuthResult.error(message: 'Failed to upload profile picture');
      }
    } catch (e) {
      return AuthResult.error(message: 'Profile picture update failed: $e');
    }
  }

  // Change password
  Future<AuthResult> changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      
      if (user != null && user.email != null) {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        
        return AuthResult.success();
      } else {
        return AuthResult.error(message: 'User not found');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error(message: 'Password change failed: $e');
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      
      if (user != null && user.email != null) {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        
        await user.reauthenticateWithCredential(credential);
        
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user from Auth
        await user.delete();
        
        return AuthResult.success();
      } else {
        return AuthResult.error(message: 'User not found');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error(message: 'Account deletion failed: $e');
    }
  }

  // Get user data from Firestore
  Future<AppUser?> _getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  // Helper method to get auth error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}

class AuthResult {
  final bool success;
  final String? message;
  final AppUser? user;

  AuthResult({
    required this.success,
    this.message,
    this.user,
  });

  factory AuthResult.success({AppUser? user}) {
    return AuthResult(success: true, user: user);
  }

  factory AuthResult.error({required String message}) {
    return AuthResult(success: false, message: message);
  }
}