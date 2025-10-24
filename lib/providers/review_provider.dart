import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';

class ReviewProvider with ChangeNotifier {
  final _supabase = SupabaseService.instance;
  final _storage = StorageService.instance;

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load reviews for a location
  Future<void> loadReviewsForLocation(String locationId) async {
    _setLoading(true);
    _error = null;

    try {
      final data = await _supabase.getReviewsForLocation(locationId);
      _reviews = data.map((json) => ReviewModel.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Add review
  Future<bool> addReview({
    required String locationId,
    int? locationBlockchainId,
    required String userId,
    required String userWallet,
    required String userName,
    String? userPhotoUrl,
    required int rating,
    required String comment,
    List<File>? images,
    bool verifiedVisit = false,
    bool isTrustedReviewer = false,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // Check review limit for location
      final existingReviews = await _supabase.getReviewsForLocation(locationId);
      final userReviewCount = existingReviews.where((r) => r['user_id'] == userId).length;

      if (userReviewCount >= 5) {
        _error = 'Maximum 5 reviews per location reached';
        _setLoading(false);
        notifyListeners();
        return false;
      }

      // Upload images
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _storage.uploadReviewImages(images);
      }

      // Calculate reward (simplified - actual calculation in smart contract)
      const baseReward = 5;
      final photoBonus = imageUrls.length * 2;
      final textBonus = comment.length > 100 ? 3 : 0;
      final verifiedBonus = verifiedVisit ? 5 : 0;
      final trustedBonus = isTrustedReviewer ? 5 : 0;
      final totalReward = baseReward + photoBonus + textBonus + verifiedBonus + trustedBonus;

      // Create review in Supabase
      final reviewData = {
        'location_id': locationId,
        'location_blockchain_id': locationBlockchainId,
        'user_id': userId,
        'user_wallet': userWallet,
        'user_name': userName,
        'user_photo_url': userPhotoUrl,
        'rating': rating,
        'comment': comment,
        'image_urls': imageUrls,
        'verified_visit': verifiedVisit,
        'reward_amount': totalReward.toString(),
        'is_trusted_reviewer': isTrustedReviewer,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.createReview(reviewData);

      // Update location average rating
      await _updateLocationRating(locationId);

      // Reload reviews
      await loadReviewsForLocation(locationId);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Update location average rating
  Future<void> _updateLocationRating(String locationId) async {
    try {
      final reviews = await _supabase.getReviewsForLocation(locationId);
      
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<int>(
          0,
          (sum, review) => sum + (review['rating'] as int),
        );
        final averageRating = totalRating / reviews.length;

        await _supabase.updateLocation(locationId, {
          'review_count': reviews.length,
          'average_rating': averageRating,
        });
      }
    } catch (e) {
      print('Error updating location rating: $e');
    }
  }

  // Vote on review (upvote/downvote)
  Future<bool> voteReview(String reviewId, bool isUpvote) async {
    try {
      // This would need proper implementation with vote tracking
      // For now, simplified version
      final review = _reviews.firstWhere((r) => r.id == reviewId);
      
      final updates = {
        'upvotes': isUpvote ? review.upvotes + 1 : review.upvotes,
        'downvotes': !isUpvote ? review.downvotes + 1 : review.downvotes,
      };

      await _supabase.client
          .from('reviews')
          .update(updates)
          .eq('id', reviewId);

      // Reload reviews
      if (_reviews.isNotEmpty) {
        await loadReviewsForLocation(_reviews.first.locationId);
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get average rating for reviews
  double getAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    
    final total = _reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return total / _reviews.length;
  }

  // Get rating distribution
  Map<int, int> getRatingDistribution() {
    final distribution = <int, int>{
      5: 0,
      4: 0,
      3: 0,
      2: 0,
      1: 0,
    };

    for (final review in _reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }

    return distribution;
  }

  // Sort reviews
  void sortReviews(String sortBy) {
    switch (sortBy) {
      case 'newest':
        _reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        _reviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        _reviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        _reviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'most_helpful':
        _reviews.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}