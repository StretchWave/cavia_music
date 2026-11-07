import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/result/result.dart';
import '../../domain/result/app_error.dart';

/// Supabase-backed authentication.
///
/// This repository never fabricates a successful sign-in. When cloud
/// credentials are absent from the build (no [client]) every network-backed
/// flow fails honestly with a user-facing explanation, and the app remains in
/// guest mode. Signing out always preserves local data.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({this.client}) {
    if (client != null) {
      _initAuthListener();
    }
  }

  final SupabaseClient? client;
  final StreamController<Profile> _profileController =
      StreamController<Profile>.broadcast();
  Profile _currentProfile = Profile.guest();
  StreamSubscription<AuthState>? _authSubscription;

  static const String _notConfiguredMessage =
      'Cloud sync is not configured on this build. '
      'Sign in requires the Supabase URL and key to be provided.';

  void _initAuthListener() {
    final c = client;
    if (c == null) return;

    final session = c.auth.currentSession;
    _currentProfile = _profileFor(session?.user);

    _authSubscription = c.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          final user = data.session?.user;
          if (user != null) {
            _currentProfile = _profileFor(user);
          }
          break;
        case AuthChangeEvent.signedOut:
          _currentProfile = Profile.guest();
          break;
        default:
          break;
      }
      _profileController.add(_currentProfile);
    });
  }

  Profile _profileFor(User? user) {
    if (user == null) return Profile.guest();
    final meta = user.userMetadata;
    final displayName = (meta?['display_name'] as String?)?.trim();
    final email = user.email;
    final fallback = (email != null && email.contains('@'))
        ? email.split('@').first
        : 'Cavia Listener';

    return Profile(
      id: user.id,
      displayName: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : fallback,
      email: email,
      avatarUrl: meta?['avatar_url'] as String?,
      isGuest: false,
      createdAt: DateTime.tryParse(user.createdAt)?.toUtc() ??
          DateTime.timestamp(),
    );
  }

  @override
  Stream<Profile> watchCurrentProfile() => _profileController.stream;

  @override
  Profile get currentProfile => _currentProfile;

  @override
  Future<Result<Profile, AppError>> signInWithPassword(
    String email,
    String password,
  ) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      return const Result.failure(
        ValidationError('Email and password cannot be empty.'),
      );
    }

    final c = client;
    if (c == null) {
      return const Result.failure(ValidationError(_notConfiguredMessage));
    }

    try {
      final response = await c.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );

      final user = response.user;
      if (user == null || response.session == null) {
        return const Result.failure(ValidationError('Invalid email or password.'));
      }

      _currentProfile = _profileFor(user);
      _profileController.add(_currentProfile);
      return Result.success(_currentProfile);
    } on AuthException catch (e) {
      return Result.failure(ValidationError(
        e.message, details: e.statusCode ?? 'auth_error',
      ));
    } catch (e, st) {
      return Result.failure(DatabaseError(
        userMessage:
            "Couldn't sign in. Please verify your connection and credentials.",
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
      return const Result.failure(
        ValidationError('Valid email and password (min 6 chars) required.'),
      );
    }

    final c = client;
    if (c == null) {
      return const Result.failure(ValidationError(_notConfiguredMessage));
    }

    try {
      final response = await c.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: {
          if (displayName != null && displayName.trim().isNotEmpty)
            'display_name': displayName.trim(),
        },
      );

      if (response.user == null) {
        return const Result.failure(DatabaseError(
          userMessage: 'Account creation failed. Please try again.',
          details: 'Empty user returned on signUp',
        ));
      }

      final user = response.user!;
      if (response.session == null) {
        // Email confirmation is enabled on this project: the account exists,
        // but no session is issued yet. Report that honestly instead of
        // implying a signed-in state.
        return Result.failure(ValidationError(
          'Account created. Check your email to confirm it before signing in.',
          details: 'signup_confirmation_required',
        ));
      }

      _currentProfile = _profileFor(user);
      _profileController.add(_currentProfile);
      return Result.success(_currentProfile);
    } on AuthException catch (e) {
      return Result.failure(ValidationError(
        e.message, details: e.statusCode ?? 'auth_error',
      ));
    } catch (e, st) {
      return Result.failure(DatabaseError(
        userMessage: 'Account creation failed. Please try again.',
        details: 'Sign up exception: $e',
        cause: st,
      ));
    }
  }

  @override
  Future<Result<void, AppError>> signOut() async {
    final c = client;
    try {
      if (c != null) {
        await c.auth.signOut();
      }
      // Always transition to guest locally; local data is never touched.
      _currentProfile = Profile.guest();
      _profileController.add(_currentProfile);
      return const Result.success(null);
    } catch (e, st) {
      // Sign-out failure leaves the session intact: report it truthfully.
      return Result.failure(DatabaseError(
        userMessage: "Couldn't sign out. Please try again.",
        details: 'Sign out failed: $e',
        cause: st,
      ));
    }
  }

  @override
  Future<Result<void, AppError>> resetPassword(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return const Result.failure(ValidationError('Email cannot be empty.'));
    }

    final c = client;
    if (c == null) {
      return const Result.failure(ValidationError(_notConfiguredMessage));
    }

    try {
      await c.auth.resetPasswordForEmail(trimmed);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(ValidationError(e.message));
    } catch (e, st) {
      return Result.failure(DatabaseError(
        userMessage: "Couldn't send the reset email. Please try again.",
        details: 'Password reset failed: $e',
        cause: st,
      ));
    }
  }

  @override
  Future<Result<Profile, AppError>> restoreSession() async {
    final c = client;
    if (c == null) {
      // No cloud on this build: guest mode is the truthful state.
      return Result.success(_currentProfile);
    }

    // supabase_flutter transparently refreshes stored sessions during
    // startup; the persisted session is the authority here.
    final session = c.auth.currentSession;
    if (session == null) {
      _currentProfile = Profile.guest();
      _profileController.add(_currentProfile);
      return Result.success(_currentProfile);
    }

    _currentProfile = _profileFor(session.user);
    _profileController.add(_currentProfile);
    return Result.success(_currentProfile);
  }

  @override
  Future<Result<void, AppError>> deleteAccount() async {
    final c = client;
    if (c == null) {
      return const Result.failure(ValidationError(
        'Cloud sync is not configured on this build. '
        'There is no cloud account to delete.',
      ));
    }

    final user = c.auth.currentUser;
    if (user == null) {
      return const Result.failure(ValidationError(
        'Sign in first to delete your cloud account.',
        details: 'delete_account_requires_auth',
      ));
    }

    try {
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
