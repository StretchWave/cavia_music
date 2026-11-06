import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:cavia_music/core/lyrics/lrclib_service.dart';

void main() {
  group('LrcLibService Tests', () {
    test('parseLrc parses standard [mm:ss.xx] timestamps into sorted LyricLines', () {
      const sampleLrc = '''
[00:01.50] Line one of song
[00:04.20] Second lyric line
[00:10.00] Third line of lyric
''';

      final lines = LrcLibService.parseLrc(sampleLrc);
      expect(lines, isNotNull);
      expect(lines!.length, 3);
      expect(lines[0].timestamp, const Duration(seconds: 1, milliseconds: 500));
      expect(lines[0].text, 'Line one of song');
      expect(lines[1].timestamp, const Duration(seconds: 4, milliseconds: 200));
      expect(lines[1].text, 'Second lyric line');
      expect(lines[2].timestamp, const Duration(seconds: 10));
      expect(lines[2].text, 'Third line of lyric');
    });

    test('parseLrc handles 3-digit millisecond timestamps [mm:ss.xxx]', () {
      const sampleLrc = '''
[01:15.350] Chorus drops here
[01:20.075] Next vocal entrance
''';

      final lines = LrcLibService.parseLrc(sampleLrc);
      expect(lines, isNotNull);
      expect(lines!.length, 2);
      expect(lines[0].timestamp, const Duration(minutes: 1, seconds: 15, milliseconds: 350));
      expect(lines[0].text, 'Chorus drops here');
      expect(lines[1].timestamp, const Duration(minutes: 1, seconds: 20, milliseconds: 75));
    });

    test('fetchLyrics returns synced lyrics when /api/get succeeds', () async {
      final mockClient = http_testing.MockClient((req) async {
        if (req.url.path == '/api/get') {
          return http.Response(jsonEncode({
            'id': 12345,
            'trackName': 'Afterglow',
            'artistName': 'Luna Caine',
            'syncedLyrics': '[00:02.00] Walking through the night\n[00:05.50] Echoes in the dark',
          }), 200);
        }
        return http.Response('Not Found', 404);
      });

      final service = LrcLibService(httpClient: mockClient);
      final lyrics = await service.fetchLyrics(title: 'Afterglow', artist: 'Luna Caine');

      expect(lyrics, isNotNull);
      expect(lyrics!.length, 2);
      expect(lyrics[0].text, 'Walking through the night');
      expect(lyrics[1].text, 'Echoes in the dark');
    });

    test('fetchLyrics falls back to /api/search when /api/get returns 404', () async {
      final mockClient = http_testing.MockClient((req) async {
        if (req.url.path == '/api/get') {
          return http.Response('Not Found', 404);
        }
        if (req.url.path == '/api/search') {
          return http.Response(jsonEncode([
            {
              'id': 67890,
              'trackName': 'Zenith',
              'artistName': 'Kenshi Yonezu',
              'syncedLyrics': '[00:01.00] In the zenith of sky\n[00:04.00] Rising sun',
            }
          ]), 200);
        }
        return http.Response('Error', 500);
      });

      final service = LrcLibService(httpClient: mockClient);
      final lyrics = await service.fetchLyrics(title: 'Zenith', artist: 'Kenshi Yonezu');

      expect(lyrics, isNotNull);
      expect(lyrics!.length, 2);
      expect(lyrics[0].text, 'In the zenith of sky');
      expect(lyrics[1].text, 'Rising sun');
    });

    test('fetchLyrics returns null gracefully when both endpoints fail', () async {
      final mockClient = http_testing.MockClient((req) async {
        return http.Response('Not Found', 404);
      });

      final service = LrcLibService(httpClient: mockClient);
      final lyrics = await service.fetchLyrics(title: 'Unknown Nonexistent Song', artist: 'Unknown');

      expect(lyrics, isNull);
    });
  });
}

