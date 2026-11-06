import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../models/music_models.dart';
import '../state/app_state_scope.dart';
import 'artwork_view.dart';
import 'glass_container.dart';
import 'toast.dart';

class TrackContextMenu {
  static void show(BuildContext context, Song song) {
    final library = AppStateScope.libraryOf(context);
    final playback = AppStateScope.playbackOf(context);
    final isLiked = library.isSongLiked(song.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return GlassContainer(
          radius: CaviaGlass.radiusLarge,
          blur: CaviaGlass.blurHeavy,
          surfaceColor: CaviaColors.overlaySheet,
          margin: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: CaviaColors.textSilver.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Song Preview Header
              Row(
                children: [
                  ArtworkView(
                    imageAsset: song.artworkAsset,
                    width: 52,
                    height: 52,
                    radius: 12,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: CaviaTypography.songTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${song.artist} • ${song.album}',
                          style: CaviaTypography.artistSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (song.isCached)
                    const Icon(
                      Icons.offline_pin_rounded,
                      color: CaviaColors.vermilionBright,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: CaviaColors.glassBorderSubtle, height: 1),
              const SizedBox(height: 8),

              // Actions
              _ActionTile(
                icon: Icons.playlist_play_rounded,
                label: 'Play Next',
                onTap: () {
                  Navigator.pop(ctx);
                  playback.addToQueue(song);
                  CaviaToast.show(context, 'Playing next in queue');
                },
              ),
              _ActionTile(
                icon: Icons.queue_music_rounded,
                label: 'Add to Queue',
                onTap: () {
                  Navigator.pop(ctx);
                  playback.addToQueue(song);
                  CaviaToast.show(context, 'Added to queue');
                },
              ),
              _ActionTile(
                icon: isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: isLiked ? 'Remove from Liked' : 'Save to Liked Songs',
                iconColor: isLiked ? CaviaColors.vermilionBright : null,
                onTap: () {
                  Navigator.pop(ctx);
                  library.toggleLikeSong(song);
                  CaviaToast.show(
                    context,
                    isLiked ? 'Removed from Liked Songs' : 'Saved to Liked Songs',
                    icon: Icons.favorite_rounded,
                  );
                },
              ),
              _ActionTile(
                icon: Icons.playlist_add_rounded,
                label: 'Add to Playlist...',
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddToPlaylistSheet(context, song);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void _showAddToPlaylistSheet(BuildContext context, Song song) {
    final library = AppStateScope.libraryOf(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return GlassContainer(
          radius: CaviaGlass.radiusLarge,
          blur: CaviaGlass.blurHeavy,
          surfaceColor: CaviaColors.overlaySheet,
          margin: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to Playlist',
                style: CaviaTypography.display.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ...library.playlists.map(
                (pl) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ArtworkView(
                    imageAsset: pl.artworkAsset,
                    width: 44,
                    height: 44,
                    radius: 8,
                  ),
                  title: Text(pl.name, style: CaviaTypography.songTitle),
                  subtitle: Text(
                    '${pl.songs.length} tracks',
                    style: CaviaTypography.caption,
                  ),
                  trailing: const Icon(
                    Icons.add_rounded,
                    color: CaviaColors.textSilver,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    library.addSongToPlaylist(pl.id, song);
                    CaviaToast.show(context, 'Added to ${pl.name}');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(
        icon,
        color: iconColor ?? CaviaColors.textIvory,
        size: 22,
      ),
      title: Text(
        label,
        style: CaviaTypography.body.copyWith(
          color: iconColor ?? CaviaColors.textIvory,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

