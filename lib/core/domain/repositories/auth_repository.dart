import '../models/profile.dart';
import '../result/result.dart';
import '../result/app_error.dart';

abstract class AuthRepository {
  /// Stream emitting user profile changes (guest or authenticated).
  Stream<Profile> watchCurrentProfile();

  /// Current profile (defaults to guest if signed out).
  Profile get currentProfile;

  /// Signs in with email and password.
  Future<Result<Profile, AppError>> signInWithPassword(String email, String password);

  /// Signs up a new account.
  Future<Result<Profile, AppError>> signUp(
    String email,
    String password, {
    String? displayName,
  });

  /// Signs out of the active account and transitions back to Guest profile.
  /// IMPORTANT: Never clears or deletes local device library data!
  Future<Result<void, AppError>> signOut();

  /// Sends a password reset request.
  Future<Result<void, AppError>> resetPassword(String email);

  /// Restores existing session from local secure storage if valid.
  Future<Result<Profile, AppError>> restoreSession();

  /// Deletes user cloud account and cascades server-side data cleanup.
  /// Local files and local guest data are preserved.
  Future<Result<void, AppError>> deleteAccount();
}

