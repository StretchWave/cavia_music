import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../core/components/cavia_page_header.dart';
import '../../../core/components/cavia_album_card.dart';
import '../../../core/components/cavia_feedback_states.dart';
import '../../../core/responsive/responsive_breakpoints.dart';
import '../../../core/state/app_state_scope.dart';
import '../../albums/album_detail_screen.dart';

/// Full collection screen for browsing all albums in the user's library.
class AlbumsCollectionScreen extends StatelessWidget {
  const AlbumsCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);

    return ListenableBuilder(
      listenable: library,
      builder: (context, _) {
        final albums = library.albums;

        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CaviaPageHeader(
                  title: 'Albums',
                  subtitle: '${albums.length} albums in your library',
                  showBackButton: true,
                ),
                Expanded(
                  child: albums.isEmpty
                      ? const CaviaEmptyState(
                          icon: Icons.album_rounded,
                          title: 'No Albums Found',
                          subtitle: 'Saved albums and releases will appear in this collection.',
                        )
                      : _buildGrid(context, albums),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<dynamic> albums) {
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
        mainAxisSpacing: 16,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return CaviaAlbumCard(
          album: album,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AlbumDetailScreen(album: album),
              ),
            );
          },
        );
      },
    );
  }
}

