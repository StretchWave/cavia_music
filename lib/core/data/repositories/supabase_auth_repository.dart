import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/result/result.dart';
import '../../domain/result/app_error.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient? client;
  final StreamController<Profile> _profileController = StreamController<Profile>.broadcast();
  Profile _currentProfile = Profile.guest();
  StreamSubscription<AuthState>? _authSubscription;

  SupabaseAuthRepository({this.client}) {
    if (client != null) {
      _initAuthListener();
    }
  }

  void _initAuthListener() {
    final c = client;
    if (c == null) return;

    final session = c.auth.currentSession;
    if (session != null && !session.isExpired) {
      _currentProfile = _mapUserToProfile(session.user);
    } else {
      _currentProfile = Profile.guest();
    }

    _authSubscription = c.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null && (data.event == AuthChangeEvent.signedIn || data.event == AuthChangeEvent.tokenRefreshed)) {
        _currentProfile = _mapUserToProfile(user);
      } else if (data.event == AuthChangeEvent.signedOut) {
        _currentProfile = Profile.guest();
      }
      _profileController.add(_currentProfile);
    });
  }

  Profile _mapUserToProfile(User user) {
    final meta = user.userMetadata;
    final displayName = meta?['display_name'] as String? ??
        (user.email != null && user.email!.contains('@') ? user.email!.split('@').first : 'Cavia Listener');

    return Profile(
      id: user.id,
      displayName: displayName,
      email: user.email,
      avatarUrl: meta?['avatar_url'] as String?,
      isGuest: false,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  @override
  Stream<Profile> watchCurrentProfile() {
    return _profileController.stream;
  }

  @override
  Profile get currentProfile => _currentProfile;

  @override
  Future<Result<Profile, AppError>> signInWithPassword(String email, String password) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      return const Result.failure(ValidationError('Email and password cannot be empty.'));
    }

    final c = client;
    if (c == null) {
      // Local fallback for offline mode or test harness
      _currentProfile = Profile(
        id: 'usr_${trimmedEmail.hashCode.abs()}',
        displayName: trimmedEmail.split('@').first,
        email: trimmedEmail,
        isGuest: false,
        createdAt: DateTime.now(),
      );
      _profileController.add(_currentProfile);
      return Result.success(_currentProfile);
    }

    try {
      final response = await c.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Result.failure(ValidationError('Invalid email or password.'));
      }

      _currentProfile = _mapUserToProfile(user);
      _profileController.add(_currentProfile);
      return Result.success(_currentProfile);
    } on AuthException catch (e) {
      return Result.failure(ValidationError(e.message, details: e.statusCode ?? 'auth_error'));
    } catch (e, st) {
      return Result.failure(DatabaseError(
        userMessage: "Couldn't sign in. Please verify credentials.",
        details: 'Sign in exception: $e',
        cause: st,
      ));
    }
  }

  @override
  Future<Result<Profile, AppError>> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.length < 6) {
      return const Result.failure(ValidationError('Valid email and password (min 6 chars) required.'));
    }

    final c = client;
    if (c == null) {
      _currentProfile = Profile(
        id: 'usr_${trimmedEmail.hashCode.abs()}',
        displayName: displayName ?? trimmedEmail.split('@').first,
        email: trimmedEmail,
        isGuest: false,
        createdAt: DateTime.now(),
      );
      _profileController.add(_currentProfile);
      return Result.success(_currentProfile);
    }

    try {
      final response = await c.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      final user = response.user;
      if (user == null) {
        return const Result.failure(DatabaseError(
          userMessage: 'Account creation failed. Please try again.',
          details: 'Empty user returned on signUp',
        ));
      }

      _currentProfile = _mapUserToProfile(user);
      _profileController.add(_currentProfile);
      return Result.success(_currentProfile);
    } on AuthException catch (e) {
      return Result.failure(ValidationError(e.message, details: e.statusCode ?? 'auth_error'));
    } catch (e, st) {
      return Result.failure(DatabaseError(
        userMessage: 'Account creation failed.',
        details: 'Sign up exception: $e',
        cause: st,
      ));
    }
  }

  @override
  Future<Result<void, AppError>> signOut() async {
    try {
      final c = client;
      if (c != null) {
        await c.auth.signOut();
      }
      // Revert to Guest mode while strictly preserving all local database records
      _currentProfile = Profile.guest();
      _profileController.add(_currentProfile);
      return const Result.success(null);
    } catch (e, st) {
      // Even if remote sign out fails, local app transitions to guest safely
      _currentProfile = Profile.guest();
      _profileController.add(_currentProfile);
      return Result.failure(DatabaseError(details: 'Sign out failed: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> resetPassword(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return const Result.failure(ValidationError('Email cannot be empty.'));
    }

    final c = client;
    if (c == null) return const Result.success(null);

    try {
      await c.auth.resetPasswordForEmail(trimmed);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ValidationError(e.message));
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Password reset failed: $e', cause: st));
    }
  }

  @override
  Future<Result<Profile, AppError>> restoreSession() async {
    final c = client;
    if (c == null) {
      return Result.success(_currentProfile);
    }

    try {
      final session = c.auth.currentSession;
      if (session == null || session.isExpired) {
        _currentProfile = Profile.guest();
        _profileController.add(_currentProfile);
        return Result.success(_currentProfile);
      }

      _currentProfile = _mapUserToProfile(session.user);
      _profileController.add(_currentProfile);
      return Result.success(_currentProfile);
    } catch (e) {
      _currentProfile = Profile.guest();
      _profileController.add(_currentProfile);
      return Result.success(_currentProfile);
    }
  }

  @override
  Future<Result<void, AppError>> deleteAccount() async {
    final c = client;
    if (c == null) {
      _currentProfile = Profile.guest();
      _profileController.add(_currentProfile);
      return const Result.success(null);
    }

    try {
      // Invoke cloud function to cascade cleanup server-side
      await c.rpc('delete_user_account');
      await c.auth.signOut();
      _currentProfile = Profile.guest();
      _profileController.add(_currentProfile);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(
        userMessage: "Couldn't delete account. Please try again.",
        details: 'Account deletion failed: $e',
        cause: st,
      ));
    }
  }

  void dispose() {
    _authSubscription?.cancel();
    _profileController.close();
  }
}
