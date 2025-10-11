import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Sign up with email and password
  Future<String?> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'username': username,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // No error
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // No error
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      } else if (e.code == 'invalid-credential') {
        return 'Invalid email or password.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
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
      return 'user';
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}