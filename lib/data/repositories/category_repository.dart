import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class CategoryRepository {
  Future<List<String>> getCategories();
  Future<void> addCategory(String category);
  Future<void> deleteCategory(String category);
}

class MockCategoryRepository implements CategoryRepository {
  final List<String> _categories = [
    'Cleaning',
    'Plumbing',
    'Electrical',
    'Appliance',
    'Painting',
    'Carpentry',
    'Pest Control',
    'Salon',
  ];

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_categories);
  }

  @override
  Future<void> addCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final trimmed = category.trim();
    if (trimmed.isNotEmpty && !_categories.any((c) => c.toLowerCase() == trimmed.toLowerCase())) {
      _categories.add(trimmed);
    }
  }

  @override
  Future<void> deleteCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _categories.removeWhere((c) => c.toLowerCase() == category.toLowerCase());
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return MockCategoryRepository();
});

final categoriesListProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});
