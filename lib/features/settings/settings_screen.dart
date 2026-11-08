import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/cavia_glass_surface.dart';
import '../../core/components/cavia_page_header.dart';
import '../../core/components/cavia_section_header.dart';
import '../../core/components/cavia_dialog.dart';
import '../../core/components/toast.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/storage/cache_state.dart';
import '../spotify_import/spotify_import_screen.dart';
import 'subscreens/playback_settings_screen.dart';
import 'subscreens/appearance_settings_screen.dart';
import 'subscreens/about_screen.dart';
import 'subscreens/providers_status_screen.dart';
import 'dialogs/auth_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppStateScope.settingsOf(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                // Editorial Header
                const CaviaPageHeader(
                  title: 'Settings',
                  kanji: '設定',
                  sectionLabel: 'S E T T I N G S',
                  padding: EdgeInsets.only(bottom: 12),
                ),

                // 1. STORAGE & CACHE
                const CaviaSectionHeader(title: 'Storage & Cache'),
                CaviaGlassSurface(
                  radius: CaviaGlass.radiusCard,
                  blur: CaviaGlass.blurStandard,
                  surfaceColor: CaviaColors.surfaceCard,
                  borderColor: CaviaColors.glassBorderSubtle,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      // Offline Caching Switch
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.download_rounded,
                          color: CaviaColors.textSilver,
                          size: 22,
                        ),
                        title: const Text('Offline caching', style: CaviaTypography.body),
                        subtitle: Text(
                          settings.offlineCaching
                              ? 'Automatic caching active'
                              : 'Automatic caching disabled (cached tracks preserved)',
                          style: CaviaTypography.caption,
                        ),
                        trailing: Switch(
                          value: settings.offlineCaching,
                          activeThumbColor: CaviaColors.vermilionBright,
                          activeTrackColor: CaviaColors.vermilion.withValues(alpha: 0.4),
                          inactiveThumbColor: CaviaColors.textSilver,
                          inactiveTrackColor: CaviaColors.glassSurface,
                          onChanged: (val) {
                            settings.toggleOfflineCaching(val);
                            CaviaToast.show(
                              context,
                              val
                                  ? 'Offline caching enabled'
                                  : 'Offline caching disabled (cached tracks preserved)',
                            );
                          },
                        ),
                      ),

                      const Divider(color: CaviaColors.glassBorderSubtle, height: 1),

                      // Clear Cache Tile
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.delete_outline_rounded,
                          color: CaviaColors.textSilver,
                          size: 22,
                        ),
                        title: const Text('Clear cache', style: CaviaTypography.body),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              settings.isMeasuringCache ? 'Measuring…' : settings.cacheSizeFormatted,
                              style: CaviaTypography.body.copyWith(
                                color: CaviaColors.textSilver,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: CaviaColors.textDim,
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () async {
                          final confirm = await CaviaDialog.show(
                            context,
                            title: 'Clear Offline Cache',
                            content:
                                'This will free ${settings.cacheSizeFormatted} of locally cached audio and artwork. Downloaded songs will need to be re-cached.',
                            confirmLabel: 'Clear Cache',
                            isDestructive: true,
                          );
                          if (!context.mounted) return;
                          if (confirm == true) {
                            await settings.clearCache(confirmed: true);
                            if (context.mounted) {
                              CaviaToast.show(context, CacheMessages.cacheCleared);
                            }
                          } else {
                            CaviaToast.show(context, CacheMessages.noChangesMade);
                          }
                        },
                      ),

                      const Divider(color: CaviaColors.glassBorderSubtle, height: 1),

                      // Storage Quota Slider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.sd_storage_rounded,
                                  color: CaviaColors.textSilver,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text('Cache storage limit', style: CaviaTypography.body),
                                ),
                                Text(
                                  settings.cacheQuotaFormatted,
                                  style: CaviaTypography.caption.copyWith(
                                    color: CaviaColors.vermilionBright,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              settings.isMeasuringCache
                                  ? 'Measuring used space…'
                                  : '${settings.cacheSizeFormatted} used of ${settings.cacheQuotaFormatted}',
                              style: CaviaTypography.caption,
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: CaviaColors.vermilionBright,
                                inactiveTrackColor: CaviaColors.glassSurface,
                                thumbColor: CaviaColors.textIvory,
                                overlayColor: CaviaColors.vermilion.withValues(alpha: 0.15),
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: settings.cacheQuotaBytes
                                    .clamp(128.0 * 1024 * 1024, 6.0 * 1024 * 1024 * 1024),
                                min: 128.0 * 1024 * 1024,
                                max: 6.0 * 1024 * 1024 * 1024,
                                onChanged:
                                    settings.isMeasuringCache ? null : settings.setCacheQuota,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. ACCOUNT & CLOUD SYNC
                const CaviaSectionHeader(title: 'Account & Cloud'),
                CaviaGlassSurface(
                  radius: CaviaGlass.radiusCard,
                  blur: CaviaGlass.blurStandard,
                  surfaceColor: CaviaColors.surfaceCard,
                  borderColor: CaviaColors.glassBorderSubtle,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      // Profile Tile
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: settings.isAuthenticated
                              ? CaviaColors.vermilion.withValues(alpha: 0.2)
                              : CaviaColors.glassSurface,
                          child: Icon(
                            settings.isAuthenticated
                                ? Icons.account_circle_rounded
                                : Icons.person_outline_rounded,
                            color: settings.isAuthenticated
                                ? CaviaColors.vermilionBright
                                : CaviaColors.textSilver,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          settings.currentProfile.displayName,
                          style: CaviaTypography.songTitle,
                        ),
                        subtitle: Text(
                          settings.isAuthenticated
                              ? (settings.currentProfile.email ?? 'Cloud connected')
                              : 'Guest mode • Tap to sign in or create account',
                          style: CaviaTypography.caption,
                        ),
                        trailing: settings.isAuthenticated
                            ? PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: CaviaColors.textSilver,
                                ),
                                color: CaviaColors.overlaySheet,
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'merge',
                                    child: Text(
                                      'Merge local library with account',
                                      style: TextStyle(
                                        color: CaviaColors.textIvory,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'sign_out',
                                    child: Text(
                                      'Sign Out',
                                      style: TextStyle(
                                        color: CaviaColors.textIvory,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete_account',
                                    child: Text(
                                      'Delete Cloud Account',
                                      style: TextStyle(
                                        color: CaviaColors.vermilionBright,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                                onSelected: (val) async {
                                  if (val == 'merge') {
                                    final confirm = await CaviaDialog.show(
                                      context,
                                      title: 'Merge local and cloud libraries?',
                                      content:
                                          'Merge your local guest playlists and liked songs with your cloud account? Your original local data will be preserved.',
                                      confirmLabel: 'Merge',
                                    );
                                    if (confirm == true && context.mounted) {
                                      final res = await settings.mergeGuestWithAccount();
                                      if (context.mounted) {
                                        CaviaToast.show(
                                          context,
                                          res.isSuccess
                                              ? 'Library synced'
                                              : (res.errorOrNull?.userMessage ?? "Couldn't sync"),
                                        );
                                      }
                                    }
                                  } else if (val == 'sign_out') {
                                    await settings.signOut();
                                    if (context.mounted) {
                                      CaviaToast.show(
                                        context,
                                        "You're signed out. Your local library is still here.",
                                      );
                                    }
                                  } else if (val == 'delete_account') {
                                    final confirm = await CaviaDialog.show(
                                      context,
                                      title: 'Delete Cloud Account',
                                      content:
                                          'Are you sure you want to delete your cloud account? All user-owned cloud records will be deleted. Your local music library and files will remain intact.',
                                      confirmLabel: 'Delete Account',
                                      isDestructive: true,
                                    );
                                    if (confirm == true && context.mounted) {
                                      final res = await settings.deleteAccount();
                                      if (context.mounted) {
                                        CaviaToast.show(
                                          context,
                                          res.isSuccess
                                              ? 'Cloud account deleted. Local library preserved.'
                                              : "Couldn't delete account",
                                        );
                                      }
                                    }
                                  }
                                },
                              )
                            : const Icon(
                                Icons.chevron_right_rounded,
                                color: CaviaColors.textSilver,
                                size: 20,
                              ),
                        onTap: settings.isAuthenticated
                            ? null
                            : () => AuthDialog.show(context, settings),
                      ),

                      const Divider(color: CaviaColors.glassBorderSubtle, height: 1),

                      // Sync Toggle
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.cloud_outlined,
                          color: CaviaColors.textSilver,
                          size: 22,
                        ),
                        title: const Text('Sync', style: CaviaTypography.body),
                        subtitle: Text(
                          settings.syncStatusMessage,
                          style: CaviaTypography.caption,
                        ),
                        trailing: Switch(
                          value: settings.cloudSync,
                          activeThumbColor: CaviaColors.vermilionBright,
                          activeTrackColor: CaviaColors.vermilion.withValues(alpha: 0.4),
                          inactiveThumbColor: CaviaColors.textSilver,
                          inactiveTrackColor: CaviaColors.glassSurface,
                          onChanged: (val) {
                            final msg = settings.toggleCloudSync(val);
                            CaviaToast.show(context, msg);
                            if (val && !settings.isAuthenticated) {
                              AuthDialog.show(context, settings);
                            }
                          },
                        ),
                      ),

                      const Divider(color: CaviaColors.glassBorderSubtle, height: 1),

                      // Import from Spotify Tile
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.album_outlined,
                          color: CaviaColors.vermilionBright,
                          size: 22,
                        ),
                        title: const Text('Import from Spotify', style: CaviaTypography.body),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: CaviaColors.textSilver,
                          size: 20,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SpotifyImportScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. PREFERENCES & SYSTEM
                const CaviaSectionHeader(title: 'Preferences & System'),
                CaviaGlassSurface(
                  radius: CaviaGlass.radiusCard,
                  blur: CaviaGlass.blurStandard,
                  surfaceColor: CaviaColors.surfaceCard,
                  borderColor: CaviaColors.glassBorderSubtle,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      _SettingsNavRow(
                        icon: Icons.tune_rounded,
                        label: 'Playback',
                        subtitle: 'Speed (${settings.playbackSpeed.toStringAsFixed(2)}×), audio quality & transitions',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PlaybackSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(color: CaviaColors.glassBorderSubtle, height: 1),
                      _SettingsNavRow(
                        icon: Icons.palette_outlined,
                        label: 'Appearance',
                        subtitle: 'Atmosphere, Japanese ink backgrounds & theme',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AppearanceSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(color: CaviaColors.glassBorderSubtle, height: 1),
                      _SettingsNavRow(
                        icon: Icons.layers_outlined,
                        label: 'Providers',
                        subtitle: 'Live audio stream engine status',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProviderStatusScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(color: CaviaColors.glassBorderSubtle, height: 1),
                      _SettingsNavRow(
                        icon: Icons.info_outline_rounded,
                        label: 'About',
                        subtitle: 'Version 1.0.0 (Japanese Ink Edition)',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsNavRow({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: CaviaColors.textSilver, size: 22),
      title: Text(label, style: CaviaTypography.body),
      subtitle: subtitle != null ? Text(subtitle!, style: CaviaTypography.caption) : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: CaviaColors.textSilver,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
