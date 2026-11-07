import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:cavia_music/core/domain/models/track.dart';
import 'package:cavia_music/core/innertube/innertube_client.dart';
import 'package:cavia_music/core/playback/playback_failure.dart';
import 'package:cavia_music/core/providers/innertube_audio_provider.dart';
import 'package:cavia_music/core/providers/provider_registry.dart';
import 'package:cavia_music/core/playback/track_resolver.dart';
import 'package:cavia_music/core/domain/repositories/track_repository.dart';
import 'package:cavia_music/core/domain/result/result.dart';
import 'package:cavia_music/core/domain/result/app_error.dart';

class _FakeTrackRepo implements TrackRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<List<Track>, AppError>> getAllTracks({String? profileId}) async => const Result.success([]);
  @override
  Stream<List<Track>> watchTracks({String? profileId}) => const Stream.empty();
  @override
  Stream<List<Track>> watchLikedTracks({String? profileId}) => const Stream.empty();
  @override
  Future<Result<Track, AppError>> getTrackById(String id, {String? profileId}) async => const Result.failure(NotFoundError('Not found'));
  @override
  Future<Result<bool, AppError>> isTrackLiked(String trackId, {String? profileId}) async => const Result.success(false);
  @override
  Future<Result<bool, AppError>> toggleLike(String trackId, {String? profileId}) async => const Result.success(false);
  @override
  Future<Result<void, AppError>> updatePlayStats(String trackId, Duration position, {String? profileId}) async => const Result.success(null);
  @override
  Future<Result<void, AppError>> insertTrack(Track track, {String? profileId}) async => const Result.success(null);
}

void main() {
  group('InnerTubeClient & Audio Streaming Tests', () {
    test('InnerTubeClient parses streaming audio formats and rejects iOS range-gated streams', () async {
      final mockClient = http_testing.MockClient((req) async {
        if (req.url.path.contains('/player')) {
          final payload = {
            'playabilityStatus': {'status': 'OK'},
            'streamingData': {
              'adaptiveFormats': [
                {
                  'itag': 140,
                  'mimeType': 'audio/mp4; codecs="mp4a.40.2"',
                  'bitrate': 129000,
                  'approxDurationMs': '210000',
                  'url': 'https://stream.googlevideo.com/videoplayback?itag=140&c=IOS', // Should be skipped (range-gated)
                },
                {
                  'itag': 251,
                  'mimeType': 'audio/webm; codecs="opus"',
                  'bitrate': 160000,
                  'approxDurationMs': '210000',
                  'url': 'https://stream.googlevideo.com/videoplayback?itag=251', // Valid
                },
                {
                  'itag': 139,
                  'mimeType': 'audio/mp4; codecs="mp4a.40.5"',
                  'bitrate': 48000,
                  'approxDurationMs': '210000',
                  'url': 'https://stream.googlevideo.com/videoplayback?itag=139', // Valid lower bitrate
                },
              ]
            }
          };
          return http.Response(jsonEncode(payload), 200);
        }
        return http.Response('Not Found', 404);
      });

      final client = InnerTubeClient(httpClient: mockClient);
      final result = await client.getStreamAudio('dQw4w9WgXcQ');

      expect(result.isSuccess, true);
      final format = result.dataOrNull!;
      expect(format.itag, 251);
      expect(format.isOpus, true);
      expect(format.url.contains('itag=251'), true);
      expect(format.bitrate, 160000);
    });

    test('InnerTubeClient returns trackUnavailable when status is not OK', () async {
      final mockClient = http_testing.MockClient((req) async {
        return http.Response(jsonEncode({
          'playabilityStatus': {
            'status': 'UNPLAYABLE',
            'reason': 'This video is not available in your country'
          }
        }), 200);
      });

      final client = InnerTubeClient(httpClient: mockClient);
      final result = await client.getStreamAudio('unavailable_id');

      expect(result.isFailure, true);
      expect(result.errorOrNull!.type, PlaybackFailureType.trackUnavailable);
      expect(result.errorOrNull!.internalMessage, contains('not available'));
    });

    test('InnerTubeAudioProvider declares operational capabilities and resolves playback source', () async {
      final mockClient = http_testing.MockClient((req) async {
        return http.Response(jsonEncode({
          'playabilityStatus': {'status': 'OK'},
          'streamingData': {
            'adaptiveFormats': [
              {
                'itag': 251,
                'mimeType': 'audio/webm; codecs="opus"',
                'bitrate': 160000,
                'approxDurationMs': '180000',
                'url': 'https://stream.googlevideo.com/audio.webm',
              }
            ]
          }
        }), 200);
      });

      final provider = InnerTubeAudioProvider(client: InnerTubeClient(httpClient: mockClient));
      expect(provider.id, 'youtube_music');
      expect(provider.capabilities.playbackSupport, true);
      expect(provider.capabilities.seekingSupport, true);
      expect(provider.isOperational, true);

      final sourceRes = await provider.resolvePlaybackSource('track_12345');
      expect(sourceRes.isSuccess, true);
      final source = sourceRes.dataOrNull!;
      expect(source.isStream, true);
      expect(source.uri.toString(), 'https://stream.googlevideo.com/audio.webm');
      expect(source.providerId, 'youtube_music');
    });

    test('TrackResolver successfully resolves youtube_music tracks into direct stream sources', () async {
      final mockClient = http_testing.MockClient((req) async {
        return http.Response(jsonEncode({
          'playabilityStatus': {'status': 'OK'},
          'streamingData': {
            'adaptiveFormats': [
              {
                'itag': 251,
                'mimeType': 'audio/webm; codecs="opus"',
                'bitrate': 160000,
                'approxDurationMs': '200000',
                'url': 'https://stream.googlevideo.com/playback_source',
              }
            ]
          }
        }), 200);
      });

      final streamProvider = InnerTubeAudioProvider(client: InnerTubeClient(httpClient: mockClient));
      final registry = ProviderRegistry(initialProviders: [streamProvider]);
      final resolver = TrackResolver(
        providerRegistry: registry,
        trackRepository: _FakeTrackRepo(),
      );

      final ytTrack = Track(
        id: 'yt_abc123xyz45',
        providerId: 'youtube_music',
        providerTrackId: 'abc123xyz45',
        title: 'Streaming Song',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(minutes: 3),
        artworkAsset: 'assets/images/cover_zenith.jpg',
        sourceAttribution: 'YouTube Music',
        dateAdded: DateTime.now(),
      );

      final result = await resolver.resolve(ytTrack);
      expect(result.isSuccess, true);
      expect(result.dataOrNull!.isStream, true);
      expect(result.dataOrNull!.uri.toString(), 'https://stream.googlevideo.com/playback_source');
    });

    test('InnerTubeClient searchSongs traverses multi-section itemSectionRenderers and parses overlay videoIds', () async {
      // Construct a response mimicking real YouTube Music response structure:
      // - 1 musicCardShelfRenderer (top result with 3 items)
      // - 1 itemSectionRenderer (regular results with 5 items having overlay play button videoIds)
      final mockResponse = {
        'contents': {
          'tabbedSearchResultsRenderer': {
            'tabs': [
              {
                'tabRenderer': {
                  'content': {
                    'sectionListRenderer': {
                      'contents': [
                        {
                          'musicCardShelfRenderer': {
                            'contents': List.generate(3, (i) => {
                              'musicResponsiveListItemRenderer': {
                                'flexColumns': [
                                  {
                                    'musicResponsiveListItemFlexColumnRenderer': {
                                      'text': {
                                        'runs': [{'text': 'Card Track $i'}]
                                      }
                                    }
                                  },
                                  {
                                    'musicResponsiveListItemFlexColumnRenderer': {
                                      'text': {
                                        'runs': [
                                          {'text': 'Card Artist $i'},
                                          {'text': ' • '},
                                          {'text': 'Card Album $i'},
                                          {'text': ' • '},
                                          {'text': '3:45'},
                                        ]
                                      }
                                    }
                                  }
                                ],
                                'navigationEndpoint': {
                                  'watchEndpoint': {'videoId': 'card_id_$i'}
                                }
                              }
                            })
                          }
                        },
                        {
                          'itemSectionRenderer': {
                            'contents': List.generate(5, (i) => {
                              'musicResponsiveListItemRenderer': {
                                'flexColumns': [
                                  {
                                    'musicResponsiveListItemFlexColumnRenderer': {
                                      'text': {
                                        'runs': [{'text': 'Section Track $i'}]
                                      }
                                    }
                                  },
                                  {
                                    'musicResponsiveListItemFlexColumnRenderer': {
                                      'text': {
                                        'runs': [
                                          {'text': 'Section Artist $i'},
                                          {'text': ' • '},
                                          {'text': 'Section Album $i'},
                                          {'text': ' • '},
                                          {'text': '1.2M views'},
                                          {'text': ' • '},
                                          {'text': '4:15'},
                                        ]
                                      }
                                    }
                                  }
                                ],
                                'overlay': {
                                  'musicItemThumbnailOverlayRenderer': {
                                    'content': {
                                      'musicPlayButtonRenderer': {
                                        'playNavigationEndpoint': {
                                          'watchEndpoint': {'videoId': 'section_id_$i'}
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            })
                          }
                        }
                      ]
                    }
                  }
                }
              }
            ]
          }
        }
      };

      final mockClient = http_testing.MockClient((req) async {
        return http.Response(
          jsonEncode(mockResponse),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = InnerTubeClient(httpClient: mockClient);
      final searchResult = await client.searchSongs('test query');

      expect(searchResult.isSuccess, true);
      final songs = searchResult.dataOrNull!;

      // Old code only parsed the top card shelf and stopped at 3.
      // New recursive multi-section extraction yields all 8 songs across shelves!
      expect(songs.length, 8);
      expect(songs[0].videoId, 'card_id_0');
      expect(songs[0].title, 'Card Track 0');
      expect(songs[3].videoId, 'section_id_0');
      expect(songs[3].title, 'Section Track 0');
      expect(songs[3].artist, 'Section Artist 0');
      expect(songs[3].album, 'Section Album 0');
      expect(songs[3].duration, const Duration(minutes: 4, seconds: 15));
    });
  });
}

