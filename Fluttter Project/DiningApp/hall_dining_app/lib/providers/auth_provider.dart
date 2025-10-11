import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AppUser? _user;
  bool _isLoading = false;
  String _error = '';
  bool _isInitialized = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isStudent => _user?.role == 'student';

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Listen to auth state changes
      _authService.user.listen(
        (user) {
          _user = user;
          _isInitialized = true;
          notifyListeners();
        },
        onError: (e) {
          _error = 'Failed to initialize auth: $e';
          _isInitialized = true;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to initialize auth: $e';
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Synchronous wrappers for UI callbacks
  void signInSync(String email, String password) => signIn(email, password);
  void signInWithGoogleSync() => signInWithGoogle();
  void signOutSync() => signOut();
  void resetPasswordSync(String email) => resetPassword(email);
  void updateProfileSync({
    String? name,
    String? phoneNumber,
    String? hall,
    String? roomNumber,
    List<String>? dietaryRestrictions,
  }) => updateProfile(
        name: name,
        phoneNumber: phoneNumber,
        hall: hall,
        roomNumber: roomNumber,
        dietaryRestrictions: dietaryRestrictions,
      );
  void updateProfilePictureSync(String imagePath) => updateProfilePicture(imagePath);
  void changePasswordSync(String currentPassword, String newPassword) => changePassword(currentPassword, newPassword);
  void deleteAccountSync(String password) => deleteAccount(password);
  void refreshUserSync() => refreshUser();

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.signInWithEmailAndPassword(email, password);
      
      _isLoading = false;
      
      if (result.success) {
        _user = result.user;
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result.message ?? 'Sign in failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Sign in failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phoneNumber,
    String? hall,
    String? roomNumber,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
        phoneNumber: phoneNumber,
        hall: hall,
        roomNumber: roomNumber,
      );
      
      _isLoading = false;
      
      if (result.success) {
        _user = result.user;
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result.message ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Registration failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();
      
      _isLoading = false;
      
      if (result.success) {
        _user = result.user;
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result.message ?? 'Google sign in failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Google sign in failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _error = '';
    } catch (e) {
      _error = 'Sign out failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.resetPassword(email);
      
      _isLoading = false;
      
      if (result.success) {
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result.message ?? 'Password reset failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Password reset failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? hall,
    String? roomNumber,
    List<String>? dietaryRestrictions,
  }) async {
    if (_user == null) {
      _error = 'No user logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        uid: _user!.uid,
        name: name,
        phoneNumber: phoneNumber,
        hall: hall,
        roomNumber: roomNumber,
        dietaryRestrictions: dietaryRestrictions,
      );
      
      _isLoading = false;
      
      if (result.success) {
        _user = result.user;
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result.message ?? 'Profile update failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Profile update failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Update profile picture
  Future<bool> updateProfilePicture(String imagePath) async {
    if (_user == null) {
      _error = 'No user logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.updateProfilePicture(_user!.uid, imagePath);
      
      _isLoading = false;
      
      if (result.success) {
        _user = result.user;
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result.message ?? 'Profile picture update failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Profile picture update failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.changePassword(currentPassword, newPassword);
      
      _isLoading = false;
      
      if (result.success) {
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result.message ?? 'Password change failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Password change failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _authService.deleteAccount(password);
      
      _isLoading = false;
      
      if (result.success) {
        _user = null;
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result.message ?? 'Account deletion failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Account deletion failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_user == null) return;

    try {
      final updatedUser = await _authService.currentUser;
      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to refresh user: $e';
      notifyListeners();
    }
  }
}