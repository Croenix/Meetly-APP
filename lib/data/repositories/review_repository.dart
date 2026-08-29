import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/review.dart';
import '../mock/mock_reviews.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviewsForProvider(String providerId);
  Future<List<Review>> getAllReviews();
  Future<void> submitReview(Review review);
  Future<void> replyToReview(String reviewId, String reply);
  Future<void> deleteReview(String reviewId);
}

class MockReviewRepository implements ReviewRepository {
  final List<Review> _reviews = List.from(mockReviews);

  @override
  Future<List<Review>> getReviewsForProvider(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _reviews.where((r) => r.providerId == providerId).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Simple sorting
  }

  @override
  Future<List<Review>> getAllReviews() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_reviews);
  }

  @override
  Future<void> submitReview(Review review) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _reviews.add(review);
  }

  @override
  Future<void> replyToReview(String reviewId, String reply) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      _reviews[index] = _reviews[index].copyWith(reply: reply);
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _reviews.removeWhere((r) => r.id == reviewId);
  }
}

// Riverpod Provider
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return MockReviewRepository();
});

// Provider-specific Reviews Provider
final providerReviewsProvider = FutureProvider.family<List<Review>, String>((ref, providerId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsForProvider(providerId);
});

// Global Reviews list Provider for Admin
final allReviewsProvider = FutureProvider<List<Review>>((ref) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getAllReviews();
});
