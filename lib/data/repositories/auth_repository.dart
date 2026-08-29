import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/app_user.dart';
import '../mock/mock_users.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> loginDemo(UserRole role);
  Future<void> logout();
  Future<AppUser> registerUser(String name, String email, String phone, String location, UserRole role);
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);
}

class MockAuthRepository implements AuthRepository {
  static const String _keyUserId = 'meetly_user_id';
  static const String _keyUserRole = 'meetly_user_role';
  static const String _keyOnboarding = 'meetly_onboarding_done';

  AppUser? _currentUser;

  @override
  Future<AppUser?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    final userRoleString = prefs.getString(_keyUserRole);

    if (userId != null && userRoleString != null) {
      // Find user from mock dataset
      try {
        final matched = allMockUsers.firstWhere((u) => u.id == userId);
        _currentUser = matched;
        return _currentUser;
      } catch (_) {
        // Handle case where user is not in seeded data (e.g. registered user)
        // For fallback, we default to the first customer in list
        _currentUser = mockCustomers.first;
        return _currentUser;
      }
    }
    return null;
  }

  @override
  Future<AppUser> loginDemo(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    AppUser selectedUser;

    switch (role) {
      case UserRole.customer:
        selectedUser = mockCustomers.first; // Aarav Nair (c1)
        break;
      case UserRole.provider:
        selectedUser = mockProviderUsers.first; // Arun Thomas (up1)
        break;
      case UserRole.admin:
        selectedUser = mockAdmins.first; // Rajesh Pillai (a1)
        break;
    }

    _currentUser = selectedUser;
    await prefs.setString(_keyUserId, selectedUser.id);
    await prefs.setString(_keyUserRole, selectedUser.role.name);
    return selectedUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserRole);
  }

  @override
  Future<AppUser> registerUser(
    String name,
    String email,
    String phone,
    String location,
    UserRole role,
  ) async {
    // Simulate registering a new user
    final newId = role == UserRole.customer
        ? 'c_${DateTime.now().millisecondsSinceEpoch}'
        : role == UserRole.provider
            ? 'up_${DateTime.now().millisecondsSinceEpoch}'
            : 'a_${DateTime.now().millisecondsSinceEpoch}';

    final newUser = AppUser(
      id: newId,
      name: name,
      email: email,
      phone: phone,
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=$name',
      role: role,
      location: location,
    );

    // Save in local cache variable
    _currentUser = newUser;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, newUser.id);
    await prefs.setString(_keyUserRole, newUser.role.name);

    return newUser;
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, completed);
  }
}

// Riverpod Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

// Auth State Notifier for reactive UI transitions
class AuthStateNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthRepository _repository;

  AuthStateNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginAsDemo(UserRole role) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginDemo(role);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(
    String name,
    String email,
    String phone,
    String location,
    UserRole role,
  ) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.registerUser(name, email, phone, location, role);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setRole(UserRole role) async {
    final currentVal = state.value;
    if (currentVal != null) {
      final updatedUser = currentVal.copyWith(role: role);
      state = AsyncValue.data(updatedUser);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('meetly_user_role', role.name);
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<AppUser?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repo);
});
