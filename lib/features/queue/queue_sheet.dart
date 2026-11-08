import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/cavia_glass_surface.dart';
import '../../core/components/cavia_artwork.dart';
import '../../core/state/app_state_scope.dart';

/// Draggable modal playback queue sheet.
class QueueSheet extends StatelessWidget {
  final VoidCallback? onClose;

  const QueueSheet({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) {
        final current = playback.currentSong;
        final queue = playback.queue;

        return CaviaGlassSurface(
          radius: CaviaGlass.radiusLarge,
          blur: CaviaGlass.blurHeavy,
          surfaceColor: CaviaColors.overlaySheet,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 4, bottom: 12),
                  decoration: BoxDecoration(
                    color: CaviaColors.glassHighlight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Queue (${queue.length})',
                    style: CaviaTypography.titleMedium.copyWith(fontSize: 17),
                  ),
                  if (onClose != null)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: CaviaColors.textSilver, size: 20),
                      onPressed: onClose,
                      tooltip: 'Close queue',
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Currently Playing Card
              if (current != null) ...[
                const Text('NOW PLAYING', style: CaviaTypography.overline),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CaviaColors.vermilion.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(CaviaGlass.radiusMedium),
                    border: Border.all(
                      color: CaviaColors.vermilionBright.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      CaviaArtwork(
                        imageAsset: current.artworkAsset,
                        width: 44,
                        height: 44,
                        radius: 8,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              current.title,
                              style: CaviaTypography.titleSmall.copyWith(
                                color: CaviaColors.vermilionBright,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              current.artist,
                              style: CaviaTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.equalizer_rounded,
                        color: CaviaColors.vermilionBright,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Up Next Header & Clear Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('UP NEXT', style: CaviaTypography.overline),
                  if (queue.isNotEmpty)
                    TextButton(
                      onPressed: playback.clearQueue,
                      child: const Text(
                        'Clear Queue',
                        style: TextStyle(
                          color: CaviaColors.vermilionBright,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Reorderable Queue List
              Expanded(
                child: queue.isEmpty
                    ? Center(
                        child: Text(
                          'No upcoming tracks in queue',
                          style: CaviaTypography.caption.copyWith(color: CaviaColors.textSilver),
                        ),
                      )
                    : ReorderableListView.builder(
                        itemCount: queue.length,
                        // ignore: deprecated_member_use
                        onReorder: (oldIdx, newIdx) => playback.reorderQueue(oldIdx, newIdx),
                        itemBuilder: (context, index) {
                          final song = queue[index];
                          final isCurrent = song.id == current?.id;

                          return ListTile(
                            key: ValueKey('${song.id}_$index'),
                            contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            leading: CaviaArtwork(
                              imageAsset: song.artworkAsset,
                              width: 40,
                              height: 40,
                              radius: 8,
                            ),
                            title: Text(
                              song.title,
                              style: CaviaTypography.titleSmall.copyWith(
                                color: isCurrent ? CaviaColors.vermilionBright : CaviaColors.textIvory,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: CaviaTypography.caption,
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
                                  tooltip: 'Remove',
                                ),
                                const Icon(
                                  Icons.drag_handle_rounded,
                                  color: CaviaColors.textSilver,
                                  size: 18,
                                ),
                              ],
                            ),
                            onTap: () => playback.playNow(song),
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
