import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../core/components/japanese_scenery_background.dart';
import '../../core/components/artwork_view.dart';
import '../../core/components/context_menus.dart';
import '../../core/components/toast.dart';
import '../../core/models/music_models.dart';
import '../../core/state/app_state_scope.dart';
import '../albums/album_detail_screen.dart';

class ArtistDetailScreen extends StatelessWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([library, playback]),
      builder: (context, _) {
        final currentArtist = library.artists.firstWhere(
          (a) => a.id == artist.id,
          orElse: () => artist,
        );

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Atmospheric Background
              JapaneseSceneryBackground(
                imageAsset: currentArtist.portraitAsset,
                opacity: 0.35,
              ),

              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: CaviaColors.background.withValues(
                      alpha: 0.8,
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: CaviaColors.textIvory,
                      onPressed: () => Navigator.pop(context),
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
                                  ? 'Unfollowed artist'
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
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: currentArtist.isFollowed
                                ? CaviaColors.vermilion.withValues(alpha: 0.15)
                                : CaviaColors.glassSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
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
                            const SizedBox(height: 40),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CaviaColors.vermilionBright,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: CaviaColors.vermilion.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: currentArtist.portraitAsset.startsWith('http://') ||
                                        currentArtist.portraitAsset.startsWith('https://')
                                    ? Image.network(
                                        currentArtist.portraitAsset,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: CaviaColors.surfaceDark,
                                          child: const Icon(
                                            Icons.person_rounded,
                                            size: 56,
                                            color: CaviaColors.textSilver,
                                          ),
                                        ),
                                      )
                                    : Image.asset(
                                        currentArtist.portraitAsset,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: CaviaColors.surfaceDark,
                                          child: const Icon(
                                            Icons.person_rounded,
                                            size: 56,
                                            color: CaviaColors.textSilver,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentArtist.name,
                              style: CaviaTypography.display.copyWith(
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Popular Tracks Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Text(
                        'POPULAR TRACKS',
                        style: CaviaTypography.sectionLabel,
                      ),
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = currentArtist.popularSongs[index];
                      final isCurrent =
                          playback.currentSong?.id == song.id;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 2,
                        ),
                        leading: ArtworkView(
                          imageAsset: song.artworkAsset,
                          width: 44,
                          height: 44,
                          radius: 8,
                        ),
                        title: Text(
                          song.title,
                          style: CaviaTypography.songTitle.copyWith(
                            color: isCurrent
                                ? CaviaColors.vermilionBright
                                : CaviaColors.textIvory,
                          ),
                        ),
                        subtitle: Text(
                          song.album,
                          style: CaviaTypography.artistSubtitle,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: CaviaColors.textSilver,
                          ),
                          onPressed: () => TrackContextMenu.show(context, song),
                        ),
                        onTap: () => playback.playQueue(
                          currentArtist.popularSongs,
                          initialIndex: index,
                        ),
                      );
                    }, childCount: currentArtist.popularSongs.length),
                  ),

                  // Albums Section
                  if (currentArtist.albums.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Text(
                          'ALBUMS & RELEASES',
                          style: CaviaTypography.sectionLabel,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: currentArtist.albums.length,
                          itemBuilder: (context, index) {
                            final album = currentArtist.albums[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AlbumDetailScreen(album: album),
                                  ),
                                );
                              },
                              child: Container(
                                width: 140,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ArtworkView(
                                      imageAsset: album.artworkAsset,
                                      width: 140,
                                      height: 140,
                                      radius: 14,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      album.title,
                                      style: CaviaTypography.songTitle.copyWith(
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${album.year}',
                                      style: CaviaTypography.caption,
                                    ),
                                  ],
                                ),
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
            ],
          ),
        );
      },
    );
  }
}
