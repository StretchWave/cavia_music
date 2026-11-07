import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../playback/playback_failure.dart';

/// Formats extracted from InnerTube streaming data.
class InnerTubeAudioFormat {
  final int itag;
  final String mimeType;
  final int bitrate;
  final int durationMs;
  final String url;
  final Map<String, String>? headers;

  const InnerTubeAudioFormat({
    required this.itag,
    required this.mimeType,
    required this.bitrate,
    required this.durationMs,
    required this.url,
    this.headers,
  });

  bool get isOpus => mimeType.contains('opus') || mimeType.contains('webm') || itag == 251 || itag == 250;
}

/// Parsed search result from InnerTube.
class InnerTubeSongItem {
  final String videoId;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String artworkUrl;

  const InnerTubeSongItem({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.artworkUrl,
  });
}

/// Lightweight, pure-Dart client for YouTube Music's InnerTube API.
/// Adapted from Harmony-Music's production-tested client configurations.
class InnerTubeClient {
  final http.Client _httpClient;
  static String? _cachedVisitorId;

  InnerTubeClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  static const String _userAgentVisionOS =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 15_7_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Safari/605.1.15';

  static const String _userAgentWeb =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0';

  /// Fetches a visitor data token ("X-Goog-Visitor-Id") from YouTube Music.
  Future<String?> getVisitorId({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedVisitorId != null && _cachedVisitorId!.isNotEmpty) {
      return _cachedVisitorId;
    }

    try {
      final uri = Uri.parse('https://music.youtube.com/youtubei/v1/guide?prettyPrint=false');
      final res = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': _userAgentWeb,
          'Origin': 'https://music.youtube.com',
        },
        body: jsonEncode({
          'context': {
            'client': {
              'clientName': 'WEB_REMIX',
              'clientVersion': '1.20260707.12.00',
              'gl': 'US',
              'hl': 'en',
            }
          }
        }),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rc = data is Map ? data['responseContext'] : null;
        if (rc is Map && rc['visitorData'] is String) {
          _cachedVisitorId = rc['visitorData'] as String;
          return _cachedVisitorId;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Resolves the highest quality playable audio stream URL for [videoId].
  /// Uses the VISIONOS client candidate which provides unthrottled direct audio URLs.
  Future<Result<InnerTubeAudioFormat, PlaybackFailure>> getStreamAudio(String videoId) async {
    final cleanId = videoId.replaceFirst('yt_', '');
    if (cleanId.isEmpty) {
      return Result.failure(PlaybackFailure(
        type: PlaybackFailureType.invalidMedia,
        internalMessage: 'Empty video ID supplied to InnerTube resolver',
        trackId: videoId,
      ));
    }

    try {
      final visitorToken = await getVisitorId();

      final uri = Uri.parse('https://music.youtube.com/youtubei/v1/player?prettyPrint=false');
      final bodyPayload = {
        'context': {
          'client': {
            'clientName': 'VISIONOS',
            'clientVersion': '1.02',
            'deviceMake': 'Apple',
            'deviceModel': 'RealityDevice17,1',
            'osName': 'visionOS',
            'osVersion': '26.5.23O471',
            'gl': 'US',
            'hl': 'en',
            if (visitorToken != null && visitorToken.isNotEmpty) 'visitorData': visitorToken,
          }
        },
        'videoId': cleanId,
        'contentCheckOk': true,
        'racyCheckOk': true,
      };

      final headers = {
        'Content-Type': 'application/json',
        'User-Agent': _userAgentVisionOS,
        'X-YouTube-Client-Name': '101',
        'X-YouTube-Client-Version': '1.02',
        'Origin': 'https://music.youtube.com',
        if (visitorToken != null && visitorToken.isNotEmpty) 'X-Goog-Visitor-Id': visitorToken,
      };

      final response = await _httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode(bodyPayload),
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode != 200) {
        return Result.failure(PlaybackFailure(
          type: PlaybackFailureType.networkUnavailable,
          internalMessage: 'InnerTube player responded with status ${response.statusCode}',
          trackId: videoId,
        ));
      }

      final json = jsonDecode(response.body);
      final playability = json['playabilityStatus'];
      if (playability != null && playability['status'] != 'OK') {
        final reason = playability['reason'] as String? ?? 'Track playability status is not OK';
        return Result.failure(PlaybackFailure(
          type: PlaybackFailureType.trackUnavailable,
          internalMessage: reason,
          trackId: videoId,
        ));
      }

      final streamingData = json['streamingData'];
      if (streamingData == null) {
        return Result.failure(PlaybackFailure(
          type: PlaybackFailureType.sourceUnavailable,
          internalMessage: 'No streaming data returned from InnerTube',
          trackId: videoId,
        ));
      }

      final adaptive = streamingData['adaptiveFormats'] as List? ?? [];
      final audioFormats = <InnerTubeAudioFormat>[];

      for (final f in adaptive) {
        final mimeType = f['mimeType'] as String? ?? '';
        if (!mimeType.startsWith('audio/')) continue;

        final url = f['url'] as String?;
        if (url == null || url.isEmpty) continue;
        // Skip range-gated iOS URLs that stall
        if (url.contains('c=IOS') || url.contains('c=ios')) continue;

        final itag = (f['itag'] as num?)?.toInt() ?? 140;
        final bitrate = (f['bitrate'] as num?)?.toInt() ?? 128000;
        final durationMs = int.tryParse('${f['approxDurationMs']}') ?? 0;

        audioFormats.add(InnerTubeAudioFormat(
          itag: itag,
          mimeType: mimeType,
          bitrate: bitrate,
          durationMs: durationMs,
          url: url,
        ));
      }

      if (audioFormats.isEmpty) {
        return Result.failure(PlaybackFailure(
          type: PlaybackFailureType.sourceUnavailable,
          internalMessage: 'No compatible audio formats found in stream response',
          trackId: videoId,
        ));
      }

      // Sort by highest bitrate descending
      audioFormats.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      return Result.success(audioFormats.first);
    } on TimeoutException {
      return Result.failure(PlaybackFailure(
        type: PlaybackFailureType.requestTimeout,
        internalMessage: 'InnerTube stream resolution timed out',
        trackId: videoId,
      ));
    } catch (e, st) {
      return Result.failure(PlaybackFailure(
        type: PlaybackFailureType.unknownPlaybackFailure,
        internalMessage: 'InnerTube resolution failed: $e',
        trackId: videoId,
        originalError: e,
        stackTrace: st,
      ));
    }
  }

  /// Searches YouTube Music for songs matching [query].
  Future<Result<List<InnerTubeSongItem>, AppError>> searchSongs(String query, {int limit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const Result.success([]);

    try {
      final uri = Uri.parse('https://music.youtube.com/youtubei/v1/search?prettyPrint=false');
      final bodyPayload = {
        'context': {
          'client': {
            'clientName': 'WEB_REMIX',
            'clientVersion': '1.20260707.12.00',
            'gl': 'US',
            'hl': 'en',
          }
        },
        'query': trimmed,
      };

      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': _userAgentWeb,
          'Origin': 'https://music.youtube.com',
        },
        body: jsonEncode(bodyPayload),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) {
        return Result.failure(DatabaseError(
          userMessage: "Couldn't search songs at this time",
          details: 'InnerTube search status: ${response.statusCode}',
        ));
      }

      final json = jsonDecode(response.body);
      final items = <InnerTubeSongItem>[];

      // Traverse YouTube Music search response hierarchy
      _parseSearchContents(json, items, limit);

      return Result.success(items);
    } catch (e, st) {
      return Result.failure(DatabaseError(
        userMessage: "Couldn't load search results",
        details: 'InnerTube search exception: $e',
        cause: st,
      ));
    }
  }

  void _parseSearchContents(dynamic json, List<InnerTubeSongItem> items, int limit) {
    if (json is! Map) return;

    try {
      final contents = json['contents'];
      if (contents == null) return;

      final tabRenderer = contents['tabbedSearchResultsRenderer']?['tabs']?[0]?['tabRenderer']?['content'];
      final sectionList = tabRenderer?['sectionListRenderer']?['contents'] as List? ?? [];

      final renderers = <Map>[];

      void collectRenderers(dynamic node) {
        if (node is List) {
          for (final item in node) {
            collectRenderers(item);
          }
        } else if (node is Map) {
          if (node.containsKey('musicResponsiveListItemRenderer')) {
            renderers.add(node['musicResponsiveListItemRenderer'] as Map);
          } else {
            for (final value in node.values) {
              if (value is Map || value is List) {
                collectRenderers(value);
              }
            }
          }
        }
      }

      collectRenderers(sectionList);

      final seenVideoIds = <String>{};

      for (final renderer in renderers) {
        if (items.length >= limit) return;

        final videoId = _extractVideoId(renderer);
        if (videoId == null || videoId.isEmpty || !seenVideoIds.add(videoId)) continue;

        final title = _extractRunText(renderer, 0) ?? 'Unknown Title';
        final parsedMeta = _extractMetadata(renderer);

        final thumbnails = renderer['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails'] as List?;
        final artworkUrl = (thumbnails != null && thumbnails.isNotEmpty)
            ? (thumbnails.last['url'] as String? ?? '')
            : '';

        items.add(InnerTubeSongItem(
          videoId: videoId,
          title: title,
          artist: parsedMeta.artist,
          album: parsedMeta.album,
          duration: parsedMeta.duration ?? _extractDuration(renderer) ?? Duration.zero,
          artworkUrl: artworkUrl,
        ));
      }
    } catch (_) {}
  }

  String? _extractVideoId(Map renderer) {
    try {
      // 1. playlistItemData
      final pId = renderer['playlistItemData']?['videoId'] as String?;
      if (pId != null && pId.isNotEmpty) return pId;

      // 2. overlay play button watchEndpoint
      final overlayId = renderer['overlay']?['musicItemThumbnailOverlayRenderer']?['content']?['musicPlayButtonRenderer']?['playNavigationEndpoint']?['watchEndpoint']?['videoId'] as String?;
      if (overlayId != null && overlayId.isNotEmpty) return overlayId;

      // 3. flexColumns runs watchEndpoint
      final flexId = _extractVideoIdFromFlexColumns(renderer);
      if (flexId != null && flexId.isNotEmpty) return flexId;

      // 4. direct navigationEndpoint
      final navId = renderer['navigationEndpoint']?['watchEndpoint']?['videoId'] as String?;
      if (navId != null && navId.isNotEmpty) return navId;

      // 5. doubleTapCommand watchEndpoint
      final dtId = renderer['doubleTapCommand']?['watchEndpoint']?['videoId'] as String?;
      if (dtId != null && dtId.isNotEmpty) return dtId;
    } catch (_) {}
    return null;
  }

  _ParsedMetadata _extractMetadata(Map renderer) {
    try {
      final flexColumns = renderer['flexColumns'] as List?;
      if (flexColumns == null || flexColumns.length < 2) {
        return const _ParsedMetadata(artist: 'Unknown Artist', album: 'Single');
      }

      // Collect all text runs across column 1 and subsequent columns
      final allTokens = <String>[];
      Duration? foundDuration;
      final durationPattern = RegExp(r'^(\d{1,2}):(\d{2})$');

      for (int i = 1; i < flexColumns.length; i++) {
        final runs = flexColumns[i]['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List?;
        if (runs == null) continue;
        for (final r in runs) {
          final text = (r['text'] as String? ?? '').trim();
          if (text.isEmpty || text == '•' || text == '&' || text == ',') continue;
          
          final match = durationPattern.firstMatch(text);
          if (match != null) {
            foundDuration = Duration(
              minutes: int.parse(match.group(1)!),
              seconds: int.parse(match.group(2)!),
            );
          } else if (!text.toLowerCase().contains('views') && !text.toLowerCase().contains('plays')) {
            allTokens.add(text);
          }
        }
      }

      // Remove leading "Song" or "Video" token if present
      if (allTokens.isNotEmpty && (allTokens.first.toLowerCase() == 'song' || allTokens.first.toLowerCase() == 'video')) {
        allTokens.removeAt(0);
      }

      final artist = allTokens.isNotEmpty ? allTokens[0] : 'Unknown Artist';
      final album = allTokens.length > 1 ? allTokens[1] : 'Single';

      return _ParsedMetadata(artist: artist, album: album, duration: foundDuration);
    } catch (_) {
      return const _ParsedMetadata(artist: 'Unknown Artist', album: 'Single');
    }
  }

  /// Extracts the track duration from the list item's flex column runs
  /// (usually rendered as "m:ss" in the last column). Returns null when the
  /// response provides none — no fabricated duration is ever substituted.
  Duration? _extractDuration(Map renderer) {
    try {
      final flexColumns = renderer['flexColumns'] as List?;
      if (flexColumns == null) return null;
      final pattern = RegExp(r'^(\d{1,2}):(\d{2})$');
      for (final col in flexColumns) {
        final runs = col['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List?;
        if (runs == null) continue;
        for (final run in runs) {
          final text = (run['text'] as String? ?? '').trim();
          final match = pattern.firstMatch(text);
          if (match != null) {
            final minutes = int.parse(match.group(1)!);
            final seconds = int.parse(match.group(2)!);
            return Duration(minutes: minutes, seconds: seconds);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  String? _extractVideoIdFromFlexColumns(Map renderer) {
    try {
      final flexColumns = renderer['flexColumns'] as List?;
      if (flexColumns == null) return null;
      for (final col in flexColumns) {
        final runs = col['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List?;
        if (runs == null) continue;
        for (final run in runs) {
          final nav = run['navigationEndpoint'];
          final id = nav?['watchEndpoint']?['videoId'] as String?;
          if (id != null && id.isNotEmpty) return id;
        }
      }
    } catch (_) {}
    return null;
  }

  String? _extractRunText(Map renderer, int columnIndex) {
    try {
      final flexColumns = renderer['flexColumns'] as List?;
      if (flexColumns == null || flexColumns.length <= columnIndex) return null;
      final runs = flexColumns[columnIndex]['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'] as List?;
      if (runs == null || runs.isEmpty) return null;
      return runs.map((r) => r['text'] as String? ?? '').join().trim();
    } catch (_) {}
    return null;
  }
}

class _ParsedMetadata {
  final String artist;
  final String album;
  final Duration? duration;

  const _ParsedMetadata({required this.artist, required this.album, this.duration});
}

