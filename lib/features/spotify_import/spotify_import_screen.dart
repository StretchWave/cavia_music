import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/glass_container.dart';
import '../../core/components/japanese_scenery_background.dart';
import '../../core/components/artwork_view.dart';
import '../../core/state/library_controller.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/spotify/spotify_models.dart';
import '../../core/spotify/spotify_oauth_service.dart';
import '../../core/spotify/spotify_playlist_client.dart';
import '../../core/spotify/spotify_import_coordinator.dart';
import '../../core/spotify/spotify_url_parser.dart';
import '../../core/domain/result/result.dart';
import '../../core/domain/result/app_error.dart';
import '../../core/domain/models/track.dart';
import '../../core/domain/models/playlist.dart';
import '../../core/domain/models/playlist_entry.dart';
import '../../core/domain/repositories/track_repository.dart';
import '../../core/domain/repositories/playlist_repository.dart';
import '../playlists/playlist_detail_screen.dart';

enum ImportState {
  initial,
  invalid,
  loadingPreview,
  previewReady,
  importing,
  completed,
  failed,
}

class SpotifyImportScreen extends StatefulWidget {
  final SpotifyImportCoordinator? coordinator;

  const SpotifyImportScreen({super.key, this.coordinator});

  @override
  State<SpotifyImportScreen> createState() => _SpotifyImportScreenState();
}

class _SpotifyImportScreenState extends State<SpotifyImportScreen> {
  final TextEditingController _urlController = TextEditingController();
  ImportState _state = ImportState.initial;
  String? _errorMessage;
  ImportPreview? _preview;
  ImportSummary? _summary;
  double _importProgress = 0.0;
  bool _skipDuplicates = true;
  bool _skipUnmatched = false;

  late final SpotifyImportCoordinator _coordinator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.coordinator != null) {
      _coordinator = widget.coordinator!;
    } else {
      final library = AppStateScope.libraryOf(context);
      final oauth = SpotifyOAuthService();
      final client = SpotifyPlaylistClient(oAuthService: oauth);
      final tRepo = library.trackRepository ?? _FallbackTrackRepo();
      final pRepo = library.playlistRepository ?? _FallbackPlaylistRepo();
      _coordinator = SpotifyImportCoordinator(
        client: client,
        trackRepository: tRepo,
        playlistRepository: pRepo,
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _loadSamplePreview() {
    final sampleMeta = SpotifyPlaylistMetadata(
      id: '37i9dQZF1DXdbXrPNafg9d',
      name: 'Tokyo Electronic Sanctuary',
      description: 'Atmospheric electronic & future beats from Tokyo.',
      artworkUrl: 'assets/images/cover_zenith.jpg',
      ownerName: 'Spotify Curators',
      totalTracks: 5,
      isCollaborative: false,
      isPublic: true,
    );

    final sampleTracks = [
      const SpotifyTrackItem(
        id: 'sp_1',
        name: 'Afterglow',
        artist: 'Luna Caine',
        album: 'Nocturne Whispers',
        duration: Duration(minutes: 4, seconds: 9),
        artworkUrl: 'assets/images/cover_afterglow.jpg',
        isPlayable: true,
      ),
      const SpotifyTrackItem(
        id: 'sp_2',
        name: 'Zenith',
        artist: 'Kenshi Yonezu',
        album: 'Floating Realm',
        duration: Duration(minutes: 3, seconds: 45),
        artworkUrl: 'assets/images/cover_zenith.jpg',
        isPlayable: true,
      ),
      const SpotifyTrackItem(
        id: 'sp_3',
        name: 'Shinjuku Neon',
        artist: 'Tokyo Electric',
        album: 'Metropolis Nights',
        duration: Duration(minutes: 3, seconds: 20),
        artworkUrl: 'assets/images/cover_shrine.jpg',
        isPlayable: true,
      ),
      const SpotifyTrackItem(
        id: 'sp_4',
        name: 'Misty Bamboo',
        artist: 'Ryuichi Sakamoto',
        album: 'Forest Solitude',
        duration: Duration(minutes: 4, seconds: 15),
        artworkUrl: 'assets/images/cover_mist_mountain.jpg',
        isPlayable: true,
      ),
      const SpotifyTrackItem(
        id: 'sp_5',
        name: 'Torii Lake Echoes',
        artist: 'Nujabes',
        album: 'Spiritual State',
        duration: Duration(minutes: 5, seconds: 2),
        artworkUrl: 'assets/images/cover_crimson_sun.jpg',
        isPlayable: true,
      ),
    ];

    final matches = sampleTracks.map((t) {
      final isMatch = t.id == 'sp_1' || t.id == 'sp_2';
      return TrackMatchResult(
        spotifyTrack: t,
        matchedTrackId: isMatch ? (t.id == 'sp_1' ? 'song_1' : 'song_2') : null,
        confidence: isMatch ? MatchConfidence.highConfidence : MatchConfidence.unmatched,
        matchReason: isMatch ? 'Sample metadata match' : 'No local match',
      );
    }).toList();

    setState(() {
      _preview = ImportPreview(
        metadata: sampleMeta,
        tracks: sampleTracks,
        matches: matches,
        matchedCount: 2,
        unmatchedCount: 3,
        duplicateCount: 0,
        unsupportedCount: 0,
      );
      _state = ImportState.previewReady;
      _errorMessage = null;
    });
  }

  void _connectSpotifyBrowser() async {
    final oauth = SpotifyOAuthService();
    final uri = await oauth.createAuthorizationUrl();
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _loadPreview() async {
    final text = _urlController.text.trim();
    final parseResult = SpotifyUrlParser.parsePlaylistId(text);
    if (parseResult.isFailure) {
      setState(() {
        _state = ImportState.invalid;
        _errorMessage = parseResult.errorOrNull?.userMessage;
      });
      return;
    }

    setState(() {
      _state = ImportState.loadingPreview;
      _errorMessage = null;
    });

    final previewResult = await _coordinator.loadPreview(inputUrl: text);

    if (!mounted) return;

    if (previewResult.isFailure) {
      setState(() {
        _state = ImportState.failed;
        _errorMessage = previewResult.errorOrNull?.userMessage ??
            "Spotify didn't provide track details for this playlist.";
      });
      return;
    }

    setState(() {
      _preview = previewResult.dataOrNull;
      _state = ImportState.previewReady;
    });
  }

  void _startImport(LibraryController library) async {
    if (_preview == null) return;

    setState(() {
      _state = ImportState.importing;
      _importProgress = 0.0;
    });

    final options = ImportOptions(
      destinationPlaylistName: _preview!.metadata.name,
      skipDuplicates: _skipDuplicates,
      skipUnmatched: _skipUnmatched,
    );

    final importResult = await _coordinator.executeImport(
      preview: _preview!,
      options: options,
      onProgress: (imported, total) {
        if (!mounted) return;
        setState(() {
          _importProgress = total > 0 ? (imported / total).clamp(0.0, 1.0) : 1.0;
        });
      },
    );

    if (!mounted) return;

    if (importResult.isFailure) {
      setState(() {
        _state = ImportState.failed;
        _errorMessage = importResult.errorOrNull?.userMessage ?? 'Import interrupted.';
      });
      return;
    }

    setState(() {
      _summary = importResult.dataOrNull;
      _state = ImportState.completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const JapaneseSceneryBackground(
            imageAsset: 'assets/images/bg_search.jpg',
            opacity: 0.4,
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: CaviaColors.textIvory,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Spotify Playlist Import',
                        style: CaviaTypography.display.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ),

                // Main Workflow Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildWorkflowContent(context, library),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowContent(BuildContext context, LibraryController library) {
    switch (_state) {
      case ImportState.initial:
      case ImportState.invalid:
        return _buildInputState();

      case ImportState.loadingPreview:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: CaviaColors.vermilionBright),
              const SizedBox(height: 20),
              Text(
                'Resolving Spotify metadata & tracks...',
                style: CaviaTypography.body,
              ),
            ],
          ),
        );

      case ImportState.previewReady:
        return _buildPreviewState(library);

      case ImportState.importing:
        return Center(
          child: GlassContainer(
            radius: CaviaGlass.radiusCard,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_download_rounded,
                  size: 48,
                  color: CaviaColors.vermilionBright,
                ),
                const SizedBox(height: 16),
                Text(
                  'Matching & Ingesting Tracks',
                  style: CaviaTypography.display.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_importProgress * 100).toInt()}% completed',
                  style: CaviaTypography.caption,
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _importProgress,
                  backgroundColor: CaviaColors.glassSurface,
                  color: CaviaColors.vermilionBright,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        );

      case ImportState.completed:
        return _buildCompletedState(library);

      case ImportState.failed:
        final isAuthIssue = _errorMessage?.contains('Spotify') == true || _errorMessage?.contains('Reconnect') == true;

        return Center(
          child: GlassContainer(
            radius: CaviaGlass.radiusCard,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: CaviaColors.errorRed),
                const SizedBox(height: 16),
                Text('Import Failed', style: CaviaTypography.display.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? "Couldn't complete import.",
                  style: CaviaTypography.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (isAuthIssue) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                    label: const Text('Connect Spotify in Browser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CaviaColors.vermilion,
                      foregroundColor: CaviaColors.textIvory,
                    ),
                    onPressed: _connectSpotifyBrowser,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _loadSamplePreview,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CaviaColors.textIvory,
                      side: const BorderSide(color: CaviaColors.glassBorder),
                    ),
                    child: const Text('Preview Sample Playlist'),
                  ),
                  const SizedBox(height: 4),
                ],
                TextButton(
                  onPressed: () => setState(() => _state = ImportState.initial),
                  child: const Text('Try Again', style: TextStyle(color: CaviaColors.textSilver)),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildInputState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GlassContainer(
          radius: CaviaGlass.radiusCard,
          blur: CaviaGlass.blurHeavy,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.music_note_rounded, color: CaviaColors.vermilionBright),
                  const SizedBox(width: 10),
                  Text(
                    'Paste Playlist URL or URI',
                    style: CaviaTypography.songTitle,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                style: const TextStyle(color: CaviaColors.textIvory),
                decoration: InputDecoration(
                  hintText: 'https://open.spotify.com/playlist/...',
                  hintStyle: const TextStyle(color: CaviaColors.textDim),
                  filled: true,
                  fillColor: CaviaColors.glassSurface,
                  errorText: _errorMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: CaviaColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: CaviaColors.vermilionBright),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ActionChip(
                    label: const Text('Use Sample Tokyo Playlist URL'),
                    labelStyle: const TextStyle(color: CaviaColors.textSilver, fontSize: 12),
                    backgroundColor: CaviaColors.glassSurface,
                    side: const BorderSide(color: CaviaColors.glassBorderSubtle),
                    onPressed: () {
                      _urlController.text = 'https://open.spotify.com/playlist/37i9dQZF1DXdbXrPNafg9d';
                      setState(() {
                        _state = ImportState.initial;
                        _errorMessage = null;
                      });
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.flash_on_rounded, size: 14, color: CaviaColors.vermilionBright),
                    label: const Text('Instant Demo Preview'),
                    labelStyle: const TextStyle(color: CaviaColors.vermilionBright, fontSize: 12, fontWeight: FontWeight.w600),
                    backgroundColor: CaviaColors.glassSurface,
                    side: BorderSide(color: CaviaColors.vermilionBright.withValues(alpha: 0.5)),
                    onPressed: _loadSamplePreview,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadPreview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CaviaColors.vermilion,
                    foregroundColor: CaviaColors.textIvory,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Fetch Playlist Preview'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewState(LibraryController library) {
    final preview = _preview!;
    final meta = preview.metadata;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Playlist Card
          GlassContainer(
            radius: CaviaGlass.radiusCard,
            blur: CaviaGlass.blurHeavy,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ArtworkView(
                  imageAsset: meta.artworkUrl ?? 'assets/images/cover_shrine_gate.jpg',
                  width: 72,
                  height: 72,
                  radius: 12,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.name,
                        style: CaviaTypography.songTitleLarge.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${meta.ownerName} • ${preview.tracks.length} tracks',
                        style: CaviaTypography.caption,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Spotify Catalog Metadata',
                        style: CaviaTypography.caption.copyWith(color: CaviaColors.textDim),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Matching Breakdown Card
          GlassContainer(
            radius: CaviaGlass.radiusCard,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MATCHING SUMMARY', style: CaviaTypography.sectionLabel),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Matched with local catalog', style: CaviaTypography.body),
                    Text(
                      '${preview.matchedCount}',
                      style: CaviaTypography.body.copyWith(
                        color: CaviaColors.vermilionBright,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Unmatched tracks', style: CaviaTypography.body),
                    Text('${preview.unmatchedCount}', style: CaviaTypography.caption),
                  ],
                ),
                if (preview.duplicateCount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duplicate entries in playlist', style: CaviaTypography.body),
                      Text('${preview.duplicateCount}', style: CaviaTypography.caption),
                    ],
                  ),
                ],
                const Divider(color: CaviaColors.glassBorderSubtle, height: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Skip duplicate tracks', style: CaviaTypography.caption),
                  value: _skipDuplicates,
                  activeThumbColor: CaviaColors.vermilionBright,
                  onChanged: (v) => setState(() => _skipDuplicates = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Skip unmatched tracks', style: CaviaTypography.caption),
                  value: _skipUnmatched,
                  activeThumbColor: CaviaColors.vermilionBright,
                  onChanged: (v) => setState(() => _skipUnmatched = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Confirmation Button (Never commits before this tap)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startImport(library),
              style: ElevatedButton.styleFrom(
                backgroundColor: CaviaColors.vermilion,
                foregroundColor: CaviaColors.textIvory,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Confirm & Import ${preview.tracks.length} Tracks',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCompletedState(LibraryController library) {
    final summary = _summary;
    final message = summary?.userMessage ?? 'Import completed.';
    final unmatched = summary?.unmatchedMessage;

    return Center(
      child: GlassContainer(
        radius: CaviaGlass.radiusCard,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 56,
              color: CaviaColors.vermilionBright,
            ),
            const SizedBox(height: 16),
            Text(
              'Import Finished',
              style: CaviaTypography.display.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: CaviaTypography.body.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (unmatched != null) ...[
              const SizedBox(height: 6),
              Text(
                unmatched,
                style: CaviaTypography.caption.copyWith(color: CaviaColors.textSilver),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final created = library.playlists.firstWhere(
                  (p) => p.name == summary?.playlistName,
                  orElse: () => library.playlists.first,
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaylistDetailScreen(playlistId: created.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CaviaColors.vermilion,
                foregroundColor: CaviaColors.textIvory,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('View Imported Playlist'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackTrackRepo implements TrackRepository {
  @override
  Future<Result<List<Track>, AppError>> getAllTracks({String? profileId}) async =>
      const Result.success([]);
  @override
  Stream<List<Track>> watchTracks({String? profileId}) => const Stream.empty();
  @override
  Stream<List<Track>> watchLikedTracks({String? profileId}) => const Stream.empty();
  @override
  Future<Result<Track, AppError>> getTrackById(String id, {String? profileId}) async =>
      const Result.failure(NotFoundError('Fallback'));
  @override
  Future<Result<bool, AppError>> isTrackLiked(String trackId, {String? profileId}) async =>
      const Result.success(false);
  @override
  Future<Result<bool, AppError>> toggleLike(String trackId, {String? profileId}) async =>
      const Result.success(false);
  @override
  Future<Result<void, AppError>> updatePlayStats(String trackId, Duration position, {String? profileId}) async =>
      const Result.success(null);
  @override
  Future<Result<void, AppError>> insertTrack(Track track, {String? profileId}) async =>
      const Result.success(null);
}

class _FallbackPlaylistRepo implements PlaylistRepository {
  @override
  Stream<List<Playlist>> watchPlaylists({String? profileId}) => const Stream.empty();
  @override
  Future<Result<List<Playlist>, AppError>> getAllPlaylists({String? profileId}) async =>
      const Result.success([]);
  @override
  Future<Result<Playlist, AppError>> getPlaylistById(String id, {String? profileId}) async =>
      const Result.failure(NotFoundError('Fallback'));
  @override
  Stream<List<PlaylistEntry>> watchPlaylistEntries(String playlistId) => const Stream.empty();
  @override
  Future<Result<List<PlaylistEntry>, AppError>> getPlaylistEntries(String playlistId) async =>
      const Result.success([]);
  @override
  Future<Result<Playlist, AppError>> createPlaylist(
    String name, {
    String description = '',
    List<String>? initialTrackIds,
    String? profileId,
  }) async =>
      Result.success(Playlist(
        id: 'pl_fallback',
        name: name,
        description: description,
        artworkAsset: '',
        songs: const [],
        createdAt: DateTime.now(),
      ));
  @override
  Future<Result<void, AppError>> editPlaylist(
    String playlistId, {
    String? name,
    String? description,
    String? artworkUri,
  }) async =>
      const Result.success(null);
  @override
  Future<Result<void, AppError>> deletePlaylist(String playlistId) async =>
      const Result.success(null);
  @override
  Future<Result<PlaylistEntry, AppError>> addTrackToPlaylist(
    String playlistId,
    String trackId,
  ) async =>
      Result.success(PlaylistEntry(
        id: 'pe_fallback',
        playlistId: playlistId,
        trackId: trackId,
        position: 0,
        dateAdded: DateTime.now(),
      ));
  @override
  Future<Result<void, AppError>> removeTrackFromPlaylist(
    String playlistId,
    String entryId,
  ) async =>
      const Result.success(null);
  @override
  Future<Result<void, AppError>> reorderPlaylistEntries(
    String playlistId,
    int oldPosition,
    int newPosition,
  ) async =>
      const Result.success(null);
}

