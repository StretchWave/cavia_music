import 'dart:async';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/repositories/search_repository.dart';
import '../providers/provider_registry.dart';
import '../providers/music_provider.dart';

/// Aggregated, normalized search response with source attribution.
class SearchResponse {
  final String query;
  final List<SearchResultItem> songs;
  final List<SearchResultItem> albums;
  final List<SearchResultItem> artists;
  final List<SearchResultItem> playlists;
  final bool hasMore;
  final List<String> operationalSources;

  const SearchResponse({
    required this.query,
    required this.songs,
    required this.albums,
    required this.artists,
    required this.playlists,
    this.hasMore = false,
    this.operationalSources = const [],
  });

  bool get isEmpty =>
      songs.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty;
  int get totalCount =>
      songs.length + albums.length + artists.length + playlists.length;
}

/// Search Coordinator that queries registered providers, manages debouncing,
/// cancels superseded requests, removes duplicates, and normalizes output.
///
/// NOTE: Home, Discovery, Recommendations, and trending feeds are strictly excluded.
class SearchService {
  final ProviderRegistry providerRegistry;
  final SearchRepository searchRepository;

  Timer? _debounceTimer;
  CancellationToken? _activeCancelToken;
  int _searchEpoch = 0;

  SearchService({
    required this.providerRegistry,
    required this.searchRepository,
  });

  /// Execute debounced search (300ms default) with cancellation of in-flight requests.
  Future<Result<SearchResponse, AppError>> debouncedSearch({
    required String query,
    Duration debounceDuration = const Duration(milliseconds: 300),
    SearchFilterCategory category = SearchFilterCategory.all,
    int page = 1,
    int pageSize = 20,
  }) {
    final completer = Completer<Result<SearchResponse, AppError>>();

    _debounceTimer?.cancel();
    _activeCancelToken?.cancel();

    if (query.trim().isEmpty) {
      return Future.value(const Result.success(SearchResponse(
        query: '',
        songs: [],
        albums: [],
        artists: [],
        playlists: [],
      )));
    }

    final token = CancellationToken();
    _activeCancelToken = token;
    final currentEpoch = ++_searchEpoch;

    _debounceTimer = Timer(debounceDuration, () async {
      if (token.isCancelled || currentEpoch != _searchEpoch) {
        completer.complete(const Result.failure(ValidationError('Superseded by newer query')));
        return;
      }

      final result = await searchImmediate(
        query: query,
        category: category,
        page: page,
        pageSize: pageSize,
        cancelToken: token,
      );

      if (!completer.isCompleted) {
        completer.complete(result);
      }
    });

    return completer.future;
  }

  /// Execute immediate non-debounced search across operational providers.
  Future<Result<SearchResponse, AppError>> searchImmediate({
    required String query,
    SearchFilterCategory category = SearchFilterCategory.all,
    int page = 1,
    int pageSize = 20,
    CancellationToken? cancelToken,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return const Result.success(SearchResponse(
        query: '',
        songs: [],
        albums: [],
        artists: [],
        playlists: [],
      ));
    }

    // Save search query into local history
    await searchRepository.addSearchQuery(cleanQuery);

    final providers = providerRegistry.searchProviders;
    final List<SearchResultItem> aggregated = [];
    final List<String> sources = [];

    // Query all operational search providers with timeout
    for (final provider in providers) {
      if (cancelToken?.isCancelled == true) {
        return const Result.failure(ValidationError('Search operation cancelled'));
      }

      try {
        final res = await provider
            .search(
              query: cleanQuery,
              category: category,
              page: page,
              pageSize: pageSize,
              cancelToken: cancelToken,
            )
            .timeout(const Duration(seconds: 8));

        if (res.isSuccess && res.dataOrNull != null) {
          aggregated.addAll(res.dataOrNull!);
          sources.add(provider.displayName);
        }
      } catch (e) {
        // Log provider failure without crashing search aggregation
      }
    }

    // Deduplicate items across providers: matching by lowercase (title + subtitle/artist)
    final seenKeys = <String>{};
    final uniqueItems = <SearchResultItem>[];

    for (final item in aggregated) {
      final key = '${item.title.toLowerCase()}_${item.subtitle.toLowerCase()}';
      if (!seenKeys.contains(key)) {
        seenKeys.add(key);
        uniqueItems.add(item);
      }
    }

    // Partition into categories
    final songs = uniqueItems.where((i) => i.category == SearchFilterCategory.songs).toList();
    final albums = uniqueItems.where((i) => i.category == SearchFilterCategory.albums).toList();
    final artists = uniqueItems.where((i) => i.category == SearchFilterCategory.artists).toList();
    final playlists = uniqueItems.where((i) => i.category == SearchFilterCategory.playlists).toList();

    return Result.success(SearchResponse(
      query: cleanQuery,
      songs: songs,
      albums: albums,
      artists: artists,
      playlists: playlists,
      hasMore: uniqueItems.length >= pageSize,
      operationalSources: sources,
    ));
  }

  void cancel() {
    _debounceTimer?.cancel();
    _activeCancelToken?.cancel();
  }
}
