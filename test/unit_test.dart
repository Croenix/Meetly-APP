import 'package:flutter_test/flutter_test.dart';
import 'package:meetly/core/models/review.dart';
import 'package:meetly/data/repositories/category_repository.dart';
import 'package:meetly/data/repositories/review_repository.dart';

void main() {
  group('CategoryRepository Tests', () {
    late CategoryRepository categoryRepo;

    setUp(() {
      categoryRepo = MockCategoryRepository();
    });

    test('should fetch initial categories list', () async {
      final list = await categoryRepo.getCategories();
      expect(list, isNotEmpty);
      expect(list.contains('Electrical'), isTrue);
      expect(list.contains('Plumbing'), isTrue);
    });

    test('should add new category dynamically', () async {
      const newCat = 'Carpentry Extra';
      await categoryRepo.addCategory(newCat);
      
      final list = await categoryRepo.getCategories();
      expect(list.contains(newCat), isTrue);
    });

    test('should not add duplicate category', () async {
      final listBefore = await categoryRepo.getCategories();
      final lengthBefore = listBefore.length;

      await categoryRepo.addCategory('Electrical'); // duplicate
      
      final listAfter = await categoryRepo.getCategories();
      expect(listAfter.length, equals(lengthBefore));
    });

    test('should delete category correctly', () async {
      await categoryRepo.deleteCategory('Cleaning');
      
      final list = await categoryRepo.getCategories();
      expect(list.contains('Cleaning'), isFalse);
    });
  });

  group('ReviewRepository Tests', () {
    late ReviewRepository reviewRepo;

    setUp(() {
      reviewRepo = MockReviewRepository();
    });

    test('should fetch provider specific reviews', () async {
      final reviews = await reviewRepo.getReviewsForProvider('p1');
      expect(reviews, isNotEmpty);
      for (final r in reviews) {
        expect(r.providerId, equals('p1'));
      }
    });

    test('should submit a review and retrieve it', () async {
      final newReview = Review(
        id: 'new_rev_123',
        bookingId: 'b1',
        providerId: 'p2',
        customerName: 'Anoop G',
        customerAvatar: 'avatar_seed',
        rating: 5.0,
        comment: 'Outstanding job!',
        date: '30 Aug 2026',
      );

      await reviewRepo.submitReview(newReview);

      final reviews = await reviewRepo.getReviewsForProvider('p2');
      expect(reviews.any((r) => r.id == 'new_rev_123'), isTrue);
    });

    test('should moderate and delete review', () async {
      // Fetch all reviews first
      final allBefore = await reviewRepo.getAllReviews();
      expect(allBefore.isNotEmpty, isTrue);

      final targetId = allBefore.first.id;
      await reviewRepo.deleteReview(targetId);

      final allAfter = await reviewRepo.getAllReviews();
      expect(allAfter.any((r) => r.id == targetId), isFalse);
    });
  });
}
