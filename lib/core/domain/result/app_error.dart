/// Domain and database errors for Cavia Music.
sealed class AppError {
  final String userMessage;
  final String debugDetails;
  final Object? cause;

  const AppError({
    required this.userMessage,
    required this.debugDetails,
    this.cause,
  });

  @override
  String toString() => '$runtimeType: $userMessage ($debugDetails)';
}

/// Validation failure (e.g. empty playlist name, invalid URL).
final class ValidationError extends AppError {
  const ValidationError(String message, {String details = 'Validation failed', super.cause})
      : super(userMessage: message, debugDetails: details);
}

/// Requested entity not found in storage.
final class NotFoundError extends AppError {
  const NotFoundError(String message, {String details = 'Entity not found', super.cause})
      : super(userMessage: message, debugDetails: details);
}

/// Entity already exists or duplicate violation.
final class DuplicateError extends AppError {
  const DuplicateError(String message, {String details = 'Duplicate entity', super.cause})
      : super(userMessage: message, debugDetails: details);
}

/// Database read/write/transaction failure.
final class DatabaseError extends AppError {
  const DatabaseError({
    super.userMessage = "Couldn't save changes",
    String details = 'Database operation failed',
    super.cause,
  }) : super(debugDetails: details);
}

/// Local file system or cache storage failure.
final class StorageError extends AppError {
  const StorageError({
    super.userMessage = 'Storage unavailable',
    String details = 'File I/O or storage limit reached',
    super.cause,
  }) : super(debugDetails: details);
}

/// Operation prohibited by system rules (e.g. deleting system Liked Songs).
final class OperationProhibitedError extends AppError {
  const OperationProhibitedError(String message, {String details = 'Operation prohibited', super.cause})
      : super(userMessage: message, debugDetails: details);
}
