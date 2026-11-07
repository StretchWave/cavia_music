import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/glass_container.dart';
import '../../core/components/japanese_scenery_background.dart';
import '../../core/components/animated_play_pause.dart';
import '../../core/models/music_models.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/lyrics/lrclib_service.dart';

class LyricsScreen extends StatefulWidget {
  final VoidCallback onClose;

  const LyricsScreen({super.key, required this.onClose});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final ScrollController _scrollController = ScrollController();
  final LrcLibService _lyricsService = LrcLibService();
  bool _isSyncedMode = true;
  int _lastActiveIndex = -1;

  String? _loadedSongId;
  List<LyricLine>? _fetchedLyrics;
  bool _isLoadingLyrics = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDynamicLyrics(Song song) async {
    setState(() => _isLoadingLyrics = true);
    final fetched = await _lyricsService.fetchLyrics(
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
    );
    if (!mounted || _loadedSongId != song.id) return;
    setState(() {
      _fetchedLyrics = fetched ?? [];
      _isLoadingLyrics = false;
    });

    // Cache the successful fetch into the local database so the next session
    // reads lyrics from storage instead of the provider again.
    if (fetched != null && fetched.isNotEmpty) {
      final library = AppStateScope.libraryOf(context);
      final repo = library.trackRepository;
      if (repo != null) {
        await repo.saveLyrics(song.id, fetched);
      }
    }
  }

  void _scrollToActive(int index, int totalLines) {
    if (index == _lastActiveIndex || !_scrollController.hasClients) return;
    _lastActiveIndex = index;

    final targetOffset = (index * 72.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  int _findActiveIndex(List<LyricLine> lyrics, Duration currentPos) {
    if (lyrics.isEmpty) return -1;
    for (int i = lyrics.length - 1; i >= 0; i--) {
      if (currentPos >= lyrics[i].timestamp) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) {
        final song = playback.currentSong;
        if (song == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                const JapaneseSceneryBackground(imageAsset: '', opacity: 0.2),
                SafeArea(
                  child: Center(
                    child: Text(
                      'No lyrics — start a song first',
                      style: CaviaTypography.songTitle,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (_loadedSongId != song.id) {
          _loadedSongId = song.id;
          _fetchedLyrics = null;
          if (song.lyrics.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _loadDynamicLyrics(song);
            });
          }
        }

        final lyrics = song.lyrics.isNotEmpty ? song.lyrics : (_fetchedLyrics ?? []);
        final activeIndex = _findActiveIndex(lyrics, playback.currentPosition);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isSyncedMode && activeIndex >= 0) {
            _scrollToActive(activeIndex, lyrics.length);
          }
        });

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Atmospheric Background
              JapaneseSceneryBackground(
                imageAsset: song.artworkAsset,
                opacity: 0.35,
              ),

              // Header
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
                        color: CaviaColors.textIvory,
                        onPressed: widget.onClose,
                      ),
                      Column(
                        children: [
                          Text(
                            song.title,
                            style: CaviaTypography.songTitle,
                            maxLines: 1,
                          ),
                          Text(
                            song.artist,
                            style: CaviaTypography.artistSubtitle,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          _isSyncedMode ? Icons.sync_rounded : Icons.subject_rounded,
                          color: CaviaColors.vermilionBright,
                        ),
                        tooltip: _isSyncedMode ? 'Synced Mode' : 'Plain Text Mode',
                        onPressed: () {
                          setState(() {
                            _isSyncedMode = !_isSyncedMode;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Lyrics List
              Positioned.fill(
                top: 100,
                bottom: 110,
                child: _isLoadingLyrics
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: CaviaColors.vermilionBright,
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Fetching synced lyrics...',
                              style: CaviaTypography.caption,
                            ),
                          ],
                        ),
                      )
                    : lyrics.isEmpty
                        ? Center(
                            child: Text(
                              'No lyrics available for this track',
                              style: CaviaTypography.artistSubtitle,
                            ),
                          )
                        : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                        itemCount: lyrics.length,
                        itemBuilder: (context, i) {
                          final line = lyrics[i];
                          final isActive = _isSyncedMode && i == activeIndex;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: isActive
                                  ? CaviaTypography.lyricActive.copyWith(
                                      color: CaviaColors.textIvory,
                                      shadows: [
                                        Shadow(
                                          color: CaviaColors.vermilion.withValues(alpha: 0.6),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    )
                                  : CaviaTypography.lyricInactive,
                              child: Text(line.text),
                            ),
                          );
                        },
                      ),
              ),

              // Floating Bottom Controls
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: GlassContainer(
                  radius: CaviaGlass.radiusPill,
                  blur: CaviaGlass.blurHeavy,
                  surfaceColor: CaviaColors.overlaySheet,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded),
                        color: CaviaColors.textIvory,
                        onPressed: playback.skipPrevious,
                      ),
                      AnimatedPlayPauseButton(
                        isPlaying: playback.isPlaying,
                        onTap: playback.togglePlayPause,
                        size: 44,
                        iconSize: 22,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded),
                        color: CaviaColors.textIvory,
                        onPressed: playback.skipNext,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
