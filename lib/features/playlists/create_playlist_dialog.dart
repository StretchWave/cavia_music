import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/glass_container.dart';
import '../../core/state/app_state_scope.dart';

class CreatePlaylistDialog extends StatefulWidget {
  const CreatePlaylistDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: CaviaColors.scrim,
      builder: (ctx) => const CreatePlaylistDialog(),
    );
  }

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: GlassContainer(
          radius: CaviaGlass.radiusCard,
          blur: CaviaGlass.blurHeavy,
          surfaceColor: CaviaColors.overlaySheet,
          padding: const EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Playlist',
                    style: CaviaTypography.display.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 16),

                  // Name Field
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    style: const TextStyle(color: CaviaColors.textIvory),
                    decoration: InputDecoration(
                      hintText: 'Playlist name (e.g. Zen Meditation)',
                      hintStyle: const TextStyle(color: CaviaColors.textDim),
                      filled: true,
                      fillColor: CaviaColors.glassSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: CaviaColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: CaviaColors.vermilionBright),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description Field
                  TextField(
                    controller: _descController,
                    style: const TextStyle(color: CaviaColors.textIvory),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Optional description...',
                      hintStyle: const TextStyle(color: CaviaColors.textDim),
                      filled: true,
                      fillColor: CaviaColors.glassSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: CaviaColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: CaviaColors.vermilionBright),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: CaviaColors.textSilver),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final name = _nameController.text.trim();
                          if (name.isNotEmpty) {
                            library.createPlaylist(name, _descController.text.trim());
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CaviaColors.vermilion,
                          foregroundColor: CaviaColors.textIvory,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

