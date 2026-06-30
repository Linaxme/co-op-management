import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../firebase_providers.dart';
import 'auth_service.dart';
import 'auth_session.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthSession>> {
  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthService _authService;

  void _init() {
    _authService.authStateChanges.listen((user) async {
      state = const AsyncValue.loading();
      try {
        final session = await _authService.resolveSession(user);
        state = AsyncValue.data(session);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  Future<void> signInAdmin(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final session = await _authService.signInAdmin(
        email: email,
        password: password,
      );
      state = AsyncValue.data(session);
    } on AuthException {
      state = const AsyncValue.data(AuthSession.unauthenticated);
      rethrow;
    } catch (e, st) {
      debugPrint('signInAdmin error: $e\n$st');
      state = const AsyncValue.data(AuthSession.unauthenticated);
      rethrow;
    }
  }

  Future<void> signInMember(
    String phone,
    String password, {
    String? shortName,
    String? coopCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final session = await _authService.signInMember(
        phone: phone,
        password: password,
        shortName: shortName,
        coopCode: coopCode,
      );
      state = AsyncValue.data(session);
    } on AuthException {
      state = const AsyncValue.data(AuthSession.unauthenticated);
      rethrow;
    } catch (e, st) {
      debugPrint('signInMember error: $e\n$st');
      state = const AsyncValue.data(AuthSession.unauthenticated);
      rethrow;
    }
  }

  Future<void> signUpCooperative({
    required String organizationName,
    required String organizationAddress,
    required String organizationShortName,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final session = await _authService.signUpCooperative(
        organizationName: organizationName,
        organizationAddress: organizationAddress,
        organizationShortName: organizationShortName,
        email: email,
        password: password,
      );
      state = AsyncValue.data(session);
    } on AuthException {
      state = const AsyncValue.data(AuthSession.unauthenticated);
      rethrow;
    } catch (e, st) {
      debugPrint('signUpCooperative error: $e\n$st');
      state = const AsyncValue.data(AuthSession.unauthenticated);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(AuthSession.unauthenticated);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthSession>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

final authSessionProvider = Provider<AuthSession>((ref) {
  return ref.watch(authProvider).value ?? AuthSession.unauthenticated;
});

final userRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(authSessionProvider).role;
});

final currentMemberUuidProvider = Provider<String?>((ref) {
  return ref.watch(authSessionProvider).memberUuid;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authSessionProvider).isAdmin;
});

final isMemberProvider = Provider<bool>((ref) {
  return ref.watch(authSessionProvider).isMember;
});

final currentCoopCodeProvider = Provider<String?>((ref) {
  return ref.watch(authSessionProvider).coopCode;
});

/// Notifies GoRouter when auth state changes.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthSession>>(authProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

final authRefreshNotifierProvider = Provider<AuthRefreshNotifier>((ref) {
  return AuthRefreshNotifier(ref);
});
