import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/glass_container.dart';
import '../../core/components/artwork_view.dart';
import '../../core/state/app_state_scope.dart';

class QueueSheet extends StatelessWidget {
  final VoidCallback onClose;

  const QueueSheet({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) {
        final current = playback.currentSong;
        final queue = playback.queue;

        return GlassContainer(
          radius: CaviaGlass.radiusLarge,
          blur: CaviaGlass.blurHeavy,
          surfaceColor: CaviaColors.overlaySheet,
          margin: const EdgeInsets.only(top: 60),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Playback Queue',
                    style: CaviaTypography.display.copyWith(fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: CaviaColors.textSilver),
                    onPressed: onClose,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Currently Playing Section (hidden honestly when nothing plays)
              if (current == null) ...[
                Text(
                  'NOTHING PLAYING',
                  style: CaviaTypography.sectionLabel.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  radius: CaviaGlass.radiusMedium,
                  surfaceColor: CaviaColors.overlaySheet,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.music_note_outlined,
                        color: CaviaColors.textSilver,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Nothing is queued. Add songs to start.',
                          style: CaviaTypography.artistSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Text(
                  'NOW PLAYING',
                  style: CaviaTypography.sectionLabel.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 8),
                GlassContainer(
                  radius: CaviaGlass.radiusMedium,
                  surfaceColor: CaviaColors.vermilion.withValues(alpha: 0.12),
                  borderColor: CaviaColors.vermilionBright.withValues(alpha: 0.5),
                  glow: true,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ArtworkView(
                        imageAsset: current.artworkAsset,
                        width: 48,
                        height: 48,
                        radius: 10,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current.title,
                              style: CaviaTypography.songTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              current.artist,
                              style: CaviaTypography.artistSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.graphic_eq_rounded,
                        color: CaviaColors.vermilionBright,
                        size: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Up Next Header & Clear Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'UP NEXT',
                    style: CaviaTypography.sectionLabel.copyWith(fontSize: 11),
                  ),
                  TextButton(
                    onPressed: playback.clearQueue,
                    child: Text(
                      'Clear Queue',
                      style: CaviaTypography.caption.copyWith(
                        color: CaviaColors.vermilionBright,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Reorderable Queue List
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: queue.length,
                  onReorderItem: (oldIdx, newIdx) => playback.reorderQueue(oldIdx, newIdx),
                  itemBuilder: (context, index) {
                    final song = queue[index];
                    final isCurrent = song.id == current?.id;

                    return ListTile(
                      key: ValueKey(song.id),
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: ArtworkView(
                        imageAsset: song.artworkAsset,
                        width: 42,
                        height: 42,
                        radius: 8,
                      ),
                      title: Text(
                        song.title,
                        style: CaviaTypography.songTitle.copyWith(
                          color: isCurrent
                              ? CaviaColors.vermilionBright
                              : CaviaColors.textIvory,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        song.artist,
                        style: CaviaTypography.artistSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                              size: 18,
                              color: CaviaColors.textDim,
                            ),
                            onPressed: () => playback.removeFromQueue(index),
                          ),
                          const Icon(
                            Icons.drag_handle_rounded,
                            color: CaviaColors.textSilver,
                            size: 20,
                          ),
                        ],
                      ),
                      onTap: () {
                        playback.playNow(song);
                      },
                    );
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
