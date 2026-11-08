import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../app/theme/cavia_glass.dart';
import '../../../app/theme/cavia_typography.dart';
import '../../../core/components/cavia_page_header.dart';
import '../../../core/components/cavia_playlist_card.dart';
import '../../../core/components/cavia_feedback_states.dart';
import '../../../core/responsive/responsive_breakpoints.dart';
import '../../../core/state/app_state_scope.dart';
import '../../playlists/create_playlist_dialog.dart';
import '../../playlists/playlist_detail_screen.dart';

/// Full collection screen for browsing and managing all playlists.
class PlaylistsCollectionScreen extends StatefulWidget {
  const PlaylistsCollectionScreen({super.key});

  @override
  State<PlaylistsCollectionScreen> createState() => _PlaylistsCollectionScreenState();
}

class _PlaylistsCollectionScreenState extends State<PlaylistsCollectionScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);

    return ListenableBuilder(
      listenable: library,
      builder: (context, _) {
        final playlists = library.playlists;

        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CaviaPageHeader(
                  title: 'Playlists',
                  subtitle: '${playlists.length} playlists in your library',
                  showBackButton: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                          color: CaviaColors.textSilver,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _isGridView = !_isGridView),
                        tooltip: _isGridView ? 'Switch to list' : 'Switch to grid',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_rounded,
                          color: CaviaColors.vermilionBright,
                          size: 24,
                        ),
                        onPressed: () => CreatePlaylistDialog.show(context),
                        tooltip: 'Create Playlist',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: playlists.isEmpty
                      ? CaviaEmptyState(
                          icon: Icons.queue_music_rounded,
                          title: 'No Playlists Yet',
                          subtitle: 'Create a playlist to organize your favorite tracks.',
                          actionLabel: 'Create Playlist',
                          onAction: () => CreatePlaylistDialog.show(context),
                        )
                      : _isGridView
                          ? _buildGrid(context, playlists)
                          : _buildList(context, playlists),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<dynamic> playlists) {
    final crossAxisCount = CaviaBreakpoints.value<int>(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final pl = playlists[index];
        return CaviaPlaylistCard(
          playlist: pl,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaylistDetailScreen(playlistId: pl.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<dynamic> playlists) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final pl = playlists[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CaviaGlass.radiusSmall),
              color: CaviaColors.surfaceCard,
            ),
            child: const Icon(
              Icons.queue_music_rounded,
              color: CaviaColors.vermilionBright,
              size: 24,
            ),
          ),
          title: Text(
            pl.name,
            style: CaviaTypography.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${pl.trackCount} tracks',
            style: CaviaTypography.caption,
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: CaviaColors.textSilver,
            size: 20,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaylistDetailScreen(playlistId: pl.id),
              ),
            );
          },
        );
      },
    );
  }
}

