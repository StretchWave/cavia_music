import '../models/app_preferences.dart';
import '../result/result.dart';
import '../result/app_error.dart';

abstract class SettingsRepository {
  Future<AppPreferences> getPreferences();
  Stream<AppPreferences> watchPreferences();
  Future<Result<void, AppError>> updatePreferences(AppPreferences preferences);
  Future<Result<void, AppError>> clearCache();
}

