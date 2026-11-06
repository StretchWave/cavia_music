import 'dart:convert';

enum SyncEntityType {
  playlist,
  playlistEntry,
  likedTrack,
  preference,
}

enum SyncOperationType {
  create,
  update,
  delete,
  reorder,
}

/// Represents an atomic, idempotent mutation staged in the local outbox.
class SyncOperation {
  final String id;
  final String profileId;
  final String deviceId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operationType;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final String? lastError;
  final String idempotencyKey;

  const SyncOperation({
    required this.id,
    required this.profileId,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastAttemptAt,
    this.lastError,
    required this.idempotencyKey,
  });

  String get payloadJson => jsonEncode(payload);

  SyncOperation copyWith({
    String? id,
    String? profileId,
    String? deviceId,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperationType? operationType,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
    DateTime? lastAttemptAt,
    String? lastError,
    String? idempotencyKey,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      deviceId: deviceId ?? this.deviceId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }
}

