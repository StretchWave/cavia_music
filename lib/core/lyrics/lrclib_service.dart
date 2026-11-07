import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/music_models.dart';

/// Free, open-source lyrics provider integrating with LRCLIB (lrclib.net).
/// Adapted from Harmony-Music's battle-tested lyrics parser.
class LrcLibService {
  final http.Client _httpClient;

  LrcLibService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  static final RegExp _lrcTimestampRegex = RegExp(r'\[(\d{1,3}):(\d{1,2})(?:[.:](\d{1,3}))?\]');

  /// Fetches synced or plain lyrics from LRCLIB for a track.
  Future<List<LyricLine>?> fetchLyrics({
    required String title,
    required String artist,
    String? album,
    Duration? duration,
  }) async {
    final cleanTitle = _cleanTitle(title);
    final cleanArtist = _cleanArtist(artist);
    if (cleanTitle.isEmpty) return null;

    // 1. Try exact match via /api/get
    try {
      final queryParams = {
        'track_name': cleanTitle,
        'artist_name': cleanArtist,
        if (album != null && album.isNotEmpty) 'album_name': album,
        if (duration != null && duration.inSeconds > 0) 'duration': '${duration.inSeconds}',
      };

      final uri = Uri.https('lrclib.net', '/api/get', queryParams);
      final response = await _httpClient.get(
        uri,
        headers: {'User-Agent': 'CaviaMusic/1.0 (https://github.com/cavia-music)'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final synced = data['syncedLyrics'] as String?;
        if (synced != null && synced.trim().isNotEmpty) {
          final lines = parseLrc(synced);
          if (lines != null && lines.isNotEmpty) return lines;
        }

        final plain = data['plainLyrics'] as String?;
        if (plain != null && plain.trim().isNotEmpty) {
          return _parsePlainLyrics(plain, duration ?? const Duration(minutes: 3));
        }
      }
    } catch (_) {}

    // 2. Fallback to /api/search
    try {
      final searchUri = Uri.https('lrclib.net', '/api/search', {'q': '$cleanTitle $cleanArtist'});
      final searchRes = await _httpClient.get(
        searchUri,
        headers: {'User-Agent': 'CaviaMusic/1.0 (https://github.com/cavia-music)'},
      ).timeout(const Duration(seconds: 5));

      if (searchRes.statusCode == 200) {
        final list = jsonDecode(searchRes.body);
        if (list is List && list.isNotEmpty) {
          final first = list.first;
          final synced = first['syncedLyrics'] as String?;
          if (synced != null && synced.trim().isNotEmpty) {
            final lines = parseLrc(synced);
            if (lines != null && lines.isNotEmpty) return lines;
          }

          final plain = first['plainLyrics'] as String?;
          if (plain != null && plain.trim().isNotEmpty) {
            return _parsePlainLyrics(plain, duration ?? const Duration(minutes: 3));
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Parses standard LRC timestamped text [mm:ss.xx] into [LyricLine]s.
  static List<LyricLine>? parseLrc(String lrc) {
    final rawLines = lrc.split('\n');
    final result = <LyricLine>[];

    for (final raw in rawLines) {
      final text = raw.trim();
      if (text.isEmpty) continue;

      final matches = _lrcTimestampRegex.allMatches(text).toList();
      if (matches.isEmpty) continue;

      final lyricText = text.replaceAll(_lrcTimestampRegex, '').trim();
      if (lyricText.isEmpty) continue;

      for (final match in matches) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
        final fracStr = match.group(3) ?? '0';

        var ms = 0;
        if (fracStr.length == 1) {
          ms = (int.tryParse(fracStr) ?? 0) * 100;
        } else if (fracStr.length == 2) {
          ms = (int.tryParse(fracStr) ?? 0) * 10;
        } else {
          ms = int.tryParse(fracStr) ?? 0;
        }

        final timestamp = Duration(minutes: minutes, seconds: seconds, milliseconds: ms);
        result.add(LyricLine(timestamp: timestamp, text: lyricText));
      }
    }

    if (result.isEmpty) return null;

    // Sort by timestamp
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return result;
  }

  /// Converts un-synced plain lyrics into pseudo-timed lines spaced across duration.
  static List<LyricLine> _parsePlainLyrics(String plain, Duration totalDuration) {
    final lines = plain.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return [];

    final stepMs = totalDuration.inMilliseconds ~/ (lines.length + 1);
    final result = <LyricLine>[];

    for (var i = 0; i < lines.length; i++) {
      result.add(LyricLine(
        timestamp: Duration(milliseconds: (i + 1) * stepMs),
        text: lines[i],
      ));
    }

    return result;
  }

  String _cleanTitle(String title) {
    var clean = title;
    // Remove (Official Video), [Audio], etc.
    clean = clean.replaceAll(RegExp(r'\s*[\(\[][^()\[\]]*(official|audio|video|lyrics|remix|hd|4k)[^()\[\]]*[\)\]]', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r'\s*-\s*(official|audio|video|lyrics).*$', caseSensitive: false), '');
    return clean.trim();
  }

  String _cleanArtist(String artist) {
    var clean = artist;
    clean = clean.replaceAll(RegExp(r'\s*-\s*topic$', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r'\s*vevo$', caseSensitive: false), '');
    return clean.trim();
  }
}

