import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/app_user.dart';
import '../mock/mock_users.dart';

class UnregisteredUserException implements Exception {
  final String message;
  UnregisteredUserException([this.message = 'You are not registered yet. Please register first to continue.']);

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> loginDemo(UserRole role);
  Future<void> logout();
  Future<AppUser> registerUser(String name, String email, String phone, String location, UserRole role);
  Future<AppUser> loginWithEmail(String email, String password);
  Future<AppUser> loginWithSocial(String providerName);
  Future<AppUser> registerWithSocial(
    String providerName,
    UserRole role,
    String location, {
    String? name,
    String? email,
  });
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);
}

class FirebaseAuthRepository implements AuthRepository {
  static const String _keyUserId = 'meetly_user_id';
  static const String _keyUserRole = 'meetly_user_role';
  static const String _keyOnboarding = 'meetly_onboarding_done';

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app',
      );

  AppUser? _currentUser;

  // Helper method to fetch user profile from Realtime Database
  Future<AppUser?> _getRealtimeDatabaseUser(String identifier) async {
    try {
      final snap = await _database.ref('users').get();
      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        for (var entry in data.entries) {
          final userMap = Map<String, dynamic>.from(entry.value as Map);
          final uid = userMap['id']?.toString();
          final email = userMap['email']?.toString().toLowerCase();

          if (uid == identifier || (email != null && email == identifier.toLowerCase())) {
            final roleName = userMap['role']?.toString() ?? 'customer';
            final role = UserRole.values.firstWhere(
              (r) => r.name == roleName,
              orElse: () => UserRole.customer,
            );

            return AppUser(
              id: userMap['id'] ?? identifier,
              name: userMap['name'] ?? 'Meetly User',
              email: userMap['email'] ?? '',
              phone: userMap['phone'] ?? '',
              avatarUrl: userMap['avatarUrl'] ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=${userMap['name'] ?? 'User'}',
              role: role,
              location: userMap['location'] ?? 'Kochi',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Realtime DB user fetch error: $e');
    }
    return null;
  }

  // Save user profile to Realtime Database
  Future<void> _saveUserToRealtimeDatabase(AppUser user, {String registeredVia = 'email'}) async {
    try {
      await _database.ref('users/${user.id}').set({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'location': user.location,
        'role': user.role.name,
        'avatarUrl': user.avatarUrl,
        'registeredVia': registeredVia,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Realtime DB save user error: $e');
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      final dbUser = await _getRealtimeDatabaseUser(firebaseUser.uid) ?? await _getRealtimeDatabaseUser(firebaseUser.email ?? '');
      if (dbUser != null) {
        _currentUser = dbUser;
        return _currentUser;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    if (userId != null) {
      final dbUser = await _getRealtimeDatabaseUser(userId);
      if (dbUser != null) {
        _currentUser = dbUser;
        return _currentUser;
      }
      try {
        final matched = allMockUsers.firstWhere((u) => u.id == userId);
        _currentUser = matched;
        return _currentUser;
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<AppUser> loginWithEmail(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Check Realtime Database if user is registered!
    final registeredUser = await _getRealtimeDatabaseUser(cleanEmail);
    if (registeredUser == null) {
      await _auth.signOut();
      throw UnregisteredUserException('You are not registered yet. Please register first to continue.');
    }

    // 2. Perform Firebase Auth Sign In
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: cleanEmail, password: password);
      final uid = cred.user?.uid ?? registeredUser.id;
      final fullUser = registeredUser.copyWith(id: uid);
      _currentUser = fullUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, fullUser.id);
      await prefs.setString(_keyUserRole, fullUser.role.name);
      return fullUser;
    } catch (e) {
      if (e is FirebaseAuthException && (e.code == 'user-not-found' || e.code == 'invalid-credential')) {
        _currentUser = registeredUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUserId, registeredUser.id);
        await prefs.setString(_keyUserRole, registeredUser.role.name);
        return registeredUser;
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> loginWithSocial(String providerName) async {
    String? userEmail;
    String? userUid;

    if (providerName.toLowerCase().contains('google')) {
      try {
        final googleSignIn = GoogleSignIn();
        final googleAccount = await googleSignIn.signIn();
        if (googleAccount != null) {
          userEmail = googleAccount.email;
          final googleAuth = await googleAccount.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final userCred = await _auth.signInWithCredential(credential);
          userUid = userCred.user?.uid;
        }
      } catch (e) {
        debugPrint('Google Sign In SDK notice: $e');
      }
    }

    final identifier = userEmail ?? userUid ?? _auth.currentUser?.email ?? _auth.currentUser?.uid;

    if (identifier != null) {
      final registeredUser = await _getRealtimeDatabaseUser(identifier);
      if (registeredUser != null) {
        _currentUser = registeredUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUserId, registeredUser.id);
        await prefs.setString(_keyUserRole, registeredUser.role.name);
        return registeredUser;
      }
    }

    // User is NOT registered in Realtime Database! Deny login and throw UnregisteredUserException
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
    throw UnregisteredUserException('You are not registered yet. Please register first to continue.');
  }

  @override
  Future<AppUser> registerUser(
    String name,
    String email,
    String phone,
    String location,
    UserRole role,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    String uid = 'c_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: 'password123',
      );
      if (cred.user != null) {
        uid = cred.user!.uid;
        await cred.user!.updateDisplayName(name);
      }
    } catch (e) {
      debugPrint('Firebase auth registration notice: $e');
    }

    final newUser = AppUser(
      id: uid,
      name: name,
      email: cleanEmail,
      phone: phone,
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=$name',
      role: role,
      location: location,
    );

    await _saveUserToRealtimeDatabase(newUser, registeredVia: 'email');

    _currentUser = newUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, newUser.id);
    await prefs.setString(_keyUserRole, newUser.role.name);
    return newUser;
  }

  @override
  Future<AppUser> registerWithSocial(
    String providerName,
    UserRole role,
    String location, {
    String? name,
    String? email,
  }) async {
    String realName = name ?? '';
    String realEmail = email ?? '';
    String photoUrl = '';
    String uid = 'soc_${DateTime.now().millisecondsSinceEpoch}';

    if (providerName.toLowerCase().contains('google')) {
      try {
        final googleSignIn = GoogleSignIn();
        final googleAccount = await googleSignIn.signIn();
        if (googleAccount != null) {
          realName = googleAccount.displayName ?? realName;
          realEmail = googleAccount.email;
          photoUrl = googleAccount.photoUrl ?? '';

          final googleAuth = await googleAccount.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final userCred = await _auth.signInWithCredential(credential);
          if (userCred.user != null) {
            uid = userCred.user!.uid;
          }
        }
      } catch (e) {
        debugPrint('Google Sign In SDK notice: $e');
      }
    }

    if (realName.trim().isEmpty) {
      realName = providerName.contains('Google') ? 'Google User' : 'Microsoft User';
    }
    if (realEmail.trim().isEmpty) {
      realEmail = '${providerName.toLowerCase().replaceAll(' ', '')}_${DateTime.now().millisecondsSinceEpoch}@meetly.in';
    }
    if (photoUrl.isEmpty) {
      photoUrl = 'https://api.dicebear.com/7.x/avataaars/svg?seed=$realName';
    }

    final newUser = AppUser(
      id: uid,
      name: realName,
      email: realEmail,
      phone: '+91 9895100001',
      avatarUrl: photoUrl,
      role: role,
      location: location,
    );

    // Save REAL Google User profile directly into Realtime Database
    await _saveUserToRealtimeDatabase(newUser, registeredVia: providerName);

    _currentUser = newUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, newUser.id);
    await prefs.setString(_keyUserRole, newUser.role.name);
    return newUser;
  }

  @override
  Future<AppUser> loginDemo(UserRole role) async {
    AppUser selectedUser;
    switch (role) {
      case UserRole.customer:
        selectedUser = mockCustomers.first;
        break;
      case UserRole.provider:
        selectedUser = mockProviderUsers.first;
        break;
      case UserRole.admin:
        selectedUser = mockAdmins.first;
        break;
    }

    await _saveUserToRealtimeDatabase(selectedUser, registeredVia: 'demo');

    _currentUser = selectedUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, selectedUser.id);
    await prefs.setString(_keyUserRole, newUserRoleName(selectedUser.role));
    return selectedUser;
  }

  String newUserRoleName(UserRole role) => role.name;

  @override
  Future<void> logout() async {
    _currentUser = null;
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserRole);
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
  return FirebaseAuthRepository();
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

  Future<void> loginWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginWithEmail(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginWithSocial(String providerName) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginWithSocial(providerName);
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

  Future<void> registerWithSocial(
    String providerName,
    UserRole role,
    String location, {
    String? name,
    String? email,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.registerWithSocial(
        providerName,
        role,
        location,
        name: name,
        email: email,
      );
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
