import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:cavia_music/core/domain/models/track.dart';
import 'package:cavia_music/core/providers/provider_registry.dart';
import 'package:cavia_music/core/providers/local_audio_provider.dart';
import 'package:cavia_music/core/providers/youtube_provider.dart';
import 'package:cavia_music/core/providers/spotify_metadata_provider.dart';
import 'package:cavia_music/core/playback/playback_source.dart';
import 'helpers/mock_audio_engine.dart';
import 'package:cavia_music/core/playback/track_resolver.dart';
import 'package:cavia_music/core/playback/queue_manager.dart';
import 'package:cavia_music/core/playback/cavia_audio_handler.dart';
import 'package:cavia_music/core/search/search_service.dart';
import 'package:cavia_music/core/state/playback_controller.dart';
import 'package:cavia_music/core/data/database/cavia_database.dart';
import 'package:cavia_music/core/data/repositories/local_track_repository.dart';
import 'package:cavia_music/core/data/repositories/local_search_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CaviaDatabase db;
  late LocalTrackRepository trackRepo;
  late LocalSearchRepository searchRepo;
  late ProviderRegistry registry;
  late TrackResolver resolver;
  late MockAudioEngine mockEngine;

  setUp(() async {
    db = CaviaDatabase.forTesting(NativeDatabase.memory());
    // InitialDataSeeder removed from production — database starts empty.
    trackRepo = LocalTrackRepository(db);
    searchRepo = LocalSearchRepository(db);

    registry = ProviderRegistry(
      initialProviders: [
        LocalAudioProvider(trackRepository: trackRepo),
        YouTubeMusicProvider(),
        SpotifyMetadataProvider(),
      ],
    );

    resolver = TrackResolver(
      providerRegistry: registry,
      trackRepository: trackRepo,
    );

    mockEngine = MockAudioEngine();
  });
}