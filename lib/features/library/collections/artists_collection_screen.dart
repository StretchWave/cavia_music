import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../core/components/cavia_page_header.dart';
import '../../../core/components/cavia_artist_card.dart';
import '../../../core/components/cavia_feedback_states.dart';
import '../../../core/responsive/responsive_breakpoints.dart';
import '../../../core/state/app_state_scope.dart';
import '../../artists/artist_detail_screen.dart';

/// Full collection screen for browsing all artists in the user's library.
class ArtistsCollectionScreen extends StatefulWidget {
  const ArtistsCollectionScreen({super.key});

  @override
  State<ArtistsCollectionScreen> createState() => _ArtistsCollectionScreenState();
}

class _ArtistsCollectionScreenState extends State<ArtistsCollectionScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);

    return ListenableBuilder(
      listenable: library,
      builder: (context, _) {
        final artists = library.artists;

        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CaviaPageHeader(
                  title: 'Artists',
                  subtitle: '${artists.length} artists in your library',
                  showBackButton: true,
                  trailing: IconButton(
                    icon: Icon(
                      _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                      color: CaviaColors.textSilver,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                    tooltip: _isGridView ? 'Switch to list' : 'Switch to grid',
                  ),
                ),
                Expanded(
                  child: artists.isEmpty
                      ? const CaviaEmptyState(
                          icon: Icons.person_outline_rounded,
                          title: 'No Artists Followed',
                          subtitle: 'Artists from your tracks and followed artists will appear here.',
                        )
                      : _isGridView
                          ? _buildGrid(context, artists)
                          : _buildList(context, artists, library),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<dynamic> artists) {
    final crossAxisCount = CaviaBreakpoints.value<int>(
      context,
      mobile: 3,
      tablet: 4,
      desktop: 5,
    );

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return CaviaArtistCard(
          artist: artist,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArtistDetailScreen(artist: artist),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<dynamic> artists, dynamic library) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return CaviaArtistRow(
          artist: artist,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArtistDetailScreen(artist: artist),
              ),
            );
          },
          onFollowToggle: () => library.toggleFollowArtist(artist.id),
        );
      },
    );
  }
}

