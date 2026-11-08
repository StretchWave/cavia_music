import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/cavia_artwork.dart';
import '../../core/components/cavia_album_card.dart';
import '../../core/components/cavia_track_row.dart';
import '../../core/components/cavia_section_header.dart';
import '../../core/components/cavia_feedback_states.dart';
import '../../core/components/toast.dart';
import '../../core/models/music_models.dart';
import '../../core/state/app_state_scope.dart';
import '../albums/album_detail_screen.dart';

/// Redesigned Artist Detail Screen: Circular Hero Portrait × Discography Browser.
class ArtistDetailScreen extends StatelessWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);
    final playback = AppStateScope.playbackOf(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.38).clamp(260.0, 340.0);
    final portraitSize = (heroHeight * 0.44).clamp(100.0, 130.0);

    return ListenableBuilder(
      listenable: Listenable.merge([library, playback]),
      builder: (context, _) {
        final currentArtist = library.artists.firstWhere(
          (a) => a.id == artist.id,
          orElse: () => artist,
        );

        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: heroHeight,
                pinned: true,
                backgroundColor: CaviaColors.background.withValues(alpha: 0.9),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  color: CaviaColors.textIvory,
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TextButton.icon(
                      onPressed: () {
                        library.toggleFollowArtist(currentArtist.id);
                        CaviaToast.show(
                          context,
                          currentArtist.isFollowed
                              ? 'Unfollowed ${currentArtist.name}'
                              : 'Following ${currentArtist.name}',
                          icon: Icons.check_rounded,
                        );
                      },
                      icon: Icon(
                        currentArtist.isFollowed
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                        size: 16,
                        color: currentArtist.isFollowed
                            ? CaviaColors.vermilionBright
                            : CaviaColors.textIvory,
                      ),
                      label: Text(
                        currentArtist.isFollowed ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: currentArtist.isFollowed
                              ? CaviaColors.vermilionBright
                              : CaviaColors.textIvory,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: currentArtist.isFollowed
                            ? CaviaColors.vermilionSubtle
                            : CaviaColors.glassSurface,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
                          side: BorderSide(
                            color: currentArtist.isFollowed
                                ? CaviaColors.vermilionBright
                                : CaviaColors.glassBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 36),
                        Container(
                          width: portraitSize,
                          height: portraitSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: currentArtist.isFollowed
                                  ? CaviaColors.vermilionBright
                                  : CaviaColors.glassBorderSubtle,
                              width: 2.0,
                            ),
                            boxShadow: [
                              if (currentArtist.isFollowed)
                                BoxShadow(
                                  color: CaviaColors.vermilion.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                ),
                            ],
                          ),
                          child: ClipOval(
                            child: CaviaArtwork(
                              imageAsset: currentArtist.portraitAsset,
                              radius: 999,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentArtist.name,
                          style: CaviaTypography.displayMedium.copyWith(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentArtist.popularSongs.length} tracks • ${currentArtist.albums.length} albums',
                          style: CaviaTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Popular Tracks Section
              if (currentArtist.popularSongs.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: CaviaSectionHeader(title: 'Popular Tracks'),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = currentArtist.popularSongs[index];
                      final isCurrent = playback.currentSong?.id == song.id;

                      return CaviaTrackRow(
                        track: song,
                        index: index,
                        showIndex: true,
                        isCurrent: isCurrent,
                        isPlaying: isCurrent && playback.isPlaying,
                        onTap: () => playback.playQueue(
                          currentArtist.popularSongs,
                          initialIndex: index,
                        ),
                      );
                    },
                    childCount: currentArtist.popularSongs.length,
                  ),
                ),
              ] else
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CaviaEmptyState(
                      icon: Icons.music_note_rounded,
                      title: 'No Tracks Available',
                      subtitle: 'No popular tracks found for this artist.',
                    ),
                  ),
                ),

              // Albums Section
              if (currentArtist.albums.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: CaviaSectionHeader(title: 'Albums & Releases'),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: currentArtist.albums.length,
                      itemBuilder: (context, index) {
                        final album = currentArtist.albums[index];
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: CaviaAlbumCard(
                            album: album,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AlbumDetailScreen(album: album),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }
}
