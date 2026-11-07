import 'dart:async';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/repositories/search_repository.dart';

/// Debounced, latest-wins coordinator for the local catalog search, mirroring
/// the cancellation semantics of [SearchService] but scoped to the on-device
/// repository (no providers, no network).
class LocalSearchService {
  final SearchRepository searchRepository;

  Timer? _debounceTimer;
  int _requestEpoch = 0;

  LocalSearchService({required this.searchRepository});

  /// Debounced search against the local catalog. Only the most recent
  /// request's result is meaningful; superseded responses are detected by
  /// epoch comparison in the caller (compare the query text or track id).
  Future<Result<SearchResults, AppError>> search(
    String query, {
    Duration debounceDuration = const Duration(milliseconds: 250),
  }) {
    final completer = Completer<Result<SearchResults, AppError>>();

    _debounceTimer?.cancel();
    final currentEpoch = ++_requestEpoch;

    if (query.trim().isEmpty) {
      return Future.value(const Result.success(SearchResults()));
    }

    _debounceTimer = Timer(debounceDuration, () async {
      if (currentEpoch != _requestEpoch) {
        return; // superseded silently
      }
      final res = await searchRepository.search(query);
      if (currentEpoch == _requestEpoch && !completer.isCompleted) {
        completer.complete(res);
      }
    });

    return completer.future;
  }

  void cancel() {
    _debounceTimer?.cancel();
    _requestEpoch++;
  }
}
