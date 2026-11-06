enum SyncStatus {
  idle,
  syncing,
  paused,
  error,
  offline,
}

class SyncState {
  final String profileId;
  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final int pendingCount;
  final String? lastError;

  const SyncState({
    required this.profileId,
    this.status = SyncStatus.idle,
    this.lastSyncedAt,
    this.pendingCount = 0,
    this.lastError,
  });

  /// User-facing status string conforming strictly to Cavia specifications:
  /// - `Sign in to sync your library.`
  /// - `Sync is off.`
  /// - `Sync paused. Your changes are safe on this device.`
  /// - `Couldn't sync. Your changes are safe on this device.`
  /// - `Library synced`
  String getUserFacingMessage({required bool isGuest, required bool syncEnabled}) {
    if (isGuest && syncEnabled) {
      return 'Sign in to sync your library.';
    }
    if (!syncEnabled) {
      return 'Sync is off.';
    }
    switch (status) {
      case SyncStatus.offline:
      case SyncStatus.paused:
        return 'Sync paused. Your changes are safe on this device.';
      case SyncStatus.error:
        return "Couldn't sync. Your changes are safe on this device.";
      case SyncStatus.syncing:
        return 'Syncing library...';
      case SyncStatus.idle:
        return 'Library synced';
    }
  }

  SyncState copyWith({
    String? profileId,
    SyncStatus? status,
    DateTime? lastSyncedAt,
    int? pendingCount,
    String? lastError,
  }) {
    return SyncState(
      profileId: profileId ?? this.profileId,
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: lastError ?? this.lastError,
    );
  }
}

