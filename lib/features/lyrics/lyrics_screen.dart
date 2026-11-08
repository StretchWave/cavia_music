import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/cavia_glass_surface.dart';
import '../../core/components/cavia_feedback_states.dart';
import '../../core/components/animated_play_pause.dart';
import '../../core/lyrics/lrclib_service.dart';
import '../../core/models/music_models.dart';
import '../../core/state/app_state_scope.dart';

/// Redesigned Lyrics Screen: Measured Precision Scrolling × User Manual Scroll Respect.
class LyricsScreen extends StatefulWidget {
  final VoidCallback onClose;

  const LyricsScreen({super.key, required this.onClose});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final ScrollController _scrollController = ScrollController();
  final LrcLibService _lyricsService = LrcLibService();

  List<LyricLine>? _fetchedLyrics;
  bool _isLoading = false;
  String? _loadedSongId;
  int _lastActiveIndex = -1;
  bool _isSyncedMode = true;

  // Manual scroll detection & auto-resume
  bool _userScrolledManually = false;
  Timer? _resumeSyncTimer;

  // GlobalKeys per line to measure exact rendered position
  final Map<int, GlobalKey> _lineKeys = {};

  @override
  void dispose() {
    _resumeSyncTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLyrics(Song song) async {
    setState(() => _isLoading = true);
    final lyrics = await _lyricsService.fetchLyrics(
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
    );
    if (mounted && _loadedSongId == song.id) {
      setState(() {
        _fetchedLyrics = lyrics;
        _isLoading = false;
      });
    }
  }

  void _scrollToActive(int index) {
    if (_userScrolledManually || index == _lastActiveIndex || !_scrollController.hasClients) {
      return;
    }
    _lastActiveIndex = index;

    final key = _lineKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        alignment: 0.35,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
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

  void _onUserScrolled() {
    if (!_userScrolledManually) {
      setState(() => _userScrolledManually = true);
    }
    _resumeSyncTimer?.cancel();
    _resumeSyncTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _userScrolledManually = false);
      }
    });
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
            backgroundColor: CaviaColors.background,
            body: Center(
              child: Text(
                'No track playing',
                style: CaviaTypography.titleMedium,
              ),
            ),
          );
        }

        if (_loadedSongId != song.id) {
          _loadedSongId = song.id;
          _fetchedLyrics = null;
          _lineKeys.clear();
          _lastActiveIndex = -1;
          _userScrolledManually = false;
          if (song.lyrics.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _loadLyrics(song);
            });
          }
        }

        final lyrics = song.lyrics.isNotEmpty ? song.lyrics : (_fetchedLyrics ?? []);
        final activeIndex = _findActiveIndex(lyrics, playback.currentPosition);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isSyncedMode && activeIndex >= 0 && !_userScrolledManually) {
            _scrollToActive(activeIndex);
          }
        });

        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: Stack(
            children: [
              // Header
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                        color: CaviaColors.textIvory,
                        onPressed: widget.onClose,
                        tooltip: 'Close lyrics',
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              song.title,
                              style: CaviaTypography.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist,
                              style: CaviaTypography.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isSyncedMode ? Icons.sync_rounded : Icons.subject_rounded,
                          color: CaviaColors.vermilionBright,
                          size: 22,
                        ),
                        tooltip: _isSyncedMode ? 'Synced Mode' : 'Plain Text Mode',
                        onPressed: () => setState(() => _isSyncedMode = !_isSyncedMode),
                      ),
                    ],
                  ),
                ),
              ),

              // Lyrics List Content
              Positioned.fill(
                top: 80,
                bottom: 100,
                child: _isLoading
                    ? const CaviaLoadingState(message: 'Fetching synchronized lyrics...')
                    : lyrics.isEmpty
                        ? const CaviaEmptyState(
                            icon: Icons.lyrics_outlined,
                            title: 'No Lyrics Found',
                            subtitle: 'Lyrics are not available for this track yet.',
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is UserScrollNotification) {
                                _onUserScrolled();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
                              itemCount: lyrics.length,
                              itemBuilder: (context, index) {
                                final line = lyrics[index];
                                final isActive = _isSyncedMode && index == activeIndex;
                                final key = _lineKeys.putIfAbsent(index, () => GlobalKey());

                                return Padding(
                                  key: key,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_isSyncedMode) {
                                        playback.seekToSeconds(line.timestamp.inSeconds);
                                      }
                                    },
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 250),
                                      style: isActive
                                          ? CaviaTypography.lyricActive
                                          : CaviaTypography.lyricInactive,
                                      child: Text(
                                        line.text,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),

              // Floating "Resume Sync" pill when user scrolled manually
              if (_userScrolledManually && _isSyncedMode && activeIndex >= 0)
                Positioned(
                  bottom: 104,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _userScrolledManually = false);
                        _scrollToActive(activeIndex);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: CaviaColors.overlaySheet,
                          borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
                          border: Border.all(color: CaviaColors.vermilionBright),
                          boxShadow: [
                            BoxShadow(
                              color: CaviaColors.vermilion.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sync_rounded, color: CaviaColors.vermilionBright, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Resume Sync',
                              style: TextStyle(
                                color: CaviaColors.vermilionBright,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Compact Bottom Control Bar
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: CaviaGlassSurface(
                  radius: CaviaGlass.radiusPill,
                  blur: CaviaGlass.blurHeavy,
                  surfaceColor: CaviaColors.glassSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, size: 26),
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
                        icon: const Icon(Icons.skip_next_rounded, size: 26),
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
