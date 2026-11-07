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
  Completer<Result<SearchResults, AppError>>? _activeCompleter;
  int _requestEpoch = 0;

  LocalSearchService({required this.searchRepository});

  /// Debounced search against the local catalog. Only the most recent
  /// request's result is meaningful; superseded responses are detected by
  /// epoch comparison in the caller (compare the query text or track id).
  Future<Result<SearchResults, AppError>> search(
    String query, {
    Duration debounceDuration = const Duration(milliseconds: 250),
  }) {
    _debounceTimer?.cancel();
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(
        const Result.failure(ValidationError('Superseded by newer query')),
      );
    }

    if (query.trim().isEmpty) {
      _activeCompleter = null;
      return Future.value(const Result.success(SearchResults()));
    }

    final completer = Completer<Result<SearchResults, AppError>>();
    _activeCompleter = completer;
    final currentEpoch = ++_requestEpoch;

    _debounceTimer = Timer(debounceDuration, () async {
      if (currentEpoch != _requestEpoch) {
        if (!completer.isCompleted) {
          completer.complete(
            const Result.failure(ValidationError('Superseded by newer query')),
          );
        }
        return; // superseded silently
      }
      final res = await searchRepository.search(query);
      if (currentEpoch == _requestEpoch && !completer.isCompleted) {
        completer.complete(res);
      } else if (!completer.isCompleted) {
        completer.complete(
          const Result.failure(ValidationError('Superseded by newer query')),
        );
      }
    });

    return completer.future;
  }

  void cancel() {
    _debounceTimer?.cancel();
    _requestEpoch++;
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(
        const Result.failure(ValidationError('Search cancelled')),
      );
      _activeCompleter = null;
    }
  }
}
