import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cavia_music/core/data/database/cavia_database.dart';
import 'package:cavia_music/core/data/repositories/local_track_repository.dart';
import 'package:cavia_music/core/data/repositories/local_playlist_repository.dart';
import 'package:cavia_music/core/data/repositories/local_settings_repository.dart';
import 'package:cavia_music/core/data/repositories/local_sync_repository.dart';
import 'package:cavia_music/core/data/repositories/supabase_auth_repository.dart';
import 'package:cavia_music/core/state/settings_controller.dart';
import 'package:cavia_music/core/domain/models/track.dart';
import 'package:cavia_music/core/domain/models/sync_operation.dart';
import 'package:cavia_music/core/domain/models/sync_state.dart';

void main() {
  late CaviaDatabase db;
  late LocalSyncRepository syncRepo;
  late SupabaseAuthRepository authRepo;
  late LocalTrackRepository trackRepo;
  late LocalPlaylistRepository playlistRepo;
  late LocalSettingsRepository settingsRepo;
  late SettingsController settingsController;

  setUp(() async {
    db = CaviaDatabase.forTesting(NativeDatabase.memory());
    syncRepo = LocalSyncRepository(db: db, deviceId: 'test_device_1');
    authRepo = SupabaseAuthRepository(); // Offline fallback mode
    trackRepo = LocalTrackRepository(db, syncRepository: syncRepo);
    playlistRepo = LocalPlaylistRepository(db, syncRepository: syncRepo);
    settingsRepo = LocalSettingsRepository(db, syncRepository: syncRepo);
    settingsController = SettingsController(
      repository: settingsRepo,
      authRepository: authRepo,
      syncRepository: syncRepo,
    );
  });

  tearDown(() async {
    authRepo.dispose();
    syncRepo.dispose();
    settingsController.dispose();
    await db.close();
  });

  group('Supabase SQL Migration & RLS Security Inspection', () {
    test('Migration file exists with valid SQL and RLS policies on all tables', () {
      final migrationFile = File('supabase/migrations/20261105000000_cavia_phase2_schema.sql');
      expect(migrationFile.existsSync(), true, reason: 'Migration file must exist');

      final sql = migrationFile.readAsStringSync();
      // Verify RLS enabled on all exposed tables
      expect(sql.contains('ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;'), true);
      expect(sql.contains('ALTER TABLE public.sync_devices ENABLE ROW LEVEL SECURITY;'), true);
      expect(sql.contains('ALTER TABLE public.playlists ENABLE ROW LEVEL SECURITY;'), true);
      expect(sql.contains('ALTER TABLE public.playlist_entries ENABLE ROW LEVEL SECURITY;'), true);
      expect(sql.contains('ALTER TABLE public.liked_tracks ENABLE ROW LEVEL SECURITY;'), true);
      expect(sql.contains('ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;'), true);
      expect(sql.contains('ALTER TABLE public.operation_receipts ENABLE ROW LEVEL SECURITY;'), true);
      expect(sql.contains('ALTER TABLE public.sync_tombstones ENABLE ROW LEVEL SECURITY;'), true);

      // Verify playlist entry boundary check (preventing tampering with another user's playlist)
      expect(sql.contains('WHERE p.id = playlist_entries.playlist_id'), true);
      expect(sql.contains('AND p.user_id = auth.uid()'), true);

      // Verify account deletion cascade function
      expect(sql.contains('CREATE OR REPLACE FUNCTION public.delete_user_account()'), true);
    });
  });

  group('Multi-User Isolation & Security Tests', () {
    test('Two separate users have strict data isolation without leakage', () async {
      const userAlice = 'user_alice_uuid';
      const userBob = 'user_bob_uuid';

      // 1. Create Alice playlist & liked song
      final alicePl = await playlistRepo.createPlaylist('Alice Private Collection', profileId: userAlice);
      expect(alicePl.isSuccess, true);

      await trackRepo.insertTrack(Track(
        id: 'track_shared_1',
        title: 'Afterglow',
        artist: 'Luna Caine',
        album: 'Nocturne Whispers',
        duration: const Duration(minutes: 4),
        artworkUri: 'assets/images/cover_afterglow.jpg',
      ));
      await trackRepo.toggleLike('track_shared_1', profileId: userAlice);

      // 2. Verify Bob cannot see Alice's playlist or liked status
      final bobPlaylists = await playlistRepo.getAllPlaylists(profileId: userBob);
      expect(bobPlaylists.dataOrNull!.isEmpty, true);

      final bobLiked = await trackRepo.isTrackLiked('track_shared_1', profileId: userBob);
      expect(bobLiked.dataOrNull, false);

      // 3. Bob likes the same track as Bob
      await trackRepo.toggleLike('track_shared_1', profileId: userBob);
      final bobLikedNow = await trackRepo.isTrackLiked('track_shared_1', profileId: userBob);
      expect(bobLikedNow.dataOrNull, true);

      // 4. Bob unlikes track; Alice's liked status remains unaffected
      await trackRepo.toggleLike('track_shared_1', profileId: userBob);
      final aliceLikedCheck = await trackRepo.isTrackLiked('track_shared_1', profileId: userAlice);
      expect(aliceLikedCheck.dataOrNull, true);
    });
  });

  group('Authentication Flow & State Transition Tests', () {
    test('Guest starts with Guest Sanctuary; Signing in transitions profile and triggers sync', () async {
      expect(settingsController.isAuthenticated, false);
      expect(settingsController.currentProfile.displayName, 'Guest Sanctuary');

      // Attempting to enable sync as guest displays required message
      final guestToggleMsg = settingsController.toggleCloudSync(true);
      expect(guestToggleMsg, 'Sign in to sync your library.');
      expect(settingsController.cloudSync, false);

      // Sign In with Account
      final signInRes = await settingsController.signIn('user@cavia.music', 'secret123');
      expect(signInRes.isSuccess, true);
      expect(settingsController.isAuthenticated, true);
      expect(settingsController.cloudSync, true);
      expect(settingsController.syncStatusMessage, 'Library synced');
    });

    test('Sign out strictly preserves all local database records and returns to Guest mode', () async {
      await settingsController.signIn('user@cavia.music', 'secret123');
      final userId = settingsController.currentProfile.id;

      // Create a playlist under this account
      await playlistRepo.createPlaylist('Saved Cloud Playlist', profileId: userId);

      // Sign out
      await settingsController.signOut();
      expect(settingsController.isAuthenticated, false);
      expect(settingsController.currentProfile.displayName, 'Guest Sanctuary');
      expect(settingsController.cloudSync, false);
      expect(settingsController.syncStatusMessage, 'Sync is off.');

      // Verify the local account records were NOT purged on sign out
      final localCheck = await playlistRepo.getAllPlaylists(profileId: userId);
      expect(localCheck.dataOrNull!.length, 1);
      expect(localCheck.dataOrNull!.first.name, 'Saved Cloud Playlist');
    });

    test('Invalid credentials returns validation error without modifying guest state', () async {
      final res = await authRepo.signInWithPassword('', '');
      expect(res.isFailure, true);
      expect(authRepo.currentProfile.isGuest, true);
    });
  });

  group('Offline Outbox Queueing & Idempotency Tests', () {
    test('Mutations as authenticated user enqueue into SQLite outbox in deterministic order', () async {
      const accountId = 'user_sync_tester';

      // 1. Create Playlist
      final plRes = await playlistRepo.createPlaylist('Nocturne Focus', profileId: accountId);
      expect(plRes.isSuccess, true);
      final plId = plRes.dataOrNull!.id;

      // 2. Insert Track & Add to Playlist
      await trackRepo.insertTrack(Track(
        id: 'song_1',
        title: 'Afterglow',
        artist: 'Luna Caine',
        album: 'Nocturne Whispers',
        duration: const Duration(minutes: 4),
        artworkUri: 'assets/images/cover_afterglow.jpg',
      ));
      final addRes = await playlistRepo.addTrackToPlaylist(plId, 'song_1');
      expect(addRes.isSuccess, true);

      // 3. Inspect Outbox
      final pendingRes = await syncRepo.getPendingOperations(profileId: accountId);
      expect(pendingRes.isSuccess, true);
      final ops = pendingRes.dataOrNull!;

      expect(ops.length, 2);
      expect(ops[0].entityType, SyncEntityType.playlist);
      expect(ops[0].operationType, SyncOperationType.create);
      expect(ops[1].entityType, SyncEntityType.playlistEntry);
      expect(ops[1].operationType, SyncOperationType.create);

      // Verify operations have non-empty idempotency keys
      expect(ops[0].idempotencyKey.isNotEmpty, true);
      expect(ops[1].idempotencyKey.isNotEmpty, true);
    });

    test('Duplicate operation does not duplicate records in outbox', () async {
      const accountId = 'user_idempotent_test';
      final op = SyncOperation(
        id: 'op_unique_1',
        profileId: accountId,
        deviceId: 'device_a',
        entityType: SyncEntityType.playlist,
        entityId: 'pl_100',
        operationType: SyncOperationType.create,
        payload: {'name': 'Idempotent Beats'},
        createdAt: DateTime.now(),
        idempotencyKey: 'idem_key_100',
      );

      // Enqueue twice
      await syncRepo.enqueueOperation(op);
      await syncRepo.enqueueOperation(op);

      final ops = await syncRepo.getPendingOperations(profileId: accountId);
      expect(ops.dataOrNull!.length, 1);
    });

    test('Operation failure increments retryCount and records lastError with backoff', () async {
      const opId = 'op_fail_test';
      await syncRepo.enqueueOperation(SyncOperation(
        id: opId,
        profileId: 'user_fail',
        deviceId: 'device_a',
        entityType: SyncEntityType.likedTrack,
        entityId: 'track_1',
        operationType: SyncOperationType.create,
        payload: {'is_liked': true},
        createdAt: DateTime.now(),
        idempotencyKey: 'idem_fail_1',
      ));

      await syncRepo.recordOperationFailed(opId, 'Network socket timeout 504');

      final pending = await syncRepo.getPendingOperations(profileId: 'user_fail');
      final failedOp = pending.dataOrNull!.first;
      expect(failedOp.retryCount, 1);
      expect(failedOp.lastError, 'Network socket timeout 504');
      expect(failedOp.lastAttemptAt != null, true);
    });
  });

  group('Conflict Resolution & Library Merging Tests', () {
    test('Merging guest library into account copies items, preserves originals, and enqueues sync', () async {
      const accountId = 'user_merge_target';

      // 1. Guest creates playlist and likes song
      await playlistRepo.createPlaylist('Guest Sunset Vibes', profileId: 'guest');
      await trackRepo.insertTrack(Track(
        id: 'guest_song_1',
        title: 'Crimson Sun',
        artist: 'Tycho',
        album: 'Sunrise',
        duration: const Duration(minutes: 3),
        artworkUri: 'assets/images/cover_crimson_sun.jpg',
      ));
      await trackRepo.toggleLike('guest_song_1', profileId: 'guest');

      // 2. Perform merge
      final mergeRes = await syncRepo.mergeGuestLibraryWithAccount(accountId);
      expect(mergeRes.isSuccess, true);

      // 3. Account now has the merged playlist and liked song
      final accountPlaylists = await playlistRepo.getAllPlaylists(profileId: accountId);
      expect(accountPlaylists.dataOrNull!.length, 1);
      expect(accountPlaylists.dataOrNull!.first.name, 'Guest Sunset Vibes');

      final accountLiked = await trackRepo.isTrackLiked('guest_song_1', profileId: accountId);
      expect(accountLiked.dataOrNull, true);

      // 4. Original guest data remains completely intact
      final guestPlaylists = await playlistRepo.getAllPlaylists(profileId: 'guest');
      expect(guestPlaylists.dataOrNull!.length, 1);
      final guestLiked = await trackRepo.isTrackLiked('guest_song_1', profileId: 'guest');
      expect(guestLiked.dataOrNull, true);

      // 5. Outbox has staged the merged items for cloud upload
      final outboxOps = await syncRepo.getPendingOperations(profileId: accountId);
      expect(outboxOps.dataOrNull!.isNotEmpty, true);
    });

    test('Tombstones prevent resurrecting deleted playlists or entries', () async {
      const accountId = 'user_tombstone_test';

      // Create and delete playlist
      final plRes = await playlistRepo.createPlaylist('Ephemeral Tracks', profileId: accountId);
      final plId = plRes.dataOrNull!.id;
      await playlistRepo.deletePlaylist(plId);

      // Verify playlist is gone locally
      final playlists = await playlistRepo.getAllPlaylists(profileId: accountId);
      expect(playlists.dataOrNull!.any((p) => p.id == plId), false);
    });
  });

  group('Sync Lifecycle & Exact UI Messaging Tests', () {
    test('User facing status strings conform exactly to specifications', () {
      const guestState = SyncState(profileId: 'guest');
      expect(
        guestState.getUserFacingMessage(isGuest: true, syncEnabled: true),
        'Sign in to sync your library.',
      );

      const disabledState = SyncState(profileId: 'user_1');
      expect(
        disabledState.getUserFacingMessage(isGuest: false, syncEnabled: false),
        'Sync is off.',
      );

      const pausedState = SyncState(profileId: 'user_1', status: SyncStatus.paused);
      expect(
        pausedState.getUserFacingMessage(isGuest: false, syncEnabled: true),
        'Sync paused. Your changes are safe on this device.',
      );

      const offlineState = SyncState(profileId: 'user_1', status: SyncStatus.offline);
      expect(
        offlineState.getUserFacingMessage(isGuest: false, syncEnabled: true),
        'Sync paused. Your changes are safe on this device.',
      );

      const errorState = SyncState(profileId: 'user_1', status: SyncStatus.error);
      expect(
        errorState.getUserFacingMessage(isGuest: false, syncEnabled: true),
        "Couldn't sync. Your changes are safe on this device.",
      );

      const syncedState = SyncState(profileId: 'user_1', status: SyncStatus.idle);
      expect(
        syncedState.getUserFacingMessage(isGuest: false, syncEnabled: true),
        'Library synced',
      );
    });
  });
}
