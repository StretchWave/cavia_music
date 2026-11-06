// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cavia_database.dart';

// ignore_for_file: type=lint
class $DbTracksTable extends DbTracks with TableInfo<$DbTracksTable, DbTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _providerTrackIdMeta = const VerificationMeta(
    'providerTrackId',
  );
  @override
  late final GeneratedColumn<String> providerTrackId = GeneratedColumn<String>(
    'provider_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistsJsonMeta = const VerificationMeta(
    'artistsJson',
  );
  @override
  late final GeneratedColumn<String> artistsJson = GeneratedColumn<String>(
    'artists_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artworkUriMeta = const VerificationMeta(
    'artworkUri',
  );
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
    'artwork_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isrcMeta = const VerificationMeta('isrc');
  @override
  late final GeneratedColumn<String> isrc = GeneratedColumn<String>(
    'isrc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explicitMeta = const VerificationMeta(
    'explicit',
  );
  @override
  late final GeneratedColumn<bool> explicit = GeneratedColumn<bool>(
    'explicit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explicit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _availabilityStateMeta = const VerificationMeta(
    'availabilityState',
  );
  @override
  late final GeneratedColumn<String> availabilityState =
      GeneratedColumn<String>(
        'availability_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('available'),
      );
  static const VerificationMeta _sourceAttributionMeta = const VerificationMeta(
    'sourceAttribution',
  );
  @override
  late final GeneratedColumn<String> sourceAttribution =
      GeneratedColumn<String>(
        'source_attribution',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCachedMeta = const VerificationMeta(
    'isCached',
  );
  @override
  late final GeneratedColumn<bool> isCached = GeneratedColumn<bool>(
    'is_cached',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cached" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localCachePathMeta = const VerificationMeta(
    'localCachePath',
  );
  @override
  late final GeneratedColumn<String> localCachePath = GeneratedColumn<String>(
    'local_cache_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lyricsJsonMeta = const VerificationMeta(
    'lyricsJson',
  );
  @override
  late final GeneratedColumn<String> lyricsJson = GeneratedColumn<String>(
    'lyrics_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    providerTrackId,
    title,
    artist,
    artistsJson,
    album,
    durationMs,
    artworkUri,
    isrc,
    explicit,
    availabilityState,
    sourceAttribution,
    dateAdded,
    isCached,
    localCachePath,
    playCount,
    lastPlayedAt,
    lyricsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTrack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('provider_track_id')) {
      context.handle(
        _providerTrackIdMeta,
        providerTrackId.isAcceptableOrUnknown(
          data['provider_track_id']!,
          _providerTrackIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('artists_json')) {
      context.handle(
        _artistsJsonMeta,
        artistsJson.isAcceptableOrUnknown(
          data['artists_json']!,
          _artistsJsonMeta,
        ),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
        _artworkUriMeta,
        artworkUri.isAcceptableOrUnknown(data['artwork_uri']!, _artworkUriMeta),
      );
    } else if (isInserting) {
      context.missing(_artworkUriMeta);
    }
    if (data.containsKey('isrc')) {
      context.handle(
        _isrcMeta,
        isrc.isAcceptableOrUnknown(data['isrc']!, _isrcMeta),
      );
    }
    if (data.containsKey('explicit')) {
      context.handle(
        _explicitMeta,
        explicit.isAcceptableOrUnknown(data['explicit']!, _explicitMeta),
      );
    }
    if (data.containsKey('availability_state')) {
      context.handle(
        _availabilityStateMeta,
        availabilityState.isAcceptableOrUnknown(
          data['availability_state']!,
          _availabilityStateMeta,
        ),
      );
    }
    if (data.containsKey('source_attribution')) {
      context.handle(
        _sourceAttributionMeta,
        sourceAttribution.isAcceptableOrUnknown(
          data['source_attribution']!,
          _sourceAttributionMeta,
        ),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('is_cached')) {
      context.handle(
        _isCachedMeta,
        isCached.isAcceptableOrUnknown(data['is_cached']!, _isCachedMeta),
      );
    }
    if (data.containsKey('local_cache_path')) {
      context.handle(
        _localCachePathMeta,
        localCachePath.isAcceptableOrUnknown(
          data['local_cache_path']!,
          _localCachePathMeta,
        ),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('lyrics_json')) {
      context.handle(
        _lyricsJsonMeta,
        lyricsJson.isAcceptableOrUnknown(data['lyrics_json']!, _lyricsJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTrack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      providerTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_track_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      artistsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artists_json'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      artworkUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_uri'],
      )!,
      isrc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isrc'],
      ),
      explicit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explicit'],
      )!,
      availabilityState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}availability_state'],
      )!,
      sourceAttribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_attribution'],
      ),
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      isCached: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cached'],
      )!,
      localCachePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_cache_path'],
      ),
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      lyricsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lyrics_json'],
      )!,
    );
  }

  @override
  $DbTracksTable createAlias(String alias) {
    return $DbTracksTable(attachedDatabase, alias);
  }
}

class DbTrack extends DataClass implements Insertable<DbTrack> {
  final String id;
  final String providerId;
  final String providerTrackId;
  final String title;
  final String artist;
  final String artistsJson;
  final String album;
  final int durationMs;
  final String artworkUri;
  final String? isrc;
  final bool explicit;
  final String availabilityState;
  final String? sourceAttribution;
  final DateTime dateAdded;
  final bool isCached;
  final String? localCachePath;
  final int playCount;
  final DateTime? lastPlayedAt;
  final String lyricsJson;
  const DbTrack({
    required this.id,
    required this.providerId,
    required this.providerTrackId,
    required this.title,
    required this.artist,
    required this.artistsJson,
    required this.album,
    required this.durationMs,
    required this.artworkUri,
    this.isrc,
    required this.explicit,
    required this.availabilityState,
    this.sourceAttribution,
    required this.dateAdded,
    required this.isCached,
    this.localCachePath,
    required this.playCount,
    this.lastPlayedAt,
    required this.lyricsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['provider_track_id'] = Variable<String>(providerTrackId);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['artists_json'] = Variable<String>(artistsJson);
    map['album'] = Variable<String>(album);
    map['duration_ms'] = Variable<int>(durationMs);
    map['artwork_uri'] = Variable<String>(artworkUri);
    if (!nullToAbsent || isrc != null) {
      map['isrc'] = Variable<String>(isrc);
    }
    map['explicit'] = Variable<bool>(explicit);
    map['availability_state'] = Variable<String>(availabilityState);
    if (!nullToAbsent || sourceAttribution != null) {
      map['source_attribution'] = Variable<String>(sourceAttribution);
    }
    map['date_added'] = Variable<DateTime>(dateAdded);
    map['is_cached'] = Variable<bool>(isCached);
    if (!nullToAbsent || localCachePath != null) {
      map['local_cache_path'] = Variable<String>(localCachePath);
    }
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    map['lyrics_json'] = Variable<String>(lyricsJson);
    return map;
  }

  DbTracksCompanion toCompanion(bool nullToAbsent) {
    return DbTracksCompanion(
      id: Value(id),
      providerId: Value(providerId),
      providerTrackId: Value(providerTrackId),
      title: Value(title),
      artist: Value(artist),
      artistsJson: Value(artistsJson),
      album: Value(album),
      durationMs: Value(durationMs),
      artworkUri: Value(artworkUri),
      isrc: isrc == null && nullToAbsent ? const Value.absent() : Value(isrc),
      explicit: Value(explicit),
      availabilityState: Value(availabilityState),
      sourceAttribution: sourceAttribution == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAttribution),
      dateAdded: Value(dateAdded),
      isCached: Value(isCached),
      localCachePath: localCachePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localCachePath),
      playCount: Value(playCount),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      lyricsJson: Value(lyricsJson),
    );
  }

  factory DbTrack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTrack(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      providerTrackId: serializer.fromJson<String>(json['providerTrackId']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      artistsJson: serializer.fromJson<String>(json['artistsJson']),
      album: serializer.fromJson<String>(json['album']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      artworkUri: serializer.fromJson<String>(json['artworkUri']),
      isrc: serializer.fromJson<String?>(json['isrc']),
      explicit: serializer.fromJson<bool>(json['explicit']),
      availabilityState: serializer.fromJson<String>(json['availabilityState']),
      sourceAttribution: serializer.fromJson<String?>(
        json['sourceAttribution'],
      ),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      isCached: serializer.fromJson<bool>(json['isCached']),
      localCachePath: serializer.fromJson<String?>(json['localCachePath']),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      lyricsJson: serializer.fromJson<String>(json['lyricsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'providerTrackId': serializer.toJson<String>(providerTrackId),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'artistsJson': serializer.toJson<String>(artistsJson),
      'album': serializer.toJson<String>(album),
      'durationMs': serializer.toJson<int>(durationMs),
      'artworkUri': serializer.toJson<String>(artworkUri),
      'isrc': serializer.toJson<String?>(isrc),
      'explicit': serializer.toJson<bool>(explicit),
      'availabilityState': serializer.toJson<String>(availabilityState),
      'sourceAttribution': serializer.toJson<String?>(sourceAttribution),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'isCached': serializer.toJson<bool>(isCached),
      'localCachePath': serializer.toJson<String?>(localCachePath),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'lyricsJson': serializer.toJson<String>(lyricsJson),
    };
  }

  DbTrack copyWith({
    String? id,
    String? providerId,
    String? providerTrackId,
    String? title,
    String? artist,
    String? artistsJson,
    String? album,
    int? durationMs,
    String? artworkUri,
    Value<String?> isrc = const Value.absent(),
    bool? explicit,
    String? availabilityState,
    Value<String?> sourceAttribution = const Value.absent(),
    DateTime? dateAdded,
    bool? isCached,
    Value<String?> localCachePath = const Value.absent(),
    int? playCount,
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    String? lyricsJson,
  }) => DbTrack(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    providerTrackId: providerTrackId ?? this.providerTrackId,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    artistsJson: artistsJson ?? this.artistsJson,
    album: album ?? this.album,
    durationMs: durationMs ?? this.durationMs,
    artworkUri: artworkUri ?? this.artworkUri,
    isrc: isrc.present ? isrc.value : this.isrc,
    explicit: explicit ?? this.explicit,
    availabilityState: availabilityState ?? this.availabilityState,
    sourceAttribution: sourceAttribution.present
        ? sourceAttribution.value
        : this.sourceAttribution,
    dateAdded: dateAdded ?? this.dateAdded,
    isCached: isCached ?? this.isCached,
    localCachePath: localCachePath.present
        ? localCachePath.value
        : this.localCachePath,
    playCount: playCount ?? this.playCount,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    lyricsJson: lyricsJson ?? this.lyricsJson,
  );
  DbTrack copyWithCompanion(DbTracksCompanion data) {
    return DbTrack(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      providerTrackId: data.providerTrackId.present
          ? data.providerTrackId.value
          : this.providerTrackId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      artistsJson: data.artistsJson.present
          ? data.artistsJson.value
          : this.artistsJson,
      album: data.album.present ? data.album.value : this.album,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      artworkUri: data.artworkUri.present
          ? data.artworkUri.value
          : this.artworkUri,
      isrc: data.isrc.present ? data.isrc.value : this.isrc,
      explicit: data.explicit.present ? data.explicit.value : this.explicit,
      availabilityState: data.availabilityState.present
          ? data.availabilityState.value
          : this.availabilityState,
      sourceAttribution: data.sourceAttribution.present
          ? data.sourceAttribution.value
          : this.sourceAttribution,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      isCached: data.isCached.present ? data.isCached.value : this.isCached,
      localCachePath: data.localCachePath.present
          ? data.localCachePath.value
          : this.localCachePath,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      lyricsJson: data.lyricsJson.present
          ? data.lyricsJson.value
          : this.lyricsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTrack(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('providerTrackId: $providerTrackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('artistsJson: $artistsJson, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('isrc: $isrc, ')
          ..write('explicit: $explicit, ')
          ..write('availabilityState: $availabilityState, ')
          ..write('sourceAttribution: $sourceAttribution, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('isCached: $isCached, ')
          ..write('localCachePath: $localCachePath, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('lyricsJson: $lyricsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    providerTrackId,
    title,
    artist,
    artistsJson,
    album,
    durationMs,
    artworkUri,
    isrc,
    explicit,
    availabilityState,
    sourceAttribution,
    dateAdded,
    isCached,
    localCachePath,
    playCount,
    lastPlayedAt,
    lyricsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTrack &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.providerTrackId == this.providerTrackId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.artistsJson == this.artistsJson &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.artworkUri == this.artworkUri &&
          other.isrc == this.isrc &&
          other.explicit == this.explicit &&
          other.availabilityState == this.availabilityState &&
          other.sourceAttribution == this.sourceAttribution &&
          other.dateAdded == this.dateAdded &&
          other.isCached == this.isCached &&
          other.localCachePath == this.localCachePath &&
          other.playCount == this.playCount &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.lyricsJson == this.lyricsJson);
}

class DbTracksCompanion extends UpdateCompanion<DbTrack> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> providerTrackId;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> artistsJson;
  final Value<String> album;
  final Value<int> durationMs;
  final Value<String> artworkUri;
  final Value<String?> isrc;
  final Value<bool> explicit;
  final Value<String> availabilityState;
  final Value<String?> sourceAttribution;
  final Value<DateTime> dateAdded;
  final Value<bool> isCached;
  final Value<String?> localCachePath;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayedAt;
  final Value<String> lyricsJson;
  final Value<int> rowid;
  const DbTracksCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.providerTrackId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.artistsJson = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.isrc = const Value.absent(),
    this.explicit = const Value.absent(),
    this.availabilityState = const Value.absent(),
    this.sourceAttribution = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.isCached = const Value.absent(),
    this.localCachePath = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.lyricsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbTracksCompanion.insert({
    required String id,
    this.providerId = const Value.absent(),
    this.providerTrackId = const Value.absent(),
    required String title,
    required String artist,
    this.artistsJson = const Value.absent(),
    required String album,
    required int durationMs,
    required String artworkUri,
    this.isrc = const Value.absent(),
    this.explicit = const Value.absent(),
    this.availabilityState = const Value.absent(),
    this.sourceAttribution = const Value.absent(),
    required DateTime dateAdded,
    this.isCached = const Value.absent(),
    this.localCachePath = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.lyricsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       artist = Value(artist),
       album = Value(album),
       durationMs = Value(durationMs),
       artworkUri = Value(artworkUri),
       dateAdded = Value(dateAdded);
  static Insertable<DbTrack> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? providerTrackId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? artistsJson,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<String>? artworkUri,
    Expression<String>? isrc,
    Expression<bool>? explicit,
    Expression<String>? availabilityState,
    Expression<String>? sourceAttribution,
    Expression<DateTime>? dateAdded,
    Expression<bool>? isCached,
    Expression<String>? localCachePath,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayedAt,
    Expression<String>? lyricsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (providerTrackId != null) 'provider_track_id': providerTrackId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (artistsJson != null) 'artists_json': artistsJson,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (isrc != null) 'isrc': isrc,
      if (explicit != null) 'explicit': explicit,
      if (availabilityState != null) 'availability_state': availabilityState,
      if (sourceAttribution != null) 'source_attribution': sourceAttribution,
      if (dateAdded != null) 'date_added': dateAdded,
      if (isCached != null) 'is_cached': isCached,
      if (localCachePath != null) 'local_cache_path': localCachePath,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (lyricsJson != null) 'lyrics_json': lyricsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbTracksCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? providerTrackId,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? artistsJson,
    Value<String>? album,
    Value<int>? durationMs,
    Value<String>? artworkUri,
    Value<String?>? isrc,
    Value<bool>? explicit,
    Value<String>? availabilityState,
    Value<String?>? sourceAttribution,
    Value<DateTime>? dateAdded,
    Value<bool>? isCached,
    Value<String?>? localCachePath,
    Value<int>? playCount,
    Value<DateTime?>? lastPlayedAt,
    Value<String>? lyricsJson,
    Value<int>? rowid,
  }) {
    return DbTracksCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerTrackId: providerTrackId ?? this.providerTrackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistsJson: artistsJson ?? this.artistsJson,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      artworkUri: artworkUri ?? this.artworkUri,
      isrc: isrc ?? this.isrc,
      explicit: explicit ?? this.explicit,
      availabilityState: availabilityState ?? this.availabilityState,
      sourceAttribution: sourceAttribution ?? this.sourceAttribution,
      dateAdded: dateAdded ?? this.dateAdded,
      isCached: isCached ?? this.isCached,
      localCachePath: localCachePath ?? this.localCachePath,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      lyricsJson: lyricsJson ?? this.lyricsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (providerTrackId.present) {
      map['provider_track_id'] = Variable<String>(providerTrackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (artistsJson.present) {
      map['artists_json'] = Variable<String>(artistsJson.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
    }
    if (isrc.present) {
      map['isrc'] = Variable<String>(isrc.value);
    }
    if (explicit.present) {
      map['explicit'] = Variable<bool>(explicit.value);
    }
    if (availabilityState.present) {
      map['availability_state'] = Variable<String>(availabilityState.value);
    }
    if (sourceAttribution.present) {
      map['source_attribution'] = Variable<String>(sourceAttribution.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (isCached.present) {
      map['is_cached'] = Variable<bool>(isCached.value);
    }
    if (localCachePath.present) {
      map['local_cache_path'] = Variable<String>(localCachePath.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (lyricsJson.present) {
      map['lyrics_json'] = Variable<String>(lyricsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbTracksCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('providerTrackId: $providerTrackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('artistsJson: $artistsJson, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('isrc: $isrc, ')
          ..write('explicit: $explicit, ')
          ..write('availabilityState: $availabilityState, ')
          ..write('sourceAttribution: $sourceAttribution, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('isCached: $isCached, ')
          ..write('localCachePath: $localCachePath, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('lyricsJson: $lyricsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbPlaylistsTable extends DbPlaylists
    with TableInfo<$DbPlaylistsTable, DbPlaylist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbPlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('guest'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _artworkUriMeta = const VerificationMeta(
    'artworkUri',
  );
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
    'artwork_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    description,
    artworkUri,
    createdAt,
    updatedAt,
    isSystem,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPlaylist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
        _artworkUriMeta,
        artworkUri.isAcceptableOrUnknown(data['artwork_uri']!, _artworkUriMeta),
      );
    } else if (isInserting) {
      context.missing(_artworkUriMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPlaylist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPlaylist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      artworkUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_uri'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $DbPlaylistsTable createAlias(String alias) {
    return $DbPlaylistsTable(attachedDatabase, alias);
  }
}

class DbPlaylist extends DataClass implements Insertable<DbPlaylist> {
  final String id;
  final String profileId;
  final String name;
  final String description;
  final String artworkUri;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSystem;
  final bool isDeleted;
  const DbPlaylist({
    required this.id,
    required this.profileId,
    required this.name,
    required this.description,
    required this.artworkUri,
    required this.createdAt,
    required this.updatedAt,
    required this.isSystem,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['artwork_uri'] = Variable<String>(artworkUri);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  DbPlaylistsCompanion toCompanion(bool nullToAbsent) {
    return DbPlaylistsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      description: Value(description),
      artworkUri: Value(artworkUri),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSystem: Value(isSystem),
      isDeleted: Value(isDeleted),
    );
  }

  factory DbPlaylist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPlaylist(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      artworkUri: serializer.fromJson<String>(json['artworkUri']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'artworkUri': serializer.toJson<String>(artworkUri),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  DbPlaylist copyWith({
    String? id,
    String? profileId,
    String? name,
    String? description,
    String? artworkUri,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSystem,
    bool? isDeleted,
  }) => DbPlaylist(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    description: description ?? this.description,
    artworkUri: artworkUri ?? this.artworkUri,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSystem: isSystem ?? this.isSystem,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  DbPlaylist copyWithCompanion(DbPlaylistsCompanion data) {
    return DbPlaylist(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      artworkUri: data.artworkUri.present
          ? data.artworkUri.value
          : this.artworkUri,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPlaylist(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSystem: $isSystem, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    description,
    artworkUri,
    createdAt,
    updatedAt,
    isSystem,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPlaylist &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.description == this.description &&
          other.artworkUri == this.artworkUri &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSystem == this.isSystem &&
          other.isDeleted == this.isDeleted);
}

class DbPlaylistsCompanion extends UpdateCompanion<DbPlaylist> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String> description;
  final Value<String> artworkUri;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSystem;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const DbPlaylistsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbPlaylistsCompanion.insert({
    required String id,
    this.profileId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required String artworkUri,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isSystem = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       artworkUri = Value(artworkUri),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DbPlaylist> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? artworkUri,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSystem,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSystem != null) 'is_system': isSystem,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbPlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? name,
    Value<String>? description,
    Value<String>? artworkUri,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSystem,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return DbPlaylistsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      description: description ?? this.description,
      artworkUri: artworkUri ?? this.artworkUri,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystem: isSystem ?? this.isSystem,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbPlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSystem: $isSystem, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbPlaylistEntriesTable extends DbPlaylistEntries
    with TableInfo<$DbPlaylistEntriesTable, DbPlaylistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbPlaylistEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playlistId,
    trackId,
    position,
    dateAdded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_playlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPlaylistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPlaylistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPlaylistEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
    );
  }

  @override
  $DbPlaylistEntriesTable createAlias(String alias) {
    return $DbPlaylistEntriesTable(attachedDatabase, alias);
  }
}

class DbPlaylistEntry extends DataClass implements Insertable<DbPlaylistEntry> {
  final String id;
  final String playlistId;
  final String trackId;
  final int position;
  final DateTime dateAdded;
  const DbPlaylistEntry({
    required this.id,
    required this.playlistId,
    required this.trackId,
    required this.position,
    required this.dateAdded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['playlist_id'] = Variable<String>(playlistId);
    map['track_id'] = Variable<String>(trackId);
    map['position'] = Variable<int>(position);
    map['date_added'] = Variable<DateTime>(dateAdded);
    return map;
  }

  DbPlaylistEntriesCompanion toCompanion(bool nullToAbsent) {
    return DbPlaylistEntriesCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      position: Value(position),
      dateAdded: Value(dateAdded),
    );
  }

  factory DbPlaylistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPlaylistEntry(
      id: serializer.fromJson<String>(json['id']),
      playlistId: serializer.fromJson<String>(json['playlistId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'playlistId': serializer.toJson<String>(playlistId),
      'trackId': serializer.toJson<String>(trackId),
      'position': serializer.toJson<int>(position),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
    };
  }

  DbPlaylistEntry copyWith({
    String? id,
    String? playlistId,
    String? trackId,
    int? position,
    DateTime? dateAdded,
  }) => DbPlaylistEntry(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
    dateAdded: dateAdded ?? this.dateAdded,
  );
  DbPlaylistEntry copyWithCompanion(DbPlaylistEntriesCompanion data) {
    return DbPlaylistEntry(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPlaylistEntry(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('dateAdded: $dateAdded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlistId, trackId, position, dateAdded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPlaylistEntry &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.position == this.position &&
          other.dateAdded == this.dateAdded);
}

class DbPlaylistEntriesCompanion extends UpdateCompanion<DbPlaylistEntry> {
  final Value<String> id;
  final Value<String> playlistId;
  final Value<String> trackId;
  final Value<int> position;
  final Value<DateTime> dateAdded;
  final Value<int> rowid;
  const DbPlaylistEntriesCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbPlaylistEntriesCompanion.insert({
    required String id,
    required String playlistId,
    required String trackId,
    required int position,
    required DateTime dateAdded,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       playlistId = Value(playlistId),
       trackId = Value(trackId),
       position = Value(position),
       dateAdded = Value(dateAdded);
  static Insertable<DbPlaylistEntry> custom({
    Expression<String>? id,
    Expression<String>? playlistId,
    Expression<String>? trackId,
    Expression<int>? position,
    Expression<DateTime>? dateAdded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
      if (dateAdded != null) 'date_added': dateAdded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbPlaylistEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? playlistId,
    Value<String>? trackId,
    Value<int>? position,
    Value<DateTime>? dateAdded,
    Value<int>? rowid,
  }) {
    return DbPlaylistEntriesCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      dateAdded: dateAdded ?? this.dateAdded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbPlaylistEntriesCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbLikedSongsTable extends DbLikedSongs
    with TableInfo<$DbLikedSongsTable, DbLikedSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbLikedSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('guest'),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateLikedMeta = const VerificationMeta(
    'dateLiked',
  );
  @override
  late final GeneratedColumn<DateTime> dateLiked = GeneratedColumn<DateTime>(
    'date_liked',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, trackId, dateLiked];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_liked_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbLikedSong> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('date_liked')) {
      context.handle(
        _dateLikedMeta,
        dateLiked.isAcceptableOrUnknown(data['date_liked']!, _dateLikedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateLikedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, trackId};
  @override
  DbLikedSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbLikedSong(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      dateLiked: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_liked'],
      )!,
    );
  }

  @override
  $DbLikedSongsTable createAlias(String alias) {
    return $DbLikedSongsTable(attachedDatabase, alias);
  }
}

class DbLikedSong extends DataClass implements Insertable<DbLikedSong> {
  final String profileId;
  final String trackId;
  final DateTime dateLiked;
  const DbLikedSong({
    required this.profileId,
    required this.trackId,
    required this.dateLiked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['track_id'] = Variable<String>(trackId);
    map['date_liked'] = Variable<DateTime>(dateLiked);
    return map;
  }

  DbLikedSongsCompanion toCompanion(bool nullToAbsent) {
    return DbLikedSongsCompanion(
      profileId: Value(profileId),
      trackId: Value(trackId),
      dateLiked: Value(dateLiked),
    );
  }

  factory DbLikedSong.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbLikedSong(
      profileId: serializer.fromJson<String>(json['profileId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      dateLiked: serializer.fromJson<DateTime>(json['dateLiked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'trackId': serializer.toJson<String>(trackId),
      'dateLiked': serializer.toJson<DateTime>(dateLiked),
    };
  }

  DbLikedSong copyWith({
    String? profileId,
    String? trackId,
    DateTime? dateLiked,
  }) => DbLikedSong(
    profileId: profileId ?? this.profileId,
    trackId: trackId ?? this.trackId,
    dateLiked: dateLiked ?? this.dateLiked,
  );
  DbLikedSong copyWithCompanion(DbLikedSongsCompanion data) {
    return DbLikedSong(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      dateLiked: data.dateLiked.present ? data.dateLiked.value : this.dateLiked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbLikedSong(')
          ..write('profileId: $profileId, ')
          ..write('trackId: $trackId, ')
          ..write('dateLiked: $dateLiked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, trackId, dateLiked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbLikedSong &&
          other.profileId == this.profileId &&
          other.trackId == this.trackId &&
          other.dateLiked == this.dateLiked);
}

class DbLikedSongsCompanion extends UpdateCompanion<DbLikedSong> {
  final Value<String> profileId;
  final Value<String> trackId;
  final Value<DateTime> dateLiked;
  final Value<int> rowid;
  const DbLikedSongsCompanion({
    this.profileId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.dateLiked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbLikedSongsCompanion.insert({
    this.profileId = const Value.absent(),
    required String trackId,
    required DateTime dateLiked,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       dateLiked = Value(dateLiked);
  static Insertable<DbLikedSong> custom({
    Expression<String>? profileId,
    Expression<String>? trackId,
    Expression<DateTime>? dateLiked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (trackId != null) 'track_id': trackId,
      if (dateLiked != null) 'date_liked': dateLiked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbLikedSongsCompanion copyWith({
    Value<String>? profileId,
    Value<String>? trackId,
    Value<DateTime>? dateLiked,
    Value<int>? rowid,
  }) {
    return DbLikedSongsCompanion(
      profileId: profileId ?? this.profileId,
      trackId: trackId ?? this.trackId,
      dateLiked: dateLiked ?? this.dateLiked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (dateLiked.present) {
      map['date_liked'] = Variable<DateTime>(dateLiked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbLikedSongsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('trackId: $trackId, ')
          ..write('dateLiked: $dateLiked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbAlbumsTable extends DbAlbums with TableInfo<$DbAlbumsTable, DbAlbum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbAlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artworkUriMeta = const VerificationMeta(
    'artworkUri',
  );
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
    'artwork_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceAttributionMeta = const VerificationMeta(
    'sourceAttribution',
  );
  @override
  late final GeneratedColumn<String> sourceAttribution =
      GeneratedColumn<String>(
        'source_attribution',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isSavedMeta = const VerificationMeta(
    'isSaved',
  );
  @override
  late final GeneratedColumn<bool> isSaved = GeneratedColumn<bool>(
    'is_saved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_saved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artist,
    year,
    artworkUri,
    sourceAttribution,
    isSaved,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbAlbum> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
        _artworkUriMeta,
        artworkUri.isAcceptableOrUnknown(data['artwork_uri']!, _artworkUriMeta),
      );
    } else if (isInserting) {
      context.missing(_artworkUriMeta);
    }
    if (data.containsKey('source_attribution')) {
      context.handle(
        _sourceAttributionMeta,
        sourceAttribution.isAcceptableOrUnknown(
          data['source_attribution']!,
          _sourceAttributionMeta,
        ),
      );
    }
    if (data.containsKey('is_saved')) {
      context.handle(
        _isSavedMeta,
        isSaved.isAcceptableOrUnknown(data['is_saved']!, _isSavedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbAlbum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbAlbum(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      artworkUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_uri'],
      )!,
      sourceAttribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_attribution'],
      ),
      isSaved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_saved'],
      )!,
    );
  }

  @override
  $DbAlbumsTable createAlias(String alias) {
    return $DbAlbumsTable(attachedDatabase, alias);
  }
}

class DbAlbum extends DataClass implements Insertable<DbAlbum> {
  final String id;
  final String title;
  final String artist;
  final int year;
  final String artworkUri;
  final String? sourceAttribution;
  final bool isSaved;
  const DbAlbum({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.artworkUri,
    this.sourceAttribution,
    required this.isSaved,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['year'] = Variable<int>(year);
    map['artwork_uri'] = Variable<String>(artworkUri);
    if (!nullToAbsent || sourceAttribution != null) {
      map['source_attribution'] = Variable<String>(sourceAttribution);
    }
    map['is_saved'] = Variable<bool>(isSaved);
    return map;
  }

  DbAlbumsCompanion toCompanion(bool nullToAbsent) {
    return DbAlbumsCompanion(
      id: Value(id),
      title: Value(title),
      artist: Value(artist),
      year: Value(year),
      artworkUri: Value(artworkUri),
      sourceAttribution: sourceAttribution == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAttribution),
      isSaved: Value(isSaved),
    );
  }

  factory DbAlbum.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbAlbum(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      year: serializer.fromJson<int>(json['year']),
      artworkUri: serializer.fromJson<String>(json['artworkUri']),
      sourceAttribution: serializer.fromJson<String?>(
        json['sourceAttribution'],
      ),
      isSaved: serializer.fromJson<bool>(json['isSaved']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'year': serializer.toJson<int>(year),
      'artworkUri': serializer.toJson<String>(artworkUri),
      'sourceAttribution': serializer.toJson<String?>(sourceAttribution),
      'isSaved': serializer.toJson<bool>(isSaved),
    };
  }

  DbAlbum copyWith({
    String? id,
    String? title,
    String? artist,
    int? year,
    String? artworkUri,
    Value<String?> sourceAttribution = const Value.absent(),
    bool? isSaved,
  }) => DbAlbum(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    year: year ?? this.year,
    artworkUri: artworkUri ?? this.artworkUri,
    sourceAttribution: sourceAttribution.present
        ? sourceAttribution.value
        : this.sourceAttribution,
    isSaved: isSaved ?? this.isSaved,
  );
  DbAlbum copyWithCompanion(DbAlbumsCompanion data) {
    return DbAlbum(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      year: data.year.present ? data.year.value : this.year,
      artworkUri: data.artworkUri.present
          ? data.artworkUri.value
          : this.artworkUri,
      sourceAttribution: data.sourceAttribution.present
          ? data.sourceAttribution.value
          : this.sourceAttribution,
      isSaved: data.isSaved.present ? data.isSaved.value : this.isSaved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbAlbum(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('year: $year, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('sourceAttribution: $sourceAttribution, ')
          ..write('isSaved: $isSaved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    year,
    artworkUri,
    sourceAttribution,
    isSaved,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbAlbum &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.year == this.year &&
          other.artworkUri == this.artworkUri &&
          other.sourceAttribution == this.sourceAttribution &&
          other.isSaved == this.isSaved);
}

class DbAlbumsCompanion extends UpdateCompanion<DbAlbum> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> artist;
  final Value<int> year;
  final Value<String> artworkUri;
  final Value<String?> sourceAttribution;
  final Value<bool> isSaved;
  final Value<int> rowid;
  const DbAlbumsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.year = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.sourceAttribution = const Value.absent(),
    this.isSaved = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbAlbumsCompanion.insert({
    required String id,
    required String title,
    required String artist,
    required int year,
    required String artworkUri,
    this.sourceAttribution = const Value.absent(),
    this.isSaved = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       artist = Value(artist),
       year = Value(year),
       artworkUri = Value(artworkUri);
  static Insertable<DbAlbum> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<int>? year,
    Expression<String>? artworkUri,
    Expression<String>? sourceAttribution,
    Expression<bool>? isSaved,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (year != null) 'year': year,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (sourceAttribution != null) 'source_attribution': sourceAttribution,
      if (isSaved != null) 'is_saved': isSaved,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbAlbumsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? artist,
    Value<int>? year,
    Value<String>? artworkUri,
    Value<String?>? sourceAttribution,
    Value<bool>? isSaved,
    Value<int>? rowid,
  }) {
    return DbAlbumsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      year: year ?? this.year,
      artworkUri: artworkUri ?? this.artworkUri,
      sourceAttribution: sourceAttribution ?? this.sourceAttribution,
      isSaved: isSaved ?? this.isSaved,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
    }
    if (sourceAttribution.present) {
      map['source_attribution'] = Variable<String>(sourceAttribution.value);
    }
    if (isSaved.present) {
      map['is_saved'] = Variable<bool>(isSaved.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbAlbumsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('year: $year, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('sourceAttribution: $sourceAttribution, ')
          ..write('isSaved: $isSaved, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbArtistsTable extends DbArtists
    with TableInfo<$DbArtistsTable, DbArtist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portraitUriMeta = const VerificationMeta(
    'portraitUri',
  );
  @override
  late final GeneratedColumn<String> portraitUri = GeneratedColumn<String>(
    'portrait_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceAttributionMeta = const VerificationMeta(
    'sourceAttribution',
  );
  @override
  late final GeneratedColumn<String> sourceAttribution =
      GeneratedColumn<String>(
        'source_attribution',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isFollowedMeta = const VerificationMeta(
    'isFollowed',
  );
  @override
  late final GeneratedColumn<bool> isFollowed = GeneratedColumn<bool>(
    'is_followed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_followed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    portraitUri,
    sourceAttribution,
    isFollowed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbArtist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('portrait_uri')) {
      context.handle(
        _portraitUriMeta,
        portraitUri.isAcceptableOrUnknown(
          data['portrait_uri']!,
          _portraitUriMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_portraitUriMeta);
    }
    if (data.containsKey('source_attribution')) {
      context.handle(
        _sourceAttributionMeta,
        sourceAttribution.isAcceptableOrUnknown(
          data['source_attribution']!,
          _sourceAttributionMeta,
        ),
      );
    }
    if (data.containsKey('is_followed')) {
      context.handle(
        _isFollowedMeta,
        isFollowed.isAcceptableOrUnknown(data['is_followed']!, _isFollowedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbArtist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbArtist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      portraitUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portrait_uri'],
      )!,
      sourceAttribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_attribution'],
      ),
      isFollowed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_followed'],
      )!,
    );
  }

  @override
  $DbArtistsTable createAlias(String alias) {
    return $DbArtistsTable(attachedDatabase, alias);
  }
}

class DbArtist extends DataClass implements Insertable<DbArtist> {
  final String id;
  final String name;
  final String portraitUri;
  final String? sourceAttribution;
  final bool isFollowed;
  const DbArtist({
    required this.id,
    required this.name,
    required this.portraitUri,
    this.sourceAttribution,
    required this.isFollowed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['portrait_uri'] = Variable<String>(portraitUri);
    if (!nullToAbsent || sourceAttribution != null) {
      map['source_attribution'] = Variable<String>(sourceAttribution);
    }
    map['is_followed'] = Variable<bool>(isFollowed);
    return map;
  }

  DbArtistsCompanion toCompanion(bool nullToAbsent) {
    return DbArtistsCompanion(
      id: Value(id),
      name: Value(name),
      portraitUri: Value(portraitUri),
      sourceAttribution: sourceAttribution == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAttribution),
      isFollowed: Value(isFollowed),
    );
  }

  factory DbArtist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbArtist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      portraitUri: serializer.fromJson<String>(json['portraitUri']),
      sourceAttribution: serializer.fromJson<String?>(
        json['sourceAttribution'],
      ),
      isFollowed: serializer.fromJson<bool>(json['isFollowed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'portraitUri': serializer.toJson<String>(portraitUri),
      'sourceAttribution': serializer.toJson<String?>(sourceAttribution),
      'isFollowed': serializer.toJson<bool>(isFollowed),
    };
  }

  DbArtist copyWith({
    String? id,
    String? name,
    String? portraitUri,
    Value<String?> sourceAttribution = const Value.absent(),
    bool? isFollowed,
  }) => DbArtist(
    id: id ?? this.id,
    name: name ?? this.name,
    portraitUri: portraitUri ?? this.portraitUri,
    sourceAttribution: sourceAttribution.present
        ? sourceAttribution.value
        : this.sourceAttribution,
    isFollowed: isFollowed ?? this.isFollowed,
  );
  DbArtist copyWithCompanion(DbArtistsCompanion data) {
    return DbArtist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      portraitUri: data.portraitUri.present
          ? data.portraitUri.value
          : this.portraitUri,
      sourceAttribution: data.sourceAttribution.present
          ? data.sourceAttribution.value
          : this.sourceAttribution,
      isFollowed: data.isFollowed.present
          ? data.isFollowed.value
          : this.isFollowed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbArtist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('portraitUri: $portraitUri, ')
          ..write('sourceAttribution: $sourceAttribution, ')
          ..write('isFollowed: $isFollowed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, portraitUri, sourceAttribution, isFollowed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbArtist &&
          other.id == this.id &&
          other.name == this.name &&
          other.portraitUri == this.portraitUri &&
          other.sourceAttribution == this.sourceAttribution &&
          other.isFollowed == this.isFollowed);
}

class DbArtistsCompanion extends UpdateCompanion<DbArtist> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> portraitUri;
  final Value<String?> sourceAttribution;
  final Value<bool> isFollowed;
  final Value<int> rowid;
  const DbArtistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.portraitUri = const Value.absent(),
    this.sourceAttribution = const Value.absent(),
    this.isFollowed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbArtistsCompanion.insert({
    required String id,
    required String name,
    required String portraitUri,
    this.sourceAttribution = const Value.absent(),
    this.isFollowed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       portraitUri = Value(portraitUri);
  static Insertable<DbArtist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? portraitUri,
    Expression<String>? sourceAttribution,
    Expression<bool>? isFollowed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (portraitUri != null) 'portrait_uri': portraitUri,
      if (sourceAttribution != null) 'source_attribution': sourceAttribution,
      if (isFollowed != null) 'is_followed': isFollowed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbArtistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? portraitUri,
    Value<String?>? sourceAttribution,
    Value<bool>? isFollowed,
    Value<int>? rowid,
  }) {
    return DbArtistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      portraitUri: portraitUri ?? this.portraitUri,
      sourceAttribution: sourceAttribution ?? this.sourceAttribution,
      isFollowed: isFollowed ?? this.isFollowed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (portraitUri.present) {
      map['portrait_uri'] = Variable<String>(portraitUri.value);
    }
    if (sourceAttribution.present) {
      map['source_attribution'] = Variable<String>(sourceAttribution.value);
    }
    if (isFollowed.present) {
      map['is_followed'] = Variable<bool>(isFollowed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbArtistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('portraitUri: $portraitUri, ')
          ..write('sourceAttribution: $sourceAttribution, ')
          ..write('isFollowed: $isFollowed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbQueueEntriesTable extends DbQueueEntries
    with TableInfo<$DbQueueEntriesTable, DbQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('guest'),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, profileId, trackId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $DbQueueEntriesTable createAlias(String alias) {
    return $DbQueueEntriesTable(attachedDatabase, alias);
  }
}

class DbQueueEntry extends DataClass implements Insertable<DbQueueEntry> {
  final String id;
  final String profileId;
  final String trackId;
  final int position;
  const DbQueueEntry({
    required this.id,
    required this.profileId,
    required this.trackId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['track_id'] = Variable<String>(trackId);
    map['position'] = Variable<int>(position);
    return map;
  }

  DbQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return DbQueueEntriesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      trackId: Value(trackId),
      position: Value(position),
    );
  }

  factory DbQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbQueueEntry(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'trackId': serializer.toJson<String>(trackId),
      'position': serializer.toJson<int>(position),
    };
  }

  DbQueueEntry copyWith({
    String? id,
    String? profileId,
    String? trackId,
    int? position,
  }) => DbQueueEntry(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
  );
  DbQueueEntry copyWithCompanion(DbQueueEntriesCompanion data) {
    return DbQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbQueueEntry(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, trackId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbQueueEntry &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.trackId == this.trackId &&
          other.position == this.position);
}

class DbQueueEntriesCompanion extends UpdateCompanion<DbQueueEntry> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> trackId;
  final Value<int> position;
  final Value<int> rowid;
  const DbQueueEntriesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbQueueEntriesCompanion.insert({
    required String id,
    this.profileId = const Value.absent(),
    required String trackId,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       position = Value(position);
  static Insertable<DbQueueEntry> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? trackId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbQueueEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? trackId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return DbQueueEntriesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbQueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbQueueStateTable extends DbQueueState
    with TableInfo<$DbQueueStateTable, DbQueueStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbQueueStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('guest'),
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('off'),
  );
  static const VerificationMeta _isShuffleMeta = const VerificationMeta(
    'isShuffle',
  );
  @override
  late final GeneratedColumn<bool> isShuffle = GeneratedColumn<bool>(
    'is_shuffle',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shuffle" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPlayingMeta = const VerificationMeta(
    'isPlaying',
  );
  @override
  late final GeneratedColumn<bool> isPlaying = GeneratedColumn<bool>(
    'is_playing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_playing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    currentIndex,
    repeatMode,
    isShuffle,
    positionMs,
    isPlaying,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_queue_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbQueueStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('is_shuffle')) {
      context.handle(
        _isShuffleMeta,
        isShuffle.isAcceptableOrUnknown(data['is_shuffle']!, _isShuffleMeta),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('is_playing')) {
      context.handle(
        _isPlayingMeta,
        isPlaying.isAcceptableOrUnknown(data['is_playing']!, _isPlayingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  DbQueueStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbQueueStateData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
      isShuffle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shuffle'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      isPlaying: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_playing'],
      )!,
    );
  }

  @override
  $DbQueueStateTable createAlias(String alias) {
    return $DbQueueStateTable(attachedDatabase, alias);
  }
}

class DbQueueStateData extends DataClass
    implements Insertable<DbQueueStateData> {
  final String profileId;
  final int currentIndex;
  final String repeatMode;
  final bool isShuffle;
  final int positionMs;
  final bool isPlaying;
  const DbQueueStateData({
    required this.profileId,
    required this.currentIndex,
    required this.repeatMode,
    required this.isShuffle,
    required this.positionMs,
    required this.isPlaying,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['current_index'] = Variable<int>(currentIndex);
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['is_shuffle'] = Variable<bool>(isShuffle);
    map['position_ms'] = Variable<int>(positionMs);
    map['is_playing'] = Variable<bool>(isPlaying);
    return map;
  }

  DbQueueStateCompanion toCompanion(bool nullToAbsent) {
    return DbQueueStateCompanion(
      profileId: Value(profileId),
      currentIndex: Value(currentIndex),
      repeatMode: Value(repeatMode),
      isShuffle: Value(isShuffle),
      positionMs: Value(positionMs),
      isPlaying: Value(isPlaying),
    );
  }

  factory DbQueueStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbQueueStateData(
      profileId: serializer.fromJson<String>(json['profileId']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      isShuffle: serializer.fromJson<bool>(json['isShuffle']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      isPlaying: serializer.fromJson<bool>(json['isPlaying']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'isShuffle': serializer.toJson<bool>(isShuffle),
      'positionMs': serializer.toJson<int>(positionMs),
      'isPlaying': serializer.toJson<bool>(isPlaying),
    };
  }

  DbQueueStateData copyWith({
    String? profileId,
    int? currentIndex,
    String? repeatMode,
    bool? isShuffle,
    int? positionMs,
    bool? isPlaying,
  }) => DbQueueStateData(
    profileId: profileId ?? this.profileId,
    currentIndex: currentIndex ?? this.currentIndex,
    repeatMode: repeatMode ?? this.repeatMode,
    isShuffle: isShuffle ?? this.isShuffle,
    positionMs: positionMs ?? this.positionMs,
    isPlaying: isPlaying ?? this.isPlaying,
  );
  DbQueueStateData copyWithCompanion(DbQueueStateCompanion data) {
    return DbQueueStateData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      isShuffle: data.isShuffle.present ? data.isShuffle.value : this.isShuffle,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      isPlaying: data.isPlaying.present ? data.isPlaying.value : this.isPlaying,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbQueueStateData(')
          ..write('profileId: $profileId, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('isShuffle: $isShuffle, ')
          ..write('positionMs: $positionMs, ')
          ..write('isPlaying: $isPlaying')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    currentIndex,
    repeatMode,
    isShuffle,
    positionMs,
    isPlaying,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbQueueStateData &&
          other.profileId == this.profileId &&
          other.currentIndex == this.currentIndex &&
          other.repeatMode == this.repeatMode &&
          other.isShuffle == this.isShuffle &&
          other.positionMs == this.positionMs &&
          other.isPlaying == this.isPlaying);
}

class DbQueueStateCompanion extends UpdateCompanion<DbQueueStateData> {
  final Value<String> profileId;
  final Value<int> currentIndex;
  final Value<String> repeatMode;
  final Value<bool> isShuffle;
  final Value<int> positionMs;
  final Value<bool> isPlaying;
  final Value<int> rowid;
  const DbQueueStateCompanion({
    this.profileId = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.isShuffle = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.isPlaying = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbQueueStateCompanion.insert({
    this.profileId = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.isShuffle = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.isPlaying = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<DbQueueStateData> custom({
    Expression<String>? profileId,
    Expression<int>? currentIndex,
    Expression<String>? repeatMode,
    Expression<bool>? isShuffle,
    Expression<int>? positionMs,
    Expression<bool>? isPlaying,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (currentIndex != null) 'current_index': currentIndex,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (isShuffle != null) 'is_shuffle': isShuffle,
      if (positionMs != null) 'position_ms': positionMs,
      if (isPlaying != null) 'is_playing': isPlaying,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbQueueStateCompanion copyWith({
    Value<String>? profileId,
    Value<int>? currentIndex,
    Value<String>? repeatMode,
    Value<bool>? isShuffle,
    Value<int>? positionMs,
    Value<bool>? isPlaying,
    Value<int>? rowid,
  }) {
    return DbQueueStateCompanion(
      profileId: profileId ?? this.profileId,
      currentIndex: currentIndex ?? this.currentIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffle: isShuffle ?? this.isShuffle,
      positionMs: positionMs ?? this.positionMs,
      isPlaying: isPlaying ?? this.isPlaying,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (isShuffle.present) {
      map['is_shuffle'] = Variable<bool>(isShuffle.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (isPlaying.present) {
      map['is_playing'] = Variable<bool>(isPlaying.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbQueueStateCompanion(')
          ..write('profileId: $profileId, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('isShuffle: $isShuffle, ')
          ..write('positionMs: $positionMs, ')
          ..write('isPlaying: $isPlaying, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbPreferencesTable extends DbPreferences
    with TableInfo<$DbPreferencesTable, DbPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DbPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPreference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DbPreferencesTable createAlias(String alias) {
    return $DbPreferencesTable(attachedDatabase, alias);
  }
}

class DbPreference extends DataClass implements Insertable<DbPreference> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const DbPreference({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DbPreferencesCompanion toCompanion(bool nullToAbsent) {
    return DbPreferencesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbPreference copyWith({String? key, String? value, DateTime? updatedAt}) =>
      DbPreference(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DbPreference copyWithCompanion(DbPreferencesCompanion data) {
    return DbPreference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPreference(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPreference &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class DbPreferencesCompanion extends UpdateCompanion<DbPreference> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DbPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbPreferencesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<DbPreference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DbPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbSearchHistoryTable extends DbSearchHistory
    with TableInfo<$DbSearchHistoryTable, DbSearchHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbSearchHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('guest'),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, profileId, query, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_search_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSearchHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbSearchHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSearchHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DbSearchHistoryTable createAlias(String alias) {
    return $DbSearchHistoryTable(attachedDatabase, alias);
  }
}

class DbSearchHistoryData extends DataClass
    implements Insertable<DbSearchHistoryData> {
  final String id;
  final String profileId;
  final String query;
  final DateTime createdAt;
  const DbSearchHistoryData({
    required this.id,
    required this.profileId,
    required this.query,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['query'] = Variable<String>(query);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DbSearchHistoryCompanion toCompanion(bool nullToAbsent) {
    return DbSearchHistoryCompanion(
      id: Value(id),
      profileId: Value(profileId),
      query: Value(query),
      createdAt: Value(createdAt),
    );
  }

  factory DbSearchHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSearchHistoryData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      query: serializer.fromJson<String>(json['query']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'query': serializer.toJson<String>(query),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbSearchHistoryData copyWith({
    String? id,
    String? profileId,
    String? query,
    DateTime? createdAt,
  }) => DbSearchHistoryData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    query: query ?? this.query,
    createdAt: createdAt ?? this.createdAt,
  );
  DbSearchHistoryData copyWithCompanion(DbSearchHistoryCompanion data) {
    return DbSearchHistoryData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      query: data.query.present ? data.query.value : this.query,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSearchHistoryData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('query: $query, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, query, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSearchHistoryData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.query == this.query &&
          other.createdAt == this.createdAt);
}

class DbSearchHistoryCompanion extends UpdateCompanion<DbSearchHistoryData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> query;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DbSearchHistoryCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.query = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbSearchHistoryCompanion.insert({
    required String id,
    this.profileId = const Value.absent(),
    required String query,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       query = Value(query),
       createdAt = Value(createdAt);
  static Insertable<DbSearchHistoryData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? query,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (query != null) 'query': query,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbSearchHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? query,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DbSearchHistoryCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      query: query ?? this.query,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbSearchHistoryCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('query: $query, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbSyncOutboxTable extends DbSyncOutbox
    with TableInfo<$DbSyncOutboxTable, DbSyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbSyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    deviceId,
    entityType,
    entityId,
    operationType,
    payloadJson,
    createdAt,
    retryCount,
    lastAttemptAt,
    lastError,
    idempotencyKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbSyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
    );
  }

  @override
  $DbSyncOutboxTable createAlias(String alias) {
    return $DbSyncOutboxTable(attachedDatabase, alias);
  }
}

class DbSyncOutboxData extends DataClass
    implements Insertable<DbSyncOutboxData> {
  final String id;
  final String profileId;
  final String deviceId;
  final String entityType;
  final String entityId;
  final String operationType;
  final String payloadJson;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final String? lastError;
  final String idempotencyKey;
  const DbSyncOutboxData({
    required this.id,
    required this.profileId,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payloadJson,
    required this.createdAt,
    required this.retryCount,
    this.lastAttemptAt,
    this.lastError,
    required this.idempotencyKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['device_id'] = Variable<String>(deviceId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation_type'] = Variable<String>(operationType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    return map;
  }

  DbSyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return DbSyncOutboxCompanion(
      id: Value(id),
      profileId: Value(profileId),
      deviceId: Value(deviceId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      idempotencyKey: Value(idempotencyKey),
    );
  }

  factory DbSyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSyncOutboxData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'deviceId': serializer.toJson<String>(deviceId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(operationType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
    };
  }

  DbSyncOutboxData copyWith({
    String? id,
    String? profileId,
    String? deviceId,
    String? entityType,
    String? entityId,
    String? operationType,
    String? payloadJson,
    DateTime? createdAt,
    int? retryCount,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    String? idempotencyKey,
  }) => DbSyncOutboxData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    deviceId: deviceId ?? this.deviceId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operationType: operationType ?? this.operationType,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
  );
  DbSyncOutboxData copyWithCompanion(DbSyncOutboxCompanion data) {
    return DbSyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSyncOutboxData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('idempotencyKey: $idempotencyKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    deviceId,
    entityType,
    entityId,
    operationType,
    payloadJson,
    createdAt,
    retryCount,
    lastAttemptAt,
    lastError,
    idempotencyKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSyncOutboxData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.deviceId == this.deviceId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastError == this.lastError &&
          other.idempotencyKey == this.idempotencyKey);
}

class DbSyncOutboxCompanion extends UpdateCompanion<DbSyncOutboxData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> deviceId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operationType;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> lastError;
  final Value<String> idempotencyKey;
  final Value<int> rowid;
  const DbSyncOutboxCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbSyncOutboxCompanion.insert({
    required String id,
    required String profileId,
    required String deviceId,
    required String entityType,
    required String entityId,
    required String operationType,
    required String payloadJson,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required String idempotencyKey,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       deviceId = Value(deviceId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operationType = Value(operationType),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       idempotencyKey = Value(idempotencyKey);
  static Insertable<DbSyncOutboxData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? deviceId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? lastError,
    Expression<String>? idempotencyKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (deviceId != null) 'device_id': deviceId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbSyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? deviceId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operationType,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? lastError,
    Value<String>? idempotencyKey,
    Value<int>? rowid,
  }) {
    return DbSyncOutboxCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      deviceId: deviceId ?? this.deviceId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbSyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbSyncStateTable extends DbSyncState
    with TableInfo<$DbSyncStateTable, DbSyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbSyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastServerRevisionMeta =
      const VerificationMeta('lastServerRevision');
  @override
  late final GeneratedColumn<int> lastServerRevision = GeneratedColumn<int>(
    'last_server_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('idle'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    lastSyncedAt,
    lastServerRevision,
    syncStatus,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_server_revision')) {
      context.handle(
        _lastServerRevisionMeta,
        lastServerRevision.isAcceptableOrUnknown(
          data['last_server_revision']!,
          _lastServerRevisionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  DbSyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSyncStateData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      lastServerRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_server_revision'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $DbSyncStateTable createAlias(String alias) {
    return $DbSyncStateTable(attachedDatabase, alias);
  }
}

class DbSyncStateData extends DataClass implements Insertable<DbSyncStateData> {
  final String profileId;
  final DateTime? lastSyncedAt;
  final int lastServerRevision;
  final String syncStatus;
  final String? errorMessage;
  const DbSyncStateData({
    required this.profileId,
    this.lastSyncedAt,
    required this.lastServerRevision,
    required this.syncStatus,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['last_server_revision'] = Variable<int>(lastServerRevision);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  DbSyncStateCompanion toCompanion(bool nullToAbsent) {
    return DbSyncStateCompanion(
      profileId: Value(profileId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      lastServerRevision: Value(lastServerRevision),
      syncStatus: Value(syncStatus),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory DbSyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSyncStateData(
      profileId: serializer.fromJson<String>(json['profileId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      lastServerRevision: serializer.fromJson<int>(json['lastServerRevision']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'lastServerRevision': serializer.toJson<int>(lastServerRevision),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  DbSyncStateData copyWith({
    String? profileId,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    int? lastServerRevision,
    String? syncStatus,
    Value<String?> errorMessage = const Value.absent(),
  }) => DbSyncStateData(
    profileId: profileId ?? this.profileId,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    lastServerRevision: lastServerRevision ?? this.lastServerRevision,
    syncStatus: syncStatus ?? this.syncStatus,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  DbSyncStateData copyWithCompanion(DbSyncStateCompanion data) {
    return DbSyncStateData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastServerRevision: data.lastServerRevision.present
          ? data.lastServerRevision.value
          : this.lastServerRevision,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSyncStateData(')
          ..write('profileId: $profileId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastServerRevision: $lastServerRevision, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    lastSyncedAt,
    lastServerRevision,
    syncStatus,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSyncStateData &&
          other.profileId == this.profileId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastServerRevision == this.lastServerRevision &&
          other.syncStatus == this.syncStatus &&
          other.errorMessage == this.errorMessage);
}

class DbSyncStateCompanion extends UpdateCompanion<DbSyncStateData> {
  final Value<String> profileId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> lastServerRevision;
  final Value<String> syncStatus;
  final Value<String?> errorMessage;
  final Value<int> rowid;
  const DbSyncStateCompanion({
    this.profileId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastServerRevision = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbSyncStateCompanion.insert({
    required String profileId,
    this.lastSyncedAt = const Value.absent(),
    this.lastServerRevision = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId);
  static Insertable<DbSyncStateData> custom({
    Expression<String>? profileId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? lastServerRevision,
    Expression<String>? syncStatus,
    Expression<String>? errorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastServerRevision != null)
        'last_server_revision': lastServerRevision,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (errorMessage != null) 'error_message': errorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbSyncStateCompanion copyWith({
    Value<String>? profileId,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? lastServerRevision,
    Value<String>? syncStatus,
    Value<String?>? errorMessage,
    Value<int>? rowid,
  }) {
    return DbSyncStateCompanion(
      profileId: profileId ?? this.profileId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastServerRevision: lastServerRevision ?? this.lastServerRevision,
      syncStatus: syncStatus ?? this.syncStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastServerRevision.present) {
      map['last_server_revision'] = Variable<int>(lastServerRevision.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbSyncStateCompanion(')
          ..write('profileId: $profileId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastServerRevision: $lastServerRevision, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbTombstonesTable extends DbTombstones
    with TableInfo<$DbTombstonesTable, DbTombstone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbTombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    entityType,
    entityId,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTombstone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbTombstone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTombstone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
    );
  }

  @override
  $DbTombstonesTable createAlias(String alias) {
    return $DbTombstonesTable(attachedDatabase, alias);
  }
}

class DbTombstone extends DataClass implements Insertable<DbTombstone> {
  final String id;
  final String profileId;
  final String entityType;
  final String entityId;
  final DateTime deletedAt;
  const DbTombstone({
    required this.id,
    required this.profileId,
    required this.entityType,
    required this.entityId,
    required this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  DbTombstonesCompanion toCompanion(bool nullToAbsent) {
    return DbTombstonesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      deletedAt: Value(deletedAt),
    );
  }

  factory DbTombstone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTombstone(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  DbTombstone copyWith({
    String? id,
    String? profileId,
    String? entityType,
    String? entityId,
    DateTime? deletedAt,
  }) => DbTombstone(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    deletedAt: deletedAt ?? this.deletedAt,
  );
  DbTombstone copyWithCompanion(DbTombstonesCompanion data) {
    return DbTombstone(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTombstone(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, entityType, entityId, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTombstone &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.deletedAt == this.deletedAt);
}

class DbTombstonesCompanion extends UpdateCompanion<DbTombstone> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<DateTime> deletedAt;
  final Value<int> rowid;
  const DbTombstonesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbTombstonesCompanion.insert({
    required String id,
    required String profileId,
    required String entityType,
    required String entityId,
    required DateTime deletedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       deletedAt = Value(deletedAt);
  static Insertable<DbTombstone> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbTombstonesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<DateTime>? deletedAt,
    Value<int>? rowid,
  }) {
    return DbTombstonesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbTombstonesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbCacheEntriesTable extends DbCacheEntries
    with TableInfo<$DbCacheEntriesTable, DbCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentSizeBytesMeta = const VerificationMeta(
    'contentSizeBytes',
  );
  @override
  late final GeneratedColumn<int> contentSizeBytes = GeneratedColumn<int>(
    'content_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('audio/mpeg'),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadStateMeta = const VerificationMeta(
    'downloadState',
  );
  @override
  late final GeneratedColumn<String> downloadState = GeneratedColumn<String>(
    'download_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('availableOffline'),
  );
  static const VerificationMeta _sha256HashMeta = const VerificationMeta(
    'sha256Hash',
  );
  @override
  late final GeneratedColumn<String> sha256Hash = GeneratedColumn<String>(
    'sha256_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    cacheKey,
    filePath,
    contentSizeBytes,
    mimeType,
    durationMs,
    providerId,
    downloadState,
    sha256Hash,
    cachedAt,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('content_size_bytes')) {
      context.handle(
        _contentSizeBytesMeta,
        contentSizeBytes.isAcceptableOrUnknown(
          data['content_size_bytes']!,
          _contentSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentSizeBytesMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('download_state')) {
      context.handle(
        _downloadStateMeta,
        downloadState.isAcceptableOrUnknown(
          data['download_state']!,
          _downloadStateMeta,
        ),
      );
    }
    if (data.containsKey('sha256_hash')) {
      context.handle(
        _sha256HashMeta,
        sha256Hash.isAcceptableOrUnknown(data['sha256_hash']!, _sha256HashMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  DbCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbCacheEntry(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      contentSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_size_bytes'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      downloadState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_state'],
      )!,
      sha256Hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256_hash'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      )!,
    );
  }

  @override
  $DbCacheEntriesTable createAlias(String alias) {
    return $DbCacheEntriesTable(attachedDatabase, alias);
  }
}

class DbCacheEntry extends DataClass implements Insertable<DbCacheEntry> {
  final String trackId;
  final String cacheKey;
  final String filePath;
  final int contentSizeBytes;
  final String mimeType;
  final int? durationMs;
  final String providerId;
  final String downloadState;
  final String? sha256Hash;
  final DateTime cachedAt;
  final DateTime lastAccessedAt;
  const DbCacheEntry({
    required this.trackId,
    required this.cacheKey,
    required this.filePath,
    required this.contentSizeBytes,
    required this.mimeType,
    this.durationMs,
    required this.providerId,
    required this.downloadState,
    this.sha256Hash,
    required this.cachedAt,
    required this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['cache_key'] = Variable<String>(cacheKey);
    map['file_path'] = Variable<String>(filePath);
    map['content_size_bytes'] = Variable<int>(contentSizeBytes);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['provider_id'] = Variable<String>(providerId);
    map['download_state'] = Variable<String>(downloadState);
    if (!nullToAbsent || sha256Hash != null) {
      map['sha256_hash'] = Variable<String>(sha256Hash);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    return map;
  }

  DbCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return DbCacheEntriesCompanion(
      trackId: Value(trackId),
      cacheKey: Value(cacheKey),
      filePath: Value(filePath),
      contentSizeBytes: Value(contentSizeBytes),
      mimeType: Value(mimeType),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      providerId: Value(providerId),
      downloadState: Value(downloadState),
      sha256Hash: sha256Hash == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256Hash),
      cachedAt: Value(cachedAt),
      lastAccessedAt: Value(lastAccessedAt),
    );
  }

  factory DbCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbCacheEntry(
      trackId: serializer.fromJson<String>(json['trackId']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      filePath: serializer.fromJson<String>(json['filePath']),
      contentSizeBytes: serializer.fromJson<int>(json['contentSizeBytes']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      providerId: serializer.fromJson<String>(json['providerId']),
      downloadState: serializer.fromJson<String>(json['downloadState']),
      sha256Hash: serializer.fromJson<String?>(json['sha256Hash']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'filePath': serializer.toJson<String>(filePath),
      'contentSizeBytes': serializer.toJson<int>(contentSizeBytes),
      'mimeType': serializer.toJson<String>(mimeType),
      'durationMs': serializer.toJson<int?>(durationMs),
      'providerId': serializer.toJson<String>(providerId),
      'downloadState': serializer.toJson<String>(downloadState),
      'sha256Hash': serializer.toJson<String?>(sha256Hash),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
    };
  }

  DbCacheEntry copyWith({
    String? trackId,
    String? cacheKey,
    String? filePath,
    int? contentSizeBytes,
    String? mimeType,
    Value<int?> durationMs = const Value.absent(),
    String? providerId,
    String? downloadState,
    Value<String?> sha256Hash = const Value.absent(),
    DateTime? cachedAt,
    DateTime? lastAccessedAt,
  }) => DbCacheEntry(
    trackId: trackId ?? this.trackId,
    cacheKey: cacheKey ?? this.cacheKey,
    filePath: filePath ?? this.filePath,
    contentSizeBytes: contentSizeBytes ?? this.contentSizeBytes,
    mimeType: mimeType ?? this.mimeType,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    providerId: providerId ?? this.providerId,
    downloadState: downloadState ?? this.downloadState,
    sha256Hash: sha256Hash.present ? sha256Hash.value : this.sha256Hash,
    cachedAt: cachedAt ?? this.cachedAt,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
  );
  DbCacheEntry copyWithCompanion(DbCacheEntriesCompanion data) {
    return DbCacheEntry(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      contentSizeBytes: data.contentSizeBytes.present
          ? data.contentSizeBytes.value
          : this.contentSizeBytes,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      downloadState: data.downloadState.present
          ? data.downloadState.value
          : this.downloadState,
      sha256Hash: data.sha256Hash.present
          ? data.sha256Hash.value
          : this.sha256Hash,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbCacheEntry(')
          ..write('trackId: $trackId, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('filePath: $filePath, ')
          ..write('contentSizeBytes: $contentSizeBytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('durationMs: $durationMs, ')
          ..write('providerId: $providerId, ')
          ..write('downloadState: $downloadState, ')
          ..write('sha256Hash: $sha256Hash, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    cacheKey,
    filePath,
    contentSizeBytes,
    mimeType,
    durationMs,
    providerId,
    downloadState,
    sha256Hash,
    cachedAt,
    lastAccessedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbCacheEntry &&
          other.trackId == this.trackId &&
          other.cacheKey == this.cacheKey &&
          other.filePath == this.filePath &&
          other.contentSizeBytes == this.contentSizeBytes &&
          other.mimeType == this.mimeType &&
          other.durationMs == this.durationMs &&
          other.providerId == this.providerId &&
          other.downloadState == this.downloadState &&
          other.sha256Hash == this.sha256Hash &&
          other.cachedAt == this.cachedAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class DbCacheEntriesCompanion extends UpdateCompanion<DbCacheEntry> {
  final Value<String> trackId;
  final Value<String> cacheKey;
  final Value<String> filePath;
  final Value<int> contentSizeBytes;
  final Value<String> mimeType;
  final Value<int?> durationMs;
  final Value<String> providerId;
  final Value<String> downloadState;
  final Value<String?> sha256Hash;
  final Value<DateTime> cachedAt;
  final Value<DateTime> lastAccessedAt;
  final Value<int> rowid;
  const DbCacheEntriesCompanion({
    this.trackId = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.filePath = const Value.absent(),
    this.contentSizeBytes = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.providerId = const Value.absent(),
    this.downloadState = const Value.absent(),
    this.sha256Hash = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbCacheEntriesCompanion.insert({
    required String trackId,
    required String cacheKey,
    required String filePath,
    required int contentSizeBytes,
    this.mimeType = const Value.absent(),
    this.durationMs = const Value.absent(),
    required String providerId,
    this.downloadState = const Value.absent(),
    this.sha256Hash = const Value.absent(),
    required DateTime cachedAt,
    required DateTime lastAccessedAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       cacheKey = Value(cacheKey),
       filePath = Value(filePath),
       contentSizeBytes = Value(contentSizeBytes),
       providerId = Value(providerId),
       cachedAt = Value(cachedAt),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<DbCacheEntry> custom({
    Expression<String>? trackId,
    Expression<String>? cacheKey,
    Expression<String>? filePath,
    Expression<int>? contentSizeBytes,
    Expression<String>? mimeType,
    Expression<int>? durationMs,
    Expression<String>? providerId,
    Expression<String>? downloadState,
    Expression<String>? sha256Hash,
    Expression<DateTime>? cachedAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (cacheKey != null) 'cache_key': cacheKey,
      if (filePath != null) 'file_path': filePath,
      if (contentSizeBytes != null) 'content_size_bytes': contentSizeBytes,
      if (mimeType != null) 'mime_type': mimeType,
      if (durationMs != null) 'duration_ms': durationMs,
      if (providerId != null) 'provider_id': providerId,
      if (downloadState != null) 'download_state': downloadState,
      if (sha256Hash != null) 'sha256_hash': sha256Hash,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbCacheEntriesCompanion copyWith({
    Value<String>? trackId,
    Value<String>? cacheKey,
    Value<String>? filePath,
    Value<int>? contentSizeBytes,
    Value<String>? mimeType,
    Value<int?>? durationMs,
    Value<String>? providerId,
    Value<String>? downloadState,
    Value<String?>? sha256Hash,
    Value<DateTime>? cachedAt,
    Value<DateTime>? lastAccessedAt,
    Value<int>? rowid,
  }) {
    return DbCacheEntriesCompanion(
      trackId: trackId ?? this.trackId,
      cacheKey: cacheKey ?? this.cacheKey,
      filePath: filePath ?? this.filePath,
      contentSizeBytes: contentSizeBytes ?? this.contentSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      durationMs: durationMs ?? this.durationMs,
      providerId: providerId ?? this.providerId,
      downloadState: downloadState ?? this.downloadState,
      sha256Hash: sha256Hash ?? this.sha256Hash,
      cachedAt: cachedAt ?? this.cachedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (contentSizeBytes.present) {
      map['content_size_bytes'] = Variable<int>(contentSizeBytes.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (downloadState.present) {
      map['download_state'] = Variable<String>(downloadState.value);
    }
    if (sha256Hash.present) {
      map['sha256_hash'] = Variable<String>(sha256Hash.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbCacheEntriesCompanion(')
          ..write('trackId: $trackId, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('filePath: $filePath, ')
          ..write('contentSizeBytes: $contentSizeBytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('durationMs: $durationMs, ')
          ..write('providerId: $providerId, ')
          ..write('downloadState: $downloadState, ')
          ..write('sha256Hash: $sha256Hash, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CaviaDatabase extends GeneratedDatabase {
  _$CaviaDatabase(QueryExecutor e) : super(e);
  $CaviaDatabaseManager get managers => $CaviaDatabaseManager(this);
  late final $DbTracksTable dbTracks = $DbTracksTable(this);
  late final $DbPlaylistsTable dbPlaylists = $DbPlaylistsTable(this);
  late final $DbPlaylistEntriesTable dbPlaylistEntries =
      $DbPlaylistEntriesTable(this);
  late final $DbLikedSongsTable dbLikedSongs = $DbLikedSongsTable(this);
  late final $DbAlbumsTable dbAlbums = $DbAlbumsTable(this);
  late final $DbArtistsTable dbArtists = $DbArtistsTable(this);
  late final $DbQueueEntriesTable dbQueueEntries = $DbQueueEntriesTable(this);
  late final $DbQueueStateTable dbQueueState = $DbQueueStateTable(this);
  late final $DbPreferencesTable dbPreferences = $DbPreferencesTable(this);
  late final $DbSearchHistoryTable dbSearchHistory = $DbSearchHistoryTable(
    this,
  );
  late final $DbSyncOutboxTable dbSyncOutbox = $DbSyncOutboxTable(this);
  late final $DbSyncStateTable dbSyncState = $DbSyncStateTable(this);
  late final $DbTombstonesTable dbTombstones = $DbTombstonesTable(this);
  late final $DbCacheEntriesTable dbCacheEntries = $DbCacheEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dbTracks,
    dbPlaylists,
    dbPlaylistEntries,
    dbLikedSongs,
    dbAlbums,
    dbArtists,
    dbQueueEntries,
    dbQueueState,
    dbPreferences,
    dbSearchHistory,
    dbSyncOutbox,
    dbSyncState,
    dbTombstones,
    dbCacheEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_playlist_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_playlist_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_liked_songs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_queue_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_cache_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DbTracksTableCreateCompanionBuilder =
    DbTracksCompanion Function({
      required String id,
      Value<String> providerId,
      Value<String> providerTrackId,
      required String title,
      required String artist,
      Value<String> artistsJson,
      required String album,
      required int durationMs,
      required String artworkUri,
      Value<String?> isrc,
      Value<bool> explicit,
      Value<String> availabilityState,
      Value<String?> sourceAttribution,
      required DateTime dateAdded,
      Value<bool> isCached,
      Value<String?> localCachePath,
      Value<int> playCount,
      Value<DateTime?> lastPlayedAt,
      Value<String> lyricsJson,
      Value<int> rowid,
    });
typedef $$DbTracksTableUpdateCompanionBuilder =
    DbTracksCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> providerTrackId,
      Value<String> title,
      Value<String> artist,
      Value<String> artistsJson,
      Value<String> album,
      Value<int> durationMs,
      Value<String> artworkUri,
      Value<String?> isrc,
      Value<bool> explicit,
      Value<String> availabilityState,
      Value<String?> sourceAttribution,
      Value<DateTime> dateAdded,
      Value<bool> isCached,
      Value<String?> localCachePath,
      Value<int> playCount,
      Value<DateTime?> lastPlayedAt,
      Value<String> lyricsJson,
      Value<int> rowid,
    });

final class $$DbTracksTableReferences
    extends BaseReferences<_$CaviaDatabase, $DbTracksTable, DbTrack> {
  $$DbTracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DbPlaylistEntriesTable, List<DbPlaylistEntry>>
  _dbPlaylistEntriesRefsTable(_$CaviaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dbPlaylistEntries,
        aliasName: 'db_tracks__id__db_playlist_entries__track_id',
      );

  $$DbPlaylistEntriesTableProcessedTableManager get dbPlaylistEntriesRefs {
    final manager = $$DbPlaylistEntriesTableTableManager(
      $_db,
      $_db.dbPlaylistEntries,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dbPlaylistEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DbLikedSongsTable, List<DbLikedSong>>
  _dbLikedSongsRefsTable(_$CaviaDatabase db) => MultiTypedResultKey.fromTable(
    db.dbLikedSongs,
    aliasName: 'db_tracks__id__db_liked_songs__track_id',
  );

  $$DbLikedSongsTableProcessedTableManager get dbLikedSongsRefs {
    final manager = $$DbLikedSongsTableTableManager(
      $_db,
      $_db.dbLikedSongs,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbLikedSongsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DbQueueEntriesTable, List<DbQueueEntry>>
  _dbQueueEntriesRefsTable(_$CaviaDatabase db) => MultiTypedResultKey.fromTable(
    db.dbQueueEntries,
    aliasName: 'db_tracks__id__db_queue_entries__track_id',
  );

  $$DbQueueEntriesTableProcessedTableManager get dbQueueEntriesRefs {
    final manager = $$DbQueueEntriesTableTableManager(
      $_db,
      $_db.dbQueueEntries,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbQueueEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DbCacheEntriesTable, List<DbCacheEntry>>
  _dbCacheEntriesRefsTable(_$CaviaDatabase db) => MultiTypedResultKey.fromTable(
    db.dbCacheEntries,
    aliasName: 'db_tracks__id__db_cache_entries__track_id',
  );

  $$DbCacheEntriesTableProcessedTableManager get dbCacheEntriesRefs {
    final manager = $$DbCacheEntriesTableTableManager(
      $_db,
      $_db.dbCacheEntries,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbCacheEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbTracksTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbTracksTable> {
  $$DbTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerTrackId => $composableBuilder(
    column: $table.providerTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistsJson => $composableBuilder(
    column: $table.artistsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isrc => $composableBuilder(
    column: $table.isrc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get availabilityState => $composableBuilder(
    column: $table.availabilityState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCached => $composableBuilder(
    column: $table.isCached,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localCachePath => $composableBuilder(
    column: $table.localCachePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lyricsJson => $composableBuilder(
    column: $table.lyricsJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dbPlaylistEntriesRefs(
    Expression<bool> Function($$DbPlaylistEntriesTableFilterComposer f) f,
  ) {
    final $$DbPlaylistEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbPlaylistEntries,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbPlaylistEntriesTableFilterComposer(
            $db: $db,
            $table: $db.dbPlaylistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dbLikedSongsRefs(
    Expression<bool> Function($$DbLikedSongsTableFilterComposer f) f,
  ) {
    final $$DbLikedSongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbLikedSongs,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbLikedSongsTableFilterComposer(
            $db: $db,
            $table: $db.dbLikedSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dbQueueEntriesRefs(
    Expression<bool> Function($$DbQueueEntriesTableFilterComposer f) f,
  ) {
    final $$DbQueueEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbQueueEntries,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQueueEntriesTableFilterComposer(
            $db: $db,
            $table: $db.dbQueueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dbCacheEntriesRefs(
    Expression<bool> Function($$DbCacheEntriesTableFilterComposer f) f,
  ) {
    final $$DbCacheEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbCacheEntries,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbCacheEntriesTableFilterComposer(
            $db: $db,
            $table: $db.dbCacheEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbTracksTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbTracksTable> {
  $$DbTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerTrackId => $composableBuilder(
    column: $table.providerTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistsJson => $composableBuilder(
    column: $table.artistsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isrc => $composableBuilder(
    column: $table.isrc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get availabilityState => $composableBuilder(
    column: $table.availabilityState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCached => $composableBuilder(
    column: $table.isCached,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localCachePath => $composableBuilder(
    column: $table.localCachePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lyricsJson => $composableBuilder(
    column: $table.lyricsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbTracksTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbTracksTable> {
  $$DbTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerTrackId => $composableBuilder(
    column: $table.providerTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get artistsJson => $composableBuilder(
    column: $table.artistsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get isrc =>
      $composableBuilder(column: $table.isrc, builder: (column) => column);

  GeneratedColumn<bool> get explicit =>
      $composableBuilder(column: $table.explicit, builder: (column) => column);

  GeneratedColumn<String> get availabilityState => $composableBuilder(
    column: $table.availabilityState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<bool> get isCached =>
      $composableBuilder(column: $table.isCached, builder: (column) => column);

  GeneratedColumn<String> get localCachePath => $composableBuilder(
    column: $table.localCachePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lyricsJson => $composableBuilder(
    column: $table.lyricsJson,
    builder: (column) => column,
  );

  Expression<T> dbPlaylistEntriesRefs<T extends Object>(
    Expression<T> Function($$DbPlaylistEntriesTableAnnotationComposer a) f,
  ) {
    final $$DbPlaylistEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dbPlaylistEntries,
          getReferencedColumn: (t) => t.trackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DbPlaylistEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.dbPlaylistEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> dbLikedSongsRefs<T extends Object>(
    Expression<T> Function($$DbLikedSongsTableAnnotationComposer a) f,
  ) {
    final $$DbLikedSongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbLikedSongs,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbLikedSongsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbLikedSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dbQueueEntriesRefs<T extends Object>(
    Expression<T> Function($$DbQueueEntriesTableAnnotationComposer a) f,
  ) {
    final $$DbQueueEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbQueueEntries,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQueueEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.dbQueueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dbCacheEntriesRefs<T extends Object>(
    Expression<T> Function($$DbCacheEntriesTableAnnotationComposer a) f,
  ) {
    final $$DbCacheEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbCacheEntries,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbCacheEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.dbCacheEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbTracksTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbTracksTable,
          DbTrack,
          $$DbTracksTableFilterComposer,
          $$DbTracksTableOrderingComposer,
          $$DbTracksTableAnnotationComposer,
          $$DbTracksTableCreateCompanionBuilder,
          $$DbTracksTableUpdateCompanionBuilder,
          (DbTrack, $$DbTracksTableReferences),
          DbTrack,
          PrefetchHooks Function({
            bool dbPlaylistEntriesRefs,
            bool dbLikedSongsRefs,
            bool dbQueueEntriesRefs,
            bool dbCacheEntriesRefs,
          })
        > {
  $$DbTracksTableTableManager(_$CaviaDatabase db, $DbTracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> providerTrackId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> artistsJson = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<String?> isrc = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<String> availabilityState = const Value.absent(),
                Value<String?> sourceAttribution = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<bool> isCached = const Value.absent(),
                Value<String?> localCachePath = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<String> lyricsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbTracksCompanion(
                id: id,
                providerId: providerId,
                providerTrackId: providerTrackId,
                title: title,
                artist: artist,
                artistsJson: artistsJson,
                album: album,
                durationMs: durationMs,
                artworkUri: artworkUri,
                isrc: isrc,
                explicit: explicit,
                availabilityState: availabilityState,
                sourceAttribution: sourceAttribution,
                dateAdded: dateAdded,
                isCached: isCached,
                localCachePath: localCachePath,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
                lyricsJson: lyricsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> providerId = const Value.absent(),
                Value<String> providerTrackId = const Value.absent(),
                required String title,
                required String artist,
                Value<String> artistsJson = const Value.absent(),
                required String album,
                required int durationMs,
                required String artworkUri,
                Value<String?> isrc = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<String> availabilityState = const Value.absent(),
                Value<String?> sourceAttribution = const Value.absent(),
                required DateTime dateAdded,
                Value<bool> isCached = const Value.absent(),
                Value<String?> localCachePath = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<String> lyricsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbTracksCompanion.insert(
                id: id,
                providerId: providerId,
                providerTrackId: providerTrackId,
                title: title,
                artist: artist,
                artistsJson: artistsJson,
                album: album,
                durationMs: durationMs,
                artworkUri: artworkUri,
                isrc: isrc,
                explicit: explicit,
                availabilityState: availabilityState,
                sourceAttribution: sourceAttribution,
                dateAdded: dateAdded,
                isCached: isCached,
                localCachePath: localCachePath,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
                lyricsJson: lyricsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbTracksTable, DbTrack>(table),
                  $$DbTracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                dbPlaylistEntriesRefs = false,
                dbLikedSongsRefs = false,
                dbQueueEntriesRefs = false,
                dbCacheEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dbPlaylistEntriesRefs) db.dbPlaylistEntries,
                    if (dbLikedSongsRefs) db.dbLikedSongs,
                    if (dbQueueEntriesRefs) db.dbQueueEntries,
                    if (dbCacheEntriesRefs) db.dbCacheEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dbPlaylistEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          DbTrack,
                          $DbTracksTable,
                          DbPlaylistEntry,
                          $DbPlaylistEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbTracksTableReferences
                              ._dbPlaylistEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbTracksTableReferences(
                                db,
                                table,
                                p0,
                              ).dbPlaylistEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'track_id',
                          typedResults: items,
                        ),
                      if (dbLikedSongsRefs)
                        await $_getPrefetchedDataByColumns<
                          DbTrack,
                          $DbTracksTable,
                          DbLikedSong,
                          $DbLikedSongsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbTracksTableReferences
                              ._dbLikedSongsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbTracksTableReferences(
                                db,
                                table,
                                p0,
                              ).dbLikedSongsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'track_id',
                          typedResults: items,
                        ),
                      if (dbQueueEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          DbTrack,
                          $DbTracksTable,
                          DbQueueEntry,
                          $DbQueueEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbTracksTableReferences
                              ._dbQueueEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbTracksTableReferences(
                                db,
                                table,
                                p0,
                              ).dbQueueEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'track_id',
                          typedResults: items,
                        ),
                      if (dbCacheEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          DbTrack,
                          $DbTracksTable,
                          DbCacheEntry,
                          $DbCacheEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbTracksTableReferences
                              ._dbCacheEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbTracksTableReferences(
                                db,
                                table,
                                p0,
                              ).dbCacheEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'track_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DbTracksTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbTracksTable,
      DbTrack,
      $$DbTracksTableFilterComposer,
      $$DbTracksTableOrderingComposer,
      $$DbTracksTableAnnotationComposer,
      $$DbTracksTableCreateCompanionBuilder,
      $$DbTracksTableUpdateCompanionBuilder,
      (DbTrack, $$DbTracksTableReferences),
      DbTrack,
      PrefetchHooks Function({
        bool dbPlaylistEntriesRefs,
        bool dbLikedSongsRefs,
        bool dbQueueEntriesRefs,
        bool dbCacheEntriesRefs,
      })
    >;
typedef $$DbPlaylistsTableCreateCompanionBuilder =
    DbPlaylistsCompanion Function({
      required String id,
      Value<String> profileId,
      required String name,
      Value<String> description,
      required String artworkUri,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isSystem,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$DbPlaylistsTableUpdateCompanionBuilder =
    DbPlaylistsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> name,
      Value<String> description,
      Value<String> artworkUri,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSystem,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$DbPlaylistsTableReferences
    extends BaseReferences<_$CaviaDatabase, $DbPlaylistsTable, DbPlaylist> {
  $$DbPlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DbPlaylistEntriesTable, List<DbPlaylistEntry>>
  _dbPlaylistEntriesRefsTable(_$CaviaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dbPlaylistEntries,
        aliasName: 'db_playlists__id__db_playlist_entries__playlist_id',
      );

  $$DbPlaylistEntriesTableProcessedTableManager get dbPlaylistEntriesRefs {
    final manager = $$DbPlaylistEntriesTableTableManager(
      $_db,
      $_db.dbPlaylistEntries,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dbPlaylistEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbPlaylistsTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbPlaylistsTable> {
  $$DbPlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dbPlaylistEntriesRefs(
    Expression<bool> Function($$DbPlaylistEntriesTableFilterComposer f) f,
  ) {
    final $$DbPlaylistEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbPlaylistEntries,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbPlaylistEntriesTableFilterComposer(
            $db: $db,
            $table: $db.dbPlaylistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbPlaylistsTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbPlaylistsTable> {
  $$DbPlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbPlaylistsTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbPlaylistsTable> {
  $$DbPlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> dbPlaylistEntriesRefs<T extends Object>(
    Expression<T> Function($$DbPlaylistEntriesTableAnnotationComposer a) f,
  ) {
    final $$DbPlaylistEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dbPlaylistEntries,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DbPlaylistEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.dbPlaylistEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DbPlaylistsTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbPlaylistsTable,
          DbPlaylist,
          $$DbPlaylistsTableFilterComposer,
          $$DbPlaylistsTableOrderingComposer,
          $$DbPlaylistsTableAnnotationComposer,
          $$DbPlaylistsTableCreateCompanionBuilder,
          $$DbPlaylistsTableUpdateCompanionBuilder,
          (DbPlaylist, $$DbPlaylistsTableReferences),
          DbPlaylist,
          PrefetchHooks Function({bool dbPlaylistEntriesRefs})
        > {
  $$DbPlaylistsTableTableManager(_$CaviaDatabase db, $DbPlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbPlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbPlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbPlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbPlaylistsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                description: description,
                artworkUri: artworkUri,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSystem: isSystem,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> profileId = const Value.absent(),
                required String name,
                Value<String> description = const Value.absent(),
                required String artworkUri,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbPlaylistsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                description: description,
                artworkUri: artworkUri,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSystem: isSystem,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbPlaylistsTable, DbPlaylist>(table),
                  $$DbPlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dbPlaylistEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dbPlaylistEntriesRefs) db.dbPlaylistEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dbPlaylistEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                      DbPlaylist,
                      $DbPlaylistsTable,
                      DbPlaylistEntry,
                      $DbPlaylistEntriesTable
                    >(
                      currentTable: table,
                      referencedTable: $$DbPlaylistsTableReferences
                          ._dbPlaylistEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DbPlaylistsTableReferences(
                            db,
                            table,
                            p0,
                          ).dbPlaylistEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'playlist_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DbPlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbPlaylistsTable,
      DbPlaylist,
      $$DbPlaylistsTableFilterComposer,
      $$DbPlaylistsTableOrderingComposer,
      $$DbPlaylistsTableAnnotationComposer,
      $$DbPlaylistsTableCreateCompanionBuilder,
      $$DbPlaylistsTableUpdateCompanionBuilder,
      (DbPlaylist, $$DbPlaylistsTableReferences),
      DbPlaylist,
      PrefetchHooks Function({bool dbPlaylistEntriesRefs})
    >;
typedef $$DbPlaylistEntriesTableCreateCompanionBuilder =
    DbPlaylistEntriesCompanion Function({
      required String id,
      required String playlistId,
      required String trackId,
      required int position,
      required DateTime dateAdded,
      Value<int> rowid,
    });
typedef $$DbPlaylistEntriesTableUpdateCompanionBuilder =
    DbPlaylistEntriesCompanion Function({
      Value<String> id,
      Value<String> playlistId,
      Value<String> trackId,
      Value<int> position,
      Value<DateTime> dateAdded,
      Value<int> rowid,
    });

final class $$DbPlaylistEntriesTableReferences
    extends
        BaseReferences<
          _$CaviaDatabase,
          $DbPlaylistEntriesTable,
          DbPlaylistEntry
        > {
  $$DbPlaylistEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DbPlaylistsTable _playlistIdTable(_$CaviaDatabase db) => db
      .dbPlaylists
      .createAlias('db_playlist_entries__playlist_id__db_playlists__id');

  $$DbPlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$DbPlaylistsTableTableManager(
      $_db,
      $_db.dbPlaylists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DbTracksTable _trackIdTable(_$CaviaDatabase db) =>
      db.dbTracks.createAlias('db_playlist_entries__track_id__db_tracks__id');

  $$DbTracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$DbTracksTableTableManager(
      $_db,
      $_db.dbTracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbPlaylistEntriesTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbPlaylistEntriesTable> {
  $$DbPlaylistEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  $$DbPlaylistsTableFilterComposer get playlistId {
    final $$DbPlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.dbPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbPlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.dbPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DbTracksTableFilterComposer get trackId {
    final $$DbTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableFilterComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbPlaylistEntriesTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbPlaylistEntriesTable> {
  $$DbPlaylistEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbPlaylistsTableOrderingComposer get playlistId {
    final $$DbPlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.dbPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbPlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.dbPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DbTracksTableOrderingComposer get trackId {
    final $$DbTracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableOrderingComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbPlaylistEntriesTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbPlaylistEntriesTable> {
  $$DbPlaylistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  $$DbPlaylistsTableAnnotationComposer get playlistId {
    final $$DbPlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.dbPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbPlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DbTracksTableAnnotationComposer get trackId {
    final $$DbTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbPlaylistEntriesTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbPlaylistEntriesTable,
          DbPlaylistEntry,
          $$DbPlaylistEntriesTableFilterComposer,
          $$DbPlaylistEntriesTableOrderingComposer,
          $$DbPlaylistEntriesTableAnnotationComposer,
          $$DbPlaylistEntriesTableCreateCompanionBuilder,
          $$DbPlaylistEntriesTableUpdateCompanionBuilder,
          (DbPlaylistEntry, $$DbPlaylistEntriesTableReferences),
          DbPlaylistEntry,
          PrefetchHooks Function({bool playlistId, bool trackId})
        > {
  $$DbPlaylistEntriesTableTableManager(
    _$CaviaDatabase db,
    $DbPlaylistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbPlaylistEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbPlaylistEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbPlaylistEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> playlistId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbPlaylistEntriesCompanion(
                id: id,
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                dateAdded: dateAdded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String playlistId,
                required String trackId,
                required int position,
                required DateTime dateAdded,
                Value<int> rowid = const Value.absent(),
              }) => DbPlaylistEntriesCompanion.insert(
                id: id,
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                dateAdded: dateAdded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbPlaylistEntriesTable, DbPlaylistEntry>(table),
                  $$DbPlaylistEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable:
                                    $$DbPlaylistEntriesTableReferences
                                        ._playlistIdTable(db),
                                referencedColumn:
                                    $$DbPlaylistEntriesTableReferences
                                        ._playlistIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable:
                                    $$DbPlaylistEntriesTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$DbPlaylistEntriesTableReferences
                                        ._trackIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DbPlaylistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbPlaylistEntriesTable,
      DbPlaylistEntry,
      $$DbPlaylistEntriesTableFilterComposer,
      $$DbPlaylistEntriesTableOrderingComposer,
      $$DbPlaylistEntriesTableAnnotationComposer,
      $$DbPlaylistEntriesTableCreateCompanionBuilder,
      $$DbPlaylistEntriesTableUpdateCompanionBuilder,
      (DbPlaylistEntry, $$DbPlaylistEntriesTableReferences),
      DbPlaylistEntry,
      PrefetchHooks Function({bool playlistId, bool trackId})
    >;
typedef $$DbLikedSongsTableCreateCompanionBuilder =
    DbLikedSongsCompanion Function({
      Value<String> profileId,
      required String trackId,
      required DateTime dateLiked,
      Value<int> rowid,
    });
typedef $$DbLikedSongsTableUpdateCompanionBuilder =
    DbLikedSongsCompanion Function({
      Value<String> profileId,
      Value<String> trackId,
      Value<DateTime> dateLiked,
      Value<int> rowid,
    });

final class $$DbLikedSongsTableReferences
    extends BaseReferences<_$CaviaDatabase, $DbLikedSongsTable, DbLikedSong> {
  $$DbLikedSongsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbTracksTable _trackIdTable(_$CaviaDatabase db) =>
      db.dbTracks.createAlias('db_liked_songs__track_id__db_tracks__id');

  $$DbTracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$DbTracksTableTableManager(
      $_db,
      $_db.dbTracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbLikedSongsTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbLikedSongsTable> {
  $$DbLikedSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateLiked => $composableBuilder(
    column: $table.dateLiked,
    builder: (column) => ColumnFilters(column),
  );

  $$DbTracksTableFilterComposer get trackId {
    final $$DbTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableFilterComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbLikedSongsTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbLikedSongsTable> {
  $$DbLikedSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateLiked => $composableBuilder(
    column: $table.dateLiked,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbTracksTableOrderingComposer get trackId {
    final $$DbTracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableOrderingComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbLikedSongsTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbLikedSongsTable> {
  $$DbLikedSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<DateTime> get dateLiked =>
      $composableBuilder(column: $table.dateLiked, builder: (column) => column);

  $$DbTracksTableAnnotationComposer get trackId {
    final $$DbTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbLikedSongsTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbLikedSongsTable,
          DbLikedSong,
          $$DbLikedSongsTableFilterComposer,
          $$DbLikedSongsTableOrderingComposer,
          $$DbLikedSongsTableAnnotationComposer,
          $$DbLikedSongsTableCreateCompanionBuilder,
          $$DbLikedSongsTableUpdateCompanionBuilder,
          (DbLikedSong, $$DbLikedSongsTableReferences),
          DbLikedSong,
          PrefetchHooks Function({bool trackId})
        > {
  $$DbLikedSongsTableTableManager(_$CaviaDatabase db, $DbLikedSongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbLikedSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbLikedSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbLikedSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<DateTime> dateLiked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbLikedSongsCompanion(
                profileId: profileId,
                trackId: trackId,
                dateLiked: dateLiked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                required String trackId,
                required DateTime dateLiked,
                Value<int> rowid = const Value.absent(),
              }) => DbLikedSongsCompanion.insert(
                profileId: profileId,
                trackId: trackId,
                dateLiked: dateLiked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbLikedSongsTable, DbLikedSong>(table),
                  $$DbLikedSongsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable: $$DbLikedSongsTableReferences
                                    ._trackIdTable(db),
                                referencedColumn: $$DbLikedSongsTableReferences
                                    ._trackIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DbLikedSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbLikedSongsTable,
      DbLikedSong,
      $$DbLikedSongsTableFilterComposer,
      $$DbLikedSongsTableOrderingComposer,
      $$DbLikedSongsTableAnnotationComposer,
      $$DbLikedSongsTableCreateCompanionBuilder,
      $$DbLikedSongsTableUpdateCompanionBuilder,
      (DbLikedSong, $$DbLikedSongsTableReferences),
      DbLikedSong,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$DbAlbumsTableCreateCompanionBuilder =
    DbAlbumsCompanion Function({
      required String id,
      required String title,
      required String artist,
      required int year,
      required String artworkUri,
      Value<String?> sourceAttribution,
      Value<bool> isSaved,
      Value<int> rowid,
    });
typedef $$DbAlbumsTableUpdateCompanionBuilder =
    DbAlbumsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> artist,
      Value<int> year,
      Value<String> artworkUri,
      Value<String?> sourceAttribution,
      Value<bool> isSaved,
      Value<int> rowid,
    });

class $$DbAlbumsTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbAlbumsTable> {
  $$DbAlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSaved => $composableBuilder(
    column: $table.isSaved,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbAlbumsTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbAlbumsTable> {
  $$DbAlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSaved => $composableBuilder(
    column: $table.isSaved,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbAlbumsTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbAlbumsTable> {
  $$DbAlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get artworkUri => $composableBuilder(
    column: $table.artworkUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSaved =>
      $composableBuilder(column: $table.isSaved, builder: (column) => column);
}

class $$DbAlbumsTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbAlbumsTable,
          DbAlbum,
          $$DbAlbumsTableFilterComposer,
          $$DbAlbumsTableOrderingComposer,
          $$DbAlbumsTableAnnotationComposer,
          $$DbAlbumsTableCreateCompanionBuilder,
          $$DbAlbumsTableUpdateCompanionBuilder,
          (DbAlbum, BaseReferences<_$CaviaDatabase, $DbAlbumsTable, DbAlbum>),
          DbAlbum,
          PrefetchHooks Function()
        > {
  $$DbAlbumsTableTableManager(_$CaviaDatabase db, $DbAlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbAlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbAlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbAlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> artworkUri = const Value.absent(),
                Value<String?> sourceAttribution = const Value.absent(),
                Value<bool> isSaved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbAlbumsCompanion(
                id: id,
                title: title,
                artist: artist,
                year: year,
                artworkUri: artworkUri,
                sourceAttribution: sourceAttribution,
                isSaved: isSaved,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String artist,
                required int year,
                required String artworkUri,
                Value<String?> sourceAttribution = const Value.absent(),
                Value<bool> isSaved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbAlbumsCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                year: year,
                artworkUri: artworkUri,
                sourceAttribution: sourceAttribution,
                isSaved: isSaved,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbAlbumsTable, DbAlbum>(table),
                  BaseReferences<_$CaviaDatabase, $DbAlbumsTable, DbAlbum>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbAlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbAlbumsTable,
      DbAlbum,
      $$DbAlbumsTableFilterComposer,
      $$DbAlbumsTableOrderingComposer,
      $$DbAlbumsTableAnnotationComposer,
      $$DbAlbumsTableCreateCompanionBuilder,
      $$DbAlbumsTableUpdateCompanionBuilder,
      (DbAlbum, BaseReferences<_$CaviaDatabase, $DbAlbumsTable, DbAlbum>),
      DbAlbum,
      PrefetchHooks Function()
    >;
typedef $$DbArtistsTableCreateCompanionBuilder =
    DbArtistsCompanion Function({
      required String id,
      required String name,
      required String portraitUri,
      Value<String?> sourceAttribution,
      Value<bool> isFollowed,
      Value<int> rowid,
    });
typedef $$DbArtistsTableUpdateCompanionBuilder =
    DbArtistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> portraitUri,
      Value<String?> sourceAttribution,
      Value<bool> isFollowed,
      Value<int> rowid,
    });

class $$DbArtistsTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbArtistsTable> {
  $$DbArtistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get portraitUri => $composableBuilder(
    column: $table.portraitUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFollowed => $composableBuilder(
    column: $table.isFollowed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbArtistsTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbArtistsTable> {
  $$DbArtistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get portraitUri => $composableBuilder(
    column: $table.portraitUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFollowed => $composableBuilder(
    column: $table.isFollowed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbArtistsTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbArtistsTable> {
  $$DbArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get portraitUri => $composableBuilder(
    column: $table.portraitUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFollowed => $composableBuilder(
    column: $table.isFollowed,
    builder: (column) => column,
  );
}

class $$DbArtistsTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbArtistsTable,
          DbArtist,
          $$DbArtistsTableFilterComposer,
          $$DbArtistsTableOrderingComposer,
          $$DbArtistsTableAnnotationComposer,
          $$DbArtistsTableCreateCompanionBuilder,
          $$DbArtistsTableUpdateCompanionBuilder,
          (
            DbArtist,
            BaseReferences<_$CaviaDatabase, $DbArtistsTable, DbArtist>,
          ),
          DbArtist,
          PrefetchHooks Function()
        > {
  $$DbArtistsTableTableManager(_$CaviaDatabase db, $DbArtistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbArtistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> portraitUri = const Value.absent(),
                Value<String?> sourceAttribution = const Value.absent(),
                Value<bool> isFollowed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbArtistsCompanion(
                id: id,
                name: name,
                portraitUri: portraitUri,
                sourceAttribution: sourceAttribution,
                isFollowed: isFollowed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String portraitUri,
                Value<String?> sourceAttribution = const Value.absent(),
                Value<bool> isFollowed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbArtistsCompanion.insert(
                id: id,
                name: name,
                portraitUri: portraitUri,
                sourceAttribution: sourceAttribution,
                isFollowed: isFollowed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbArtistsTable, DbArtist>(table),
                  BaseReferences<_$CaviaDatabase, $DbArtistsTable, DbArtist>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbArtistsTable,
      DbArtist,
      $$DbArtistsTableFilterComposer,
      $$DbArtistsTableOrderingComposer,
      $$DbArtistsTableAnnotationComposer,
      $$DbArtistsTableCreateCompanionBuilder,
      $$DbArtistsTableUpdateCompanionBuilder,
      (DbArtist, BaseReferences<_$CaviaDatabase, $DbArtistsTable, DbArtist>),
      DbArtist,
      PrefetchHooks Function()
    >;
typedef $$DbQueueEntriesTableCreateCompanionBuilder =
    DbQueueEntriesCompanion Function({
      required String id,
      Value<String> profileId,
      required String trackId,
      required int position,
      Value<int> rowid,
    });
typedef $$DbQueueEntriesTableUpdateCompanionBuilder =
    DbQueueEntriesCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> trackId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$DbQueueEntriesTableReferences
    extends
        BaseReferences<_$CaviaDatabase, $DbQueueEntriesTable, DbQueueEntry> {
  $$DbQueueEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DbTracksTable _trackIdTable(_$CaviaDatabase db) =>
      db.dbTracks.createAlias('db_queue_entries__track_id__db_tracks__id');

  $$DbTracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$DbTracksTableTableManager(
      $_db,
      $_db.dbTracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbQueueEntriesTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbQueueEntriesTable> {
  $$DbQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$DbTracksTableFilterComposer get trackId {
    final $$DbTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableFilterComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbQueueEntriesTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbQueueEntriesTable> {
  $$DbQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbTracksTableOrderingComposer get trackId {
    final $$DbTracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableOrderingComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbQueueEntriesTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbQueueEntriesTable> {
  $$DbQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$DbTracksTableAnnotationComposer get trackId {
    final $$DbTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbQueueEntriesTable,
          DbQueueEntry,
          $$DbQueueEntriesTableFilterComposer,
          $$DbQueueEntriesTableOrderingComposer,
          $$DbQueueEntriesTableAnnotationComposer,
          $$DbQueueEntriesTableCreateCompanionBuilder,
          $$DbQueueEntriesTableUpdateCompanionBuilder,
          (DbQueueEntry, $$DbQueueEntriesTableReferences),
          DbQueueEntry,
          PrefetchHooks Function({bool trackId})
        > {
  $$DbQueueEntriesTableTableManager(
    _$CaviaDatabase db,
    $DbQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbQueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbQueueEntriesCompanion(
                id: id,
                profileId: profileId,
                trackId: trackId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> profileId = const Value.absent(),
                required String trackId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => DbQueueEntriesCompanion.insert(
                id: id,
                profileId: profileId,
                trackId: trackId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbQueueEntriesTable, DbQueueEntry>(table),
                  $$DbQueueEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable: $$DbQueueEntriesTableReferences
                                    ._trackIdTable(db),
                                referencedColumn:
                                    $$DbQueueEntriesTableReferences
                                        ._trackIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DbQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbQueueEntriesTable,
      DbQueueEntry,
      $$DbQueueEntriesTableFilterComposer,
      $$DbQueueEntriesTableOrderingComposer,
      $$DbQueueEntriesTableAnnotationComposer,
      $$DbQueueEntriesTableCreateCompanionBuilder,
      $$DbQueueEntriesTableUpdateCompanionBuilder,
      (DbQueueEntry, $$DbQueueEntriesTableReferences),
      DbQueueEntry,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$DbQueueStateTableCreateCompanionBuilder =
    DbQueueStateCompanion Function({
      Value<String> profileId,
      Value<int> currentIndex,
      Value<String> repeatMode,
      Value<bool> isShuffle,
      Value<int> positionMs,
      Value<bool> isPlaying,
      Value<int> rowid,
    });
typedef $$DbQueueStateTableUpdateCompanionBuilder =
    DbQueueStateCompanion Function({
      Value<String> profileId,
      Value<int> currentIndex,
      Value<String> repeatMode,
      Value<bool> isShuffle,
      Value<int> positionMs,
      Value<bool> isPlaying,
      Value<int> rowid,
    });

class $$DbQueueStateTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbQueueStateTable> {
  $$DbQueueStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShuffle => $composableBuilder(
    column: $table.isShuffle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlaying => $composableBuilder(
    column: $table.isPlaying,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbQueueStateTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbQueueStateTable> {
  $$DbQueueStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShuffle => $composableBuilder(
    column: $table.isShuffle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlaying => $composableBuilder(
    column: $table.isPlaying,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbQueueStateTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbQueueStateTable> {
  $$DbQueueStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isShuffle =>
      $composableBuilder(column: $table.isShuffle, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPlaying =>
      $composableBuilder(column: $table.isPlaying, builder: (column) => column);
}

class $$DbQueueStateTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbQueueStateTable,
          DbQueueStateData,
          $$DbQueueStateTableFilterComposer,
          $$DbQueueStateTableOrderingComposer,
          $$DbQueueStateTableAnnotationComposer,
          $$DbQueueStateTableCreateCompanionBuilder,
          $$DbQueueStateTableUpdateCompanionBuilder,
          (
            DbQueueStateData,
            BaseReferences<
              _$CaviaDatabase,
              $DbQueueStateTable,
              DbQueueStateData
            >,
          ),
          DbQueueStateData,
          PrefetchHooks Function()
        > {
  $$DbQueueStateTableTableManager(_$CaviaDatabase db, $DbQueueStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbQueueStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbQueueStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbQueueStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<bool> isShuffle = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> isPlaying = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbQueueStateCompanion(
                profileId: profileId,
                currentIndex: currentIndex,
                repeatMode: repeatMode,
                isShuffle: isShuffle,
                positionMs: positionMs,
                isPlaying: isPlaying,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<bool> isShuffle = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> isPlaying = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbQueueStateCompanion.insert(
                profileId: profileId,
                currentIndex: currentIndex,
                repeatMode: repeatMode,
                isShuffle: isShuffle,
                positionMs: positionMs,
                isPlaying: isPlaying,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbQueueStateTable, DbQueueStateData>(table),
                  BaseReferences<
                    _$CaviaDatabase,
                    $DbQueueStateTable,
                    DbQueueStateData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbQueueStateTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbQueueStateTable,
      DbQueueStateData,
      $$DbQueueStateTableFilterComposer,
      $$DbQueueStateTableOrderingComposer,
      $$DbQueueStateTableAnnotationComposer,
      $$DbQueueStateTableCreateCompanionBuilder,
      $$DbQueueStateTableUpdateCompanionBuilder,
      (
        DbQueueStateData,
        BaseReferences<_$CaviaDatabase, $DbQueueStateTable, DbQueueStateData>,
      ),
      DbQueueStateData,
      PrefetchHooks Function()
    >;
typedef $$DbPreferencesTableCreateCompanionBuilder =
    DbPreferencesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DbPreferencesTableUpdateCompanionBuilder =
    DbPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DbPreferencesTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbPreferencesTable> {
  $$DbPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbPreferencesTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbPreferencesTable> {
  $$DbPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbPreferencesTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbPreferencesTable> {
  $$DbPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DbPreferencesTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbPreferencesTable,
          DbPreference,
          $$DbPreferencesTableFilterComposer,
          $$DbPreferencesTableOrderingComposer,
          $$DbPreferencesTableAnnotationComposer,
          $$DbPreferencesTableCreateCompanionBuilder,
          $$DbPreferencesTableUpdateCompanionBuilder,
          (
            DbPreference,
            BaseReferences<_$CaviaDatabase, $DbPreferencesTable, DbPreference>,
          ),
          DbPreference,
          PrefetchHooks Function()
        > {
  $$DbPreferencesTableTableManager(
    _$CaviaDatabase db,
    $DbPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbPreferencesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DbPreferencesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbPreferencesTable, DbPreference>(table),
                  BaseReferences<
                    _$CaviaDatabase,
                    $DbPreferencesTable,
                    DbPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbPreferencesTable,
      DbPreference,
      $$DbPreferencesTableFilterComposer,
      $$DbPreferencesTableOrderingComposer,
      $$DbPreferencesTableAnnotationComposer,
      $$DbPreferencesTableCreateCompanionBuilder,
      $$DbPreferencesTableUpdateCompanionBuilder,
      (
        DbPreference,
        BaseReferences<_$CaviaDatabase, $DbPreferencesTable, DbPreference>,
      ),
      DbPreference,
      PrefetchHooks Function()
    >;
typedef $$DbSearchHistoryTableCreateCompanionBuilder =
    DbSearchHistoryCompanion Function({
      required String id,
      Value<String> profileId,
      required String query,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DbSearchHistoryTableUpdateCompanionBuilder =
    DbSearchHistoryCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> query,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DbSearchHistoryTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbSearchHistoryTable> {
  $$DbSearchHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbSearchHistoryTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbSearchHistoryTable> {
  $$DbSearchHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbSearchHistoryTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbSearchHistoryTable> {
  $$DbSearchHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DbSearchHistoryTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbSearchHistoryTable,
          DbSearchHistoryData,
          $$DbSearchHistoryTableFilterComposer,
          $$DbSearchHistoryTableOrderingComposer,
          $$DbSearchHistoryTableAnnotationComposer,
          $$DbSearchHistoryTableCreateCompanionBuilder,
          $$DbSearchHistoryTableUpdateCompanionBuilder,
          (
            DbSearchHistoryData,
            BaseReferences<
              _$CaviaDatabase,
              $DbSearchHistoryTable,
              DbSearchHistoryData
            >,
          ),
          DbSearchHistoryData,
          PrefetchHooks Function()
        > {
  $$DbSearchHistoryTableTableManager(
    _$CaviaDatabase db,
    $DbSearchHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbSearchHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbSearchHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbSearchHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbSearchHistoryCompanion(
                id: id,
                profileId: profileId,
                query: query,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> profileId = const Value.absent(),
                required String query,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DbSearchHistoryCompanion.insert(
                id: id,
                profileId: profileId,
                query: query,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbSearchHistoryTable, DbSearchHistoryData>(
                    table,
                  ),
                  BaseReferences<
                    _$CaviaDatabase,
                    $DbSearchHistoryTable,
                    DbSearchHistoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbSearchHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbSearchHistoryTable,
      DbSearchHistoryData,
      $$DbSearchHistoryTableFilterComposer,
      $$DbSearchHistoryTableOrderingComposer,
      $$DbSearchHistoryTableAnnotationComposer,
      $$DbSearchHistoryTableCreateCompanionBuilder,
      $$DbSearchHistoryTableUpdateCompanionBuilder,
      (
        DbSearchHistoryData,
        BaseReferences<
          _$CaviaDatabase,
          $DbSearchHistoryTable,
          DbSearchHistoryData
        >,
      ),
      DbSearchHistoryData,
      PrefetchHooks Function()
    >;
typedef $$DbSyncOutboxTableCreateCompanionBuilder =
    DbSyncOutboxCompanion Function({
      required String id,
      required String profileId,
      required String deviceId,
      required String entityType,
      required String entityId,
      required String operationType,
      required String payloadJson,
      required DateTime createdAt,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
      required String idempotencyKey,
      Value<int> rowid,
    });
typedef $$DbSyncOutboxTableUpdateCompanionBuilder =
    DbSyncOutboxCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> deviceId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operationType,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
      Value<String> idempotencyKey,
      Value<int> rowid,
    });

class $$DbSyncOutboxTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbSyncOutboxTable> {
  $$DbSyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbSyncOutboxTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbSyncOutboxTable> {
  $$DbSyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbSyncOutboxTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbSyncOutboxTable> {
  $$DbSyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );
}

class $$DbSyncOutboxTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbSyncOutboxTable,
          DbSyncOutboxData,
          $$DbSyncOutboxTableFilterComposer,
          $$DbSyncOutboxTableOrderingComposer,
          $$DbSyncOutboxTableAnnotationComposer,
          $$DbSyncOutboxTableCreateCompanionBuilder,
          $$DbSyncOutboxTableUpdateCompanionBuilder,
          (
            DbSyncOutboxData,
            BaseReferences<
              _$CaviaDatabase,
              $DbSyncOutboxTable,
              DbSyncOutboxData
            >,
          ),
          DbSyncOutboxData,
          PrefetchHooks Function()
        > {
  $$DbSyncOutboxTableTableManager(_$CaviaDatabase db, $DbSyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbSyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbSyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbSyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbSyncOutboxCompanion(
                id: id,
                profileId: profileId,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                idempotencyKey: idempotencyKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String deviceId,
                required String entityType,
                required String entityId,
                required String operationType,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required String idempotencyKey,
                Value<int> rowid = const Value.absent(),
              }) => DbSyncOutboxCompanion.insert(
                id: id,
                profileId: profileId,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                idempotencyKey: idempotencyKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbSyncOutboxTable, DbSyncOutboxData>(table),
                  BaseReferences<
                    _$CaviaDatabase,
                    $DbSyncOutboxTable,
                    DbSyncOutboxData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbSyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbSyncOutboxTable,
      DbSyncOutboxData,
      $$DbSyncOutboxTableFilterComposer,
      $$DbSyncOutboxTableOrderingComposer,
      $$DbSyncOutboxTableAnnotationComposer,
      $$DbSyncOutboxTableCreateCompanionBuilder,
      $$DbSyncOutboxTableUpdateCompanionBuilder,
      (
        DbSyncOutboxData,
        BaseReferences<_$CaviaDatabase, $DbSyncOutboxTable, DbSyncOutboxData>,
      ),
      DbSyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$DbSyncStateTableCreateCompanionBuilder =
    DbSyncStateCompanion Function({
      required String profileId,
      Value<DateTime?> lastSyncedAt,
      Value<int> lastServerRevision,
      Value<String> syncStatus,
      Value<String?> errorMessage,
      Value<int> rowid,
    });
typedef $$DbSyncStateTableUpdateCompanionBuilder =
    DbSyncStateCompanion Function({
      Value<String> profileId,
      Value<DateTime?> lastSyncedAt,
      Value<int> lastServerRevision,
      Value<String> syncStatus,
      Value<String?> errorMessage,
      Value<int> rowid,
    });

class $$DbSyncStateTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbSyncStateTable> {
  $$DbSyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastServerRevision => $composableBuilder(
    column: $table.lastServerRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbSyncStateTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbSyncStateTable> {
  $$DbSyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastServerRevision => $composableBuilder(
    column: $table.lastServerRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbSyncStateTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbSyncStateTable> {
  $$DbSyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastServerRevision => $composableBuilder(
    column: $table.lastServerRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$DbSyncStateTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbSyncStateTable,
          DbSyncStateData,
          $$DbSyncStateTableFilterComposer,
          $$DbSyncStateTableOrderingComposer,
          $$DbSyncStateTableAnnotationComposer,
          $$DbSyncStateTableCreateCompanionBuilder,
          $$DbSyncStateTableUpdateCompanionBuilder,
          (
            DbSyncStateData,
            BaseReferences<_$CaviaDatabase, $DbSyncStateTable, DbSyncStateData>,
          ),
          DbSyncStateData,
          PrefetchHooks Function()
        > {
  $$DbSyncStateTableTableManager(_$CaviaDatabase db, $DbSyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbSyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbSyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbSyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> lastServerRevision = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbSyncStateCompanion(
                profileId: profileId,
                lastSyncedAt: lastSyncedAt,
                lastServerRevision: lastServerRevision,
                syncStatus: syncStatus,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> lastServerRevision = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbSyncStateCompanion.insert(
                profileId: profileId,
                lastSyncedAt: lastSyncedAt,
                lastServerRevision: lastServerRevision,
                syncStatus: syncStatus,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbSyncStateTable, DbSyncStateData>(table),
                  BaseReferences<
                    _$CaviaDatabase,
                    $DbSyncStateTable,
                    DbSyncStateData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbSyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbSyncStateTable,
      DbSyncStateData,
      $$DbSyncStateTableFilterComposer,
      $$DbSyncStateTableOrderingComposer,
      $$DbSyncStateTableAnnotationComposer,
      $$DbSyncStateTableCreateCompanionBuilder,
      $$DbSyncStateTableUpdateCompanionBuilder,
      (
        DbSyncStateData,
        BaseReferences<_$CaviaDatabase, $DbSyncStateTable, DbSyncStateData>,
      ),
      DbSyncStateData,
      PrefetchHooks Function()
    >;
typedef $$DbTombstonesTableCreateCompanionBuilder =
    DbTombstonesCompanion Function({
      required String id,
      required String profileId,
      required String entityType,
      required String entityId,
      required DateTime deletedAt,
      Value<int> rowid,
    });
typedef $$DbTombstonesTableUpdateCompanionBuilder =
    DbTombstonesCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> entityType,
      Value<String> entityId,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });

class $$DbTombstonesTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbTombstonesTable> {
  $$DbTombstonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbTombstonesTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbTombstonesTable> {
  $$DbTombstonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbTombstonesTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbTombstonesTable> {
  $$DbTombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DbTombstonesTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbTombstonesTable,
          DbTombstone,
          $$DbTombstonesTableFilterComposer,
          $$DbTombstonesTableOrderingComposer,
          $$DbTombstonesTableAnnotationComposer,
          $$DbTombstonesTableCreateCompanionBuilder,
          $$DbTombstonesTableUpdateCompanionBuilder,
          (
            DbTombstone,
            BaseReferences<_$CaviaDatabase, $DbTombstonesTable, DbTombstone>,
          ),
          DbTombstone,
          PrefetchHooks Function()
        > {
  $$DbTombstonesTableTableManager(_$CaviaDatabase db, $DbTombstonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbTombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbTombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbTombstonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbTombstonesCompanion(
                id: id,
                profileId: profileId,
                entityType: entityType,
                entityId: entityId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String entityType,
                required String entityId,
                required DateTime deletedAt,
                Value<int> rowid = const Value.absent(),
              }) => DbTombstonesCompanion.insert(
                id: id,
                profileId: profileId,
                entityType: entityType,
                entityId: entityId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbTombstonesTable, DbTombstone>(table),
                  BaseReferences<
                    _$CaviaDatabase,
                    $DbTombstonesTable,
                    DbTombstone
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbTombstonesTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbTombstonesTable,
      DbTombstone,
      $$DbTombstonesTableFilterComposer,
      $$DbTombstonesTableOrderingComposer,
      $$DbTombstonesTableAnnotationComposer,
      $$DbTombstonesTableCreateCompanionBuilder,
      $$DbTombstonesTableUpdateCompanionBuilder,
      (
        DbTombstone,
        BaseReferences<_$CaviaDatabase, $DbTombstonesTable, DbTombstone>,
      ),
      DbTombstone,
      PrefetchHooks Function()
    >;
typedef $$DbCacheEntriesTableCreateCompanionBuilder =
    DbCacheEntriesCompanion Function({
      required String trackId,
      required String cacheKey,
      required String filePath,
      required int contentSizeBytes,
      Value<String> mimeType,
      Value<int?> durationMs,
      required String providerId,
      Value<String> downloadState,
      Value<String?> sha256Hash,
      required DateTime cachedAt,
      required DateTime lastAccessedAt,
      Value<int> rowid,
    });
typedef $$DbCacheEntriesTableUpdateCompanionBuilder =
    DbCacheEntriesCompanion Function({
      Value<String> trackId,
      Value<String> cacheKey,
      Value<String> filePath,
      Value<int> contentSizeBytes,
      Value<String> mimeType,
      Value<int?> durationMs,
      Value<String> providerId,
      Value<String> downloadState,
      Value<String?> sha256Hash,
      Value<DateTime> cachedAt,
      Value<DateTime> lastAccessedAt,
      Value<int> rowid,
    });

final class $$DbCacheEntriesTableReferences
    extends
        BaseReferences<_$CaviaDatabase, $DbCacheEntriesTable, DbCacheEntry> {
  $$DbCacheEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DbTracksTable _trackIdTable(_$CaviaDatabase db) =>
      db.dbTracks.createAlias('db_cache_entries__track_id__db_tracks__id');

  $$DbTracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$DbTracksTableTableManager(
      $_db,
      $_db.dbTracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbCacheEntriesTableFilterComposer
    extends Composer<_$CaviaDatabase, $DbCacheEntriesTable> {
  $$DbCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentSizeBytes => $composableBuilder(
    column: $table.contentSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadState => $composableBuilder(
    column: $table.downloadState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256Hash => $composableBuilder(
    column: $table.sha256Hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DbTracksTableFilterComposer get trackId {
    final $$DbTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableFilterComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbCacheEntriesTableOrderingComposer
    extends Composer<_$CaviaDatabase, $DbCacheEntriesTable> {
  $$DbCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentSizeBytes => $composableBuilder(
    column: $table.contentSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadState => $composableBuilder(
    column: $table.downloadState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256Hash => $composableBuilder(
    column: $table.sha256Hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbTracksTableOrderingComposer get trackId {
    final $$DbTracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableOrderingComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbCacheEntriesTableAnnotationComposer
    extends Composer<_$CaviaDatabase, $DbCacheEntriesTable> {
  $$DbCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get contentSizeBytes => $composableBuilder(
    column: $table.contentSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get downloadState => $composableBuilder(
    column: $table.downloadState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256Hash => $composableBuilder(
    column: $table.sha256Hash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  $$DbTracksTableAnnotationComposer get trackId {
    final $$DbTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.dbTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$CaviaDatabase,
          $DbCacheEntriesTable,
          DbCacheEntry,
          $$DbCacheEntriesTableFilterComposer,
          $$DbCacheEntriesTableOrderingComposer,
          $$DbCacheEntriesTableAnnotationComposer,
          $$DbCacheEntriesTableCreateCompanionBuilder,
          $$DbCacheEntriesTableUpdateCompanionBuilder,
          (DbCacheEntry, $$DbCacheEntriesTableReferences),
          DbCacheEntry,
          PrefetchHooks Function({bool trackId})
        > {
  $$DbCacheEntriesTableTableManager(
    _$CaviaDatabase db,
    $DbCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> contentSizeBytes = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> downloadState = const Value.absent(),
                Value<String?> sha256Hash = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<DateTime> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbCacheEntriesCompanion(
                trackId: trackId,
                cacheKey: cacheKey,
                filePath: filePath,
                contentSizeBytes: contentSizeBytes,
                mimeType: mimeType,
                durationMs: durationMs,
                providerId: providerId,
                downloadState: downloadState,
                sha256Hash: sha256Hash,
                cachedAt: cachedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String cacheKey,
                required String filePath,
                required int contentSizeBytes,
                Value<String> mimeType = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required String providerId,
                Value<String> downloadState = const Value.absent(),
                Value<String?> sha256Hash = const Value.absent(),
                required DateTime cachedAt,
                required DateTime lastAccessedAt,
                Value<int> rowid = const Value.absent(),
              }) => DbCacheEntriesCompanion.insert(
                trackId: trackId,
                cacheKey: cacheKey,
                filePath: filePath,
                contentSizeBytes: contentSizeBytes,
                mimeType: mimeType,
                durationMs: durationMs,
                providerId: providerId,
                downloadState: downloadState,
                sha256Hash: sha256Hash,
                cachedAt: cachedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbCacheEntriesTable, DbCacheEntry>(table),
                  $$DbCacheEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable: $$DbCacheEntriesTableReferences
                                    ._trackIdTable(db),
                                referencedColumn:
                                    $$DbCacheEntriesTableReferences
                                        ._trackIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DbCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CaviaDatabase,
      $DbCacheEntriesTable,
      DbCacheEntry,
      $$DbCacheEntriesTableFilterComposer,
      $$DbCacheEntriesTableOrderingComposer,
      $$DbCacheEntriesTableAnnotationComposer,
      $$DbCacheEntriesTableCreateCompanionBuilder,
      $$DbCacheEntriesTableUpdateCompanionBuilder,
      (DbCacheEntry, $$DbCacheEntriesTableReferences),
      DbCacheEntry,
      PrefetchHooks Function({bool trackId})
    >;

class $CaviaDatabaseManager {
  final _$CaviaDatabase _db;
  $CaviaDatabaseManager(this._db);
  $$DbTracksTableTableManager get dbTracks =>
      $$DbTracksTableTableManager(_db, _db.dbTracks);
  $$DbPlaylistsTableTableManager get dbPlaylists =>
      $$DbPlaylistsTableTableManager(_db, _db.dbPlaylists);
  $$DbPlaylistEntriesTableTableManager get dbPlaylistEntries =>
      $$DbPlaylistEntriesTableTableManager(_db, _db.dbPlaylistEntries);
  $$DbLikedSongsTableTableManager get dbLikedSongs =>
      $$DbLikedSongsTableTableManager(_db, _db.dbLikedSongs);
  $$DbAlbumsTableTableManager get dbAlbums =>
      $$DbAlbumsTableTableManager(_db, _db.dbAlbums);
  $$DbArtistsTableTableManager get dbArtists =>
      $$DbArtistsTableTableManager(_db, _db.dbArtists);
  $$DbQueueEntriesTableTableManager get dbQueueEntries =>
      $$DbQueueEntriesTableTableManager(_db, _db.dbQueueEntries);
  $$DbQueueStateTableTableManager get dbQueueState =>
      $$DbQueueStateTableTableManager(_db, _db.dbQueueState);
  $$DbPreferencesTableTableManager get dbPreferences =>
      $$DbPreferencesTableTableManager(_db, _db.dbPreferences);
  $$DbSearchHistoryTableTableManager get dbSearchHistory =>
      $$DbSearchHistoryTableTableManager(_db, _db.dbSearchHistory);
  $$DbSyncOutboxTableTableManager get dbSyncOutbox =>
      $$DbSyncOutboxTableTableManager(_db, _db.dbSyncOutbox);
  $$DbSyncStateTableTableManager get dbSyncState =>
      $$DbSyncStateTableTableManager(_db, _db.dbSyncState);
  $$DbTombstonesTableTableManager get dbTombstones =>
      $$DbTombstonesTableTableManager(_db, _db.dbTombstones);
  $$DbCacheEntriesTableTableManager get dbCacheEntries =>
      $$DbCacheEntriesTableTableManager(_db, _db.dbCacheEntries);
}
