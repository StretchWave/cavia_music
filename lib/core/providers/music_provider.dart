import 'dart:async';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/models/track.dart';
import '../playback/playback_source.dart';
import '../playback/playback_failure.dart';

/// Supported operating platforms for music providers.
enum CaviaPlatform {
  android,
  ios,
  windows,
  macos,
  linux,
  web,
}

/// Explicit declaration of capabilities for a music catalog / streaming provider.
class ProviderCapabilities {
  final bool searchSupport;
  final bool metadataSupport;
  final bool playbackSupport;
  final bool backgroundPlaybackSupport;
  final bool seekingSupport;
  final bool cachingPermission;
  final bool offlineAvailability;
  final bool authenticationRequired;
  final List<String> supportedRegions;
  final List<CaviaPlatform> supportedPlatforms;

  const ProviderCapabilities({
    required this.searchSupport,
    required this.metadataSupport,
    required this.playbackSupport,
    required this.backgroundPlaybackSupport,
    required this.seekingSupport,
    required this.cachingPermission,
    required this.offlineAvailability,
    required this.authenticationRequired,
    this.supportedRegions = const ['GLOBAL'],
    this.supportedPlatforms = const [
      CaviaPlatform.android,
      CaviaPlatform.windows,
      CaviaPlatform.linux,
      CaviaPlatform.macos,
      CaviaPlatform.ios,
      CaviaPlatform.web,
    ],
  });
}

/// Filter categories for search queries across providers.
enum SearchFilterCategory {
  all,
  songs,
  albums,
  artists,
  playlists,
}

/// Normalized search result item across all music providers.
class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final String? artworkUrl;
  final SearchFilterCategory category;
  final String providerId;
  final String sourceAttribution;
  final Duration? duration;
  final Track? trackData;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.artworkUrl,
    required this.category,
    required this.providerId,
    required this.sourceAttribution,
    this.duration,
    this.trackData,
  });
}

/// Cancellation token for debounced or superseded provider operations.
class CancellationToken {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

/// Abstract contract for music catalog, metadata, and streaming providers.
abstract class MusicProvider {
  /// Unique identifier (e.g. 'local', 'youtube', 'spotify').
  String get id;

  /// Human-readable display label (e.g. 'Local Library', 'YouTube Music').
  String get displayName;

  /// Declared capabilities.
  ProviderCapabilities get capabilities;

  /// Whether the provider is configured and available on the current device.
  bool get isOperational;

  /// Execute a catalog search with optional pagination and cancellation.
  Future<Result<List<SearchResultItem>, AppError>> search({
    required String query,
    SearchFilterCategory category = SearchFilterCategory.all,
    int page = 1,
    int pageSize = 20,
    CancellationToken? cancelToken,
  });

  /// Fetch full metadata for a track.
  Future<Result<Track, AppError>> resolveTrackMetadata(String providerTrackId);

  /// Resolve a playable audio source or detect unsupported official playback.
  Future<Result<PlaybackSource, PlaybackFailure>> resolvePlaybackSource(String providerTrackId);
}

