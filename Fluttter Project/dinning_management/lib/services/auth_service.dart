import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      notifyListeners();
    });
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final uc = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return uc;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final uc = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return uc;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
