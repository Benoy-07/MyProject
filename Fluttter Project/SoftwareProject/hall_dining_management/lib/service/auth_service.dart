import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user (async version for consistency with Firestore loads)
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Sign up with email and password
  Future<String?> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print('Attempting to create user: $email');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('User created successfully: ${result.user!.uid}');

      // Save user data to Firestore
      try {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'name': username.trim(),
          'email': email.trim(),
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': result.user!.uid,
        });

        print('User data saved to Firestore');
      } on FirebaseException catch (fe) {
        print('Firestore Error during signup: ${fe.code} - ${fe.message}');
        // Attempt to delete the created auth user to avoid orphaned auth accounts
        try {
          await result.user!.delete();
          print('Deleted auth user due to Firestore failure');
        } catch (delErr) {
          print('Failed to delete auth user after Firestore failure: $delErr');
        }
        return 'Failed to save user data: ${fe.message ?? fe.code}';
      }

      return null; // No error
      
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error during signup: ${e.code} - ${e.message}');
      
      String errorMessage = 'Sign up failed. Please try again.';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred.';
      }
      return errorMessage;
      
    } catch (e) {
      print('General Error during signup: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting to sign in: $email');
      
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('Sign in successful');
      return null; // No error
      
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error during signin: ${e.code} - ${e.message}');
      
      String errorMessage = 'Sign in failed. Please try again.';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email. Please sign up first.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred.';
      }
      return errorMessage;
      
    } catch (e) {
      print('General Error during signin: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out user');
      await _auth.signOut();
      print('Sign out successful');
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  // Get user role
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.get('role') ?? 'user';
      }
      return 'user';
    } catch (e) {
      print('Error getting user role: $e');
      return 'user';
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (_auth.currentUser == null) return null;
    return await getUserData(_auth.currentUser!.uid);
  }

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Password reset
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.code} - ${e.message}');
      
      String errorMessage = 'Failed to send reset email.';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred.';
      }
      return errorMessage;
    } catch (e) {
      print('General error during password reset: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Update user profile
  Future<String?> updateUserProfile({
    required String uid,
    String? name,
    String? email,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name.trim();
      if (email != null) updateData['email'] = email.trim();
      
      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updateData);
        
        // If email is updated, initiate verification in Firebase Auth
        if (email != null && _auth.currentUser != null) {
          try {
            await _auth.currentUser!.verifyBeforeUpdateEmail(email.trim());
            return 'Profile updated. A verification email has been sent to ${email.trim()}. Please verify to complete the email change.';
          } on FirebaseAuthException catch (authError) {
            if (authError.code == 'requires-recent-login') {
              // Handle re-authentication needed (you can prompt user to re-sign in here)
              return 'Please sign in again to update your email for security.';
            }
            print('Auth error during email update: ${authError.code} - ${authError.message}');
            return authError.message ?? 'Failed to update email in Auth.';
          }
        }
      }
      
      return null; // Success for non-email updates
    } on FirebaseAuthException catch (e) {
      print('Error updating profile: ${e.code} - ${e.message}');
      return e.message;
    } catch (e) {
      print('General error updating profile: $e');
      return 'Failed to update profile. Please try again.';
    }
  }

  // Delete user account
  Future<String?> deleteUserAccount(String uid) async {
    try {
      // Delete from Firestore first
      await _firestore.collection('users').doc(uid).delete();
      
      // Then delete from Firebase Auth
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      print('Error deleting account: ${e.code} - ${e.message}');
      return e.message;
    } catch (e) {
      print('General error deleting account: $e');
      return 'Failed to delete account. Please try again.';
    }
  }

  // Verify email
  Future<void> sendEmailVerification() async {
    if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
      await _auth.currentUser!.sendEmailVerification();
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Reload user (to refresh email verification status)
  Future<void> reloadUser() async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.reload();
    }
  }
}