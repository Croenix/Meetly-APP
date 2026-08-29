import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/service_provider.dart';
import '../mock/mock_providers.dart';
import 'auth_repository.dart';

abstract class ProviderRepository {
  Future<List<ServiceProvider>> getProviders();
  Future<ServiceProvider?> getProviderById(String id);
  Future<List<ServiceProvider>> getProvidersByCategory(String category);
  Future<List<ServiceProvider>> getFavoriteProviders();
  Future<void> toggleFavorite(String providerId);
  Future<bool> isFavorite(String providerId);
  Future<void> updateProviderProfile(ServiceProvider provider);
  Future<void> submitVerification(String providerId, String name, String phone, String businessDetails);
}

class MockProviderRepository implements ProviderRepository {
  static const String _keyFavorites = 'meetly_favorites';

  // In-memory list of providers initialized from mock data
  final List<ServiceProvider> _providers = List.from(mockProviders);

  @override
  Future<List<ServiceProvider>> getProviders() async {
    // Artificial delay to simulate network call
    await Future.delayed(const Duration(milliseconds: 300));
    return _providers;
  }

  @override
  Future<ServiceProvider?> getProviderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _providers.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ServiceProvider>> getProvidersByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _providers.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  @override
  Future<List<ServiceProvider>> getFavoriteProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList(_keyFavorites) ?? [];
    return _providers.where((p) => favIds.contains(p.id)).toList();
  }

  @override
  Future<void> toggleFavorite(String providerId) async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList(_keyFavorites) ?? [];
    if (favIds.contains(providerId)) {
      favIds.remove(providerId);
    } else {
      favIds.add(providerId);
    }
    await prefs.setStringList(_keyFavorites, favIds);
  }

  @override
  Future<bool> isFavorite(String providerId) async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList(_keyFavorites) ?? [];
    return favIds.contains(providerId);
  }

  @override
  Future<void> updateProviderProfile(ServiceProvider provider) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _providers.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      _providers[index] = provider;
    }
  }

  @override
  Future<void> submitVerification(
    String providerId,
    String name,
    String phone,
    String businessDetails,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _providers.indexWhere((p) => p.id == providerId);
    if (index != -1) {
      final updated = _providers[index].copyWith(
        businessName: businessDetails.isNotEmpty ? businessDetails : _providers[index].businessName,
        phone: phone.isNotEmpty ? phone : _providers[index].phone,
        verificationStatus: 'under_review',
      );
      _providers[index] = updated;
    }
  }
}

// Riverpod Provider
final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  return MockProviderRepository();
});

// Providers List Riverpod Provider
final providersListProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  final repo = ref.watch(providerRepositoryProvider);
  return repo.getProviders();
});

// Single Provider Details Riverpod Provider
final providerDetailsProvider = FutureProvider.family<ServiceProvider?, String>((ref, id) async {
  final repo = ref.watch(providerRepositoryProvider);
  return repo.getProviderById(id);
});

// Category-filtered Providers Riverpod Provider
final categoryProvidersProvider = FutureProvider.family<List<ServiceProvider>, String>((ref, category) async {
  final repo = ref.watch(providerRepositoryProvider);
  return repo.getProvidersByCategory(category);
});

// Favorites Providers List Riverpod Provider
final favoritesListProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  final repo = ref.watch(providerRepositoryProvider);
  return repo.getFavoriteProviders();
});

// Get current logged in provider's business profile
final currentProviderProfileProvider = FutureProvider<ServiceProvider?>((ref) async {
  // We dynamic import here or watch
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return null;
  final repo = ref.watch(providerRepositoryProvider);
  final list = await repo.getProviders();
  try {
    return list.firstWhere((p) => p.userId == user.id);
  } catch (_) {
    return null;
  }
});
