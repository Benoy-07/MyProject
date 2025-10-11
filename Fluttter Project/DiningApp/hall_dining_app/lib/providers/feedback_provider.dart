import 'package:flutter/foundation.dart';
import '../models/feedback_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class FeedbackProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  
  List<Feedback> _feedbackList = [];
  List<Feedback> _userFeedback = [];
  Feedback? _selectedFeedback;
  bool _isLoading = false;
  String _error = '';
  List<String> _selectedImages = [];

  List<Feedback> get feedbackList => _feedbackList;
  List<Feedback> get userFeedback => _userFeedback;
  Feedback? get selectedFeedback => _selectedFeedback;
  bool get isLoading => _isLoading;
  String get error => _error;
  List<String> get selectedImages => _selectedImages;

  // Initialize provider
  void initialize(String userId) {
    _loadUserFeedback(userId);
  }

  // Load user feedback
  Future<void> _loadUserFeedback(String userId) async {
    try {
      _firestoreService.getUserFeedbackStream(userId).listen((feedback) {
        _userFeedback = feedback;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to load feedback: $e';
      notifyListeners();
    }
  }

  // Load all feedback (for admin)
  Future<void> loadAllFeedback() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _firestoreService.getAllFeedbackStream().listen((feedback) {
        _feedbackList = feedback;
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        _error = 'Failed to load feedback: $error';
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to load feedback: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit feedback
  Future<FeedbackResult> submitFeedback({
    required String userId,
    required String userName,
    required String userEmail,
    required FeedbackType type,
    required int rating,
    required String comment,
    String? bookingId,
    String? menuItemId,
    String? menuItemName,
    bool isAnonymous = false,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      List<String> uploadedImageUrls = [];
      
      // Upload images if any
      if (_selectedImages.isNotEmpty) {
        final feedbackId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        uploadedImageUrls = await _storageService.uploadFeedbackImages(
          feedbackId,
          _selectedImages,
        );
      }

      final feedback = Feedback(
        id: '', // Will be set by Firestore
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        bookingId: bookingId,
        menuItemId: menuItemId,
        menuItemName: menuItemName,
        type: type,
        rating: rating,
        comment: comment,
        images: uploadedImageUrls,
        isAnonymous: isAnonymous,
        status: FeedbackStatus.pending,
        createdAt: DateTime.now(),
      );

      final feedbackId = await _firestoreService.submitFeedback(feedback);
      
      // Clear selected images
      _selectedImages.clear();
      
      _isLoading = false;
      notifyListeners();
      return FeedbackResult.success(feedbackId: feedbackId);
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to submit feedback: $e';
      notifyListeners();
      return FeedbackResult.error(message: _error);
    }
  }

  // Add image to feedback
  void addImage(String imagePath) {
    _selectedImages.add(imagePath);
    notifyListeners();
  }

  // Remove image from feedback
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  // Clear selected images
  void clearImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  // Set selected feedback
  void setSelectedFeedback(Feedback feedback) {
    _selectedFeedback = feedback;
    notifyListeners();
  }

  // Clear selected feedback
  void clearSelectedFeedback() {
    _selectedFeedback = null;
    notifyListeners();
  }

  // Update feedback status (admin only)
  Future<bool> updateFeedbackStatus(String feedbackId, FeedbackStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, you would update this in Firestore
      // For now, we'll update the local state
      final feedbackIndex = _feedbackList.indexWhere((f) => f.id == feedbackId);
      if (feedbackIndex != -1) {
        _feedbackList[feedbackIndex] = _feedbackList[feedbackIndex].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update feedback status: $e';
      notifyListeners();
      return false;
    }
  }

  // Add admin response to feedback
  Future<bool> addAdminResponse({
    required String feedbackId,
    required String response,
    required String adminId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, you would update this in Firestore
      final feedbackIndex = _feedbackList.indexWhere((f) => f.id == feedbackId);
      if (feedbackIndex != -1) {
        _feedbackList[feedbackIndex] = _feedbackList[feedbackIndex].copyWith(
          adminResponse: response,
          adminResponseDate: DateTime.now(),
          respondedBy: adminId,
          status: FeedbackStatus.resolved,
          updatedAt: DateTime.now(),
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add admin response: $e';
      notifyListeners();
      return false;
    }
  }

  // Get feedback by type
  List<Feedback> getFeedbackByType(FeedbackType type) {
    return _feedbackList.where((feedback) => feedback.type == type).toList();
  }

  // Get feedback by status
  List<Feedback> getFeedbackByStatus(FeedbackStatus status) {
    return _feedbackList.where((feedback) => feedback.status == status).toList();
  }

  // Get high priority feedback (low ratings)
  List<Feedback> getHighPriorityFeedback() {
    return _feedbackList.where((feedback) => feedback.rating <= 2).toList();
  }

  // Get feedback statistics
  Map<String, dynamic> getFeedbackStats() {
    final totalFeedback = _feedbackList.length;
    final pendingFeedback = _feedbackList.where((f) => f.status == FeedbackStatus.pending).length;
    final resolvedFeedback = _feedbackList.where((f) => f.status == FeedbackStatus.resolved).length;
    
    double totalRating = 0;
    final ratingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    
    for (final feedback in _feedbackList) {
      totalRating += feedback.rating;
      ratingDistribution[feedback.rating] = (ratingDistribution[feedback.rating] ?? 0) + 1;
    }
    
    final averageRating = totalFeedback > 0 ? totalRating / totalFeedback : 0;
    final resolutionRate = totalFeedback > 0 ? (resolvedFeedback / totalFeedback) * 100 : 0;
    
    final typeDistribution = <String, int>{};
    for (final feedback in _feedbackList) {
      final type = feedback.displayType;
      typeDistribution[type] = (typeDistribution[type] ?? 0) + 1;
    }
    
    return {
      'totalFeedback': totalFeedback,
      'pendingFeedback': pendingFeedback,
      'resolvedFeedback': resolvedFeedback,
      'averageRating': averageRating,
      'resolutionRate': resolutionRate,
      'ratingDistribution': ratingDistribution,
      'typeDistribution': typeDistribution,
    };
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Refresh feedback
  Future<void> refreshFeedback(String userId) async {
    _loadUserFeedback(userId);
  }
}

class FeedbackResult {
  final bool success;
  final String? feedbackId;
  final String? message;

  FeedbackResult({
    required this.success,
    this.feedbackId,
    this.message,
  });

  factory FeedbackResult.success({required String feedbackId}) {
    return FeedbackResult(success: true, feedbackId: feedbackId);
  }

  factory FeedbackResult.error({required String message}) {
    return FeedbackResult(success: false, message: message);
  }
}