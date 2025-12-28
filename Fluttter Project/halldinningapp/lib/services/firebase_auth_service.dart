import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';

// Import generated Firebase options (user should fill with real values)
import '../firebase_options.dart';

class FirebaseAuthService {
  static FirebaseAuth? _auth;
  static bool _initialized = false;

  // Initialize Firebase (safe for web and native)
  static Future<void> initializeFirebase() async {
    if (_initialized) return;
    try {
      if (kIsWeb) {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } catch (e) {
          debugPrint('⚠️ Firebase web init note: $e');
        }
      } else {
        try {
          await Firebase.initializeApp();
        } catch (e) {
          debugPrint('⚠️ Firebase init note: $e');
        }
      }
      // Assign auth instance
      try {
        _auth = FirebaseAuth.instance;
      } catch (e) {
        debugPrint('⚠️ Could not get FirebaseAuth.instance yet: $e');
      }
      _initialized = true;
      debugPrint('✅ Firebase initialized (or attempted)');
    } catch (e) {
      debugPrint('❌ Firebase initialization error: $e');
    }
  }

  // Sign up a new user (email + password)
  static Future<User?> signUpWithEmail(String email, String password) async {
    try {
      // Log runtime platform and projectId for debugging
      try {
        final isWeb = kIsWeb;
        final proj = DefaultFirebaseOptions.currentPlatform.projectId;
        debugPrint('signUpWithEmail: kIsWeb=$isWeb, projectId="$proj"');

        // Guard: if running on web and DefaultFirebaseOptions contains demo placeholders,
        // avoid calling the Firebase JS SDK which can cause interop TypeErrors.
        if (isWeb && (proj.contains('demo') || proj.contains('YOUR_PROJECT_ID') || proj.isEmpty)) {
          debugPrint('❌ Firebase web config not set (firebase_options.dart). Signup aborted.');
          return null;
        }
      } catch (e, st) {
        debugPrint('⚠️ Unable to read DefaultFirebaseOptions: $e');
        debugPrint('$st');
      }

      // Lazy initialize auth instance only after guard
      _auth ??= FirebaseAuth.instance;

      UserCredential credential;
      try {
        credential = await _auth!.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on TypeError catch (t) {
        // This can occur when JS interop returns an unexpected object
        debugPrint('❌ Signup TypeError (JS interop): $t');
        return null;
      }

      User? user = credential.user;

      // Create a corresponding Firestore user document (safe defaults)
      try {
        if (user != null) {
          final users = FirebaseFirestore.instance.collection('users');
          await users.doc(user.uid).set({
            'createdAt': Timestamp.now(),
            'email': user.email ?? '',
            'emailVerified': user.emailVerified,
            'hall': '',
            'isAdmin': false,
            'name': user.displayName ?? '',
            'phone': '',
            'photoUrl': user.photoURL ?? '',
            'uid': user.uid,
          }, SetOptions(merge: true));
          debugPrint('✅ Firestore user document created for uid=${user.uid}');
        }
      } catch (e) {
        debugPrint('⚠️ Failed to create Firestore user document: $e');
      }

      if (user != null && !user.emailVerified) {
        await sendVerificationEmail(user);
        debugPrint('✉️ Verification email sent to: $email');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } on FirebaseException catch (e) {
      // firebase_core or web SDK errors can surface as FirebaseException on web.
      debugPrint('❌ FirebaseException during signup: ${e.message ?? e.toString()}');
      return null;
    } catch (e) {
      debugPrint('❌ Signup error: $e');
      return null;
    }
  }

  // Send verification email
  static Future<void> sendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
      debugPrint('✉️ Verification email sent successfully');
    } catch (e) {
      debugPrint('❌ Error sending verification email: $e');
    }
  }

  // Check if email is verified
  static Future<bool> checkEmailVerification() async {
    if (_auth == null) {
      debugPrint('⚠️ checkEmailVerification: FirebaseAuth not initialized');
      return false;
    }
    try {
      User? user = _auth!.currentUser;
      if (user == null) return false;
      await user.reload();
      return user.emailVerified;
    } catch (e) {
      debugPrint('❌ checkEmailVerification error: $e');
      return false;
    }
  }

  // Reload current user
  static Future<void> reloadUser() async {
    try {
      await _auth?.currentUser?.reload();
      debugPrint('🔄 User reloaded');
    } catch (e) {
      debugPrint('❌ Error reloading user: $e');
    }
  }

  // Check if email is verified (direct check)
  static bool isEmailVerified() {
    return _auth?.currentUser?.emailVerified ?? false;
  }

  // Login (email + password)
  static Future<User?> loginWithEmail(String email, String password) async {
    try {
      if (kIsWeb) {
        final opts = DefaultFirebaseOptions.currentPlatform;
        final proj = opts.projectId;
        if (proj.contains('demo') || proj.contains('YOUR_PROJECT_ID')) {
          debugPrint('❌ Firebase web config not set (firebase_options.dart). Login aborted.');
          return null;
        }
      }

      _auth ??= FirebaseAuth.instance;

      UserCredential credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null && !user.emailVerified) {
        await sendVerificationEmail(user);
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email. Verification email sent.',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException during login: ${e.message ?? e.toString()}');
      return null;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      if (_auth == null) {
        debugPrint('⚠️ logout: FirebaseAuth not initialized');
        return;
      }
      await _auth!.signOut();
      debugPrint('✅ Logged out successfully');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth?.currentUser;
  }

  // User stream (real-time)
  static Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? const Stream<User?>.empty();

  // Password reset email
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      if (_auth == null) {
        debugPrint('⚠️ sendPasswordResetEmail: FirebaseAuth not initialized');
        return false;
      }
      await _auth!.sendPasswordResetEmail(email: email);
      debugPrint('✉️ Password reset email sent to: $email');
      return true;
    } catch (e) {
      debugPrint('❌ Error sending password reset email: $e');
      return false;
    }
  }

  // Update profile
  static Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth?.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        await user.reload();
        debugPrint('✅ Profile updated successfully');
      }
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
    }
  }

  // Delete user account
  static Future<bool> deleteAccount() async {
    try {
      final user = _auth?.currentUser;
      if (user != null) {
        await user.delete();
        debugPrint('✅ Account deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting account: $e');
      return false;
    }
  }

  // Firebase error handling
  static String _handleAuthError(FirebaseAuthException e) {
    String message = '';
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        message = 'Email already in use.';
        break;
      case 'weak-password':
        message = 'Password is too weak.';
        break;
      case 'invalid-email':
        message = 'Invalid email address.';
        break;
      case 'user-disabled':
        message = 'User account has been disabled.';
        break;
      case 'email-not-verified':
        message = 'Please verify your email first.';
        break;
      default:
        message = e.message ?? 'An error occurred';
    }
    debugPrint('Firebase Error (${e.code}): $message');
    return message;
  }

  // Get user email
  static String? getUserEmail() {
    return _auth?.currentUser?.email;
  }

  // Check if user is logged in
  static bool isUserLoggedIn() {
    return _auth?.currentUser != null;
  }

  // Re-authenticate user (before sensitive actions)
  static Future<bool> reauthenticateUser(String password) async {
    try {
      final user = _auth?.currentUser;
      if (user != null && user.email != null) {
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Re-authentication error: $e');
      return false;
    }
  }

  // Change password
  static Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final reauth = await reauthenticateUser(currentPassword);
      if (reauth) {
        final user = _auth?.currentUser;
        await user?.updatePassword(newPassword);
        debugPrint('✅ Password changed successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error changing password: $e');
      return false;
    }
  }

  // Resend verification email
  static Future<void> resendVerificationEmail() async {
    try {
      final user = _auth?.currentUser;
      if (user != null && !user.emailVerified) {
        await sendVerificationEmail(user);
      }
    } catch (e) {
      debugPrint('❌ Error resending verification email: $e');
    }
  }
}
