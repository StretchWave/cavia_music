/// Typed Result type for domain and repository operations.
sealed class Result<S, E> {
  const Result();

  const factory Result.success(S data) = Success<S, E>;
  const factory Result.failure(E error) = Failure<S, E>;

  bool get isSuccess => this is Success<S, E>;
  bool get isFailure => this is Failure<S, E>;

  S? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Failure() => null,
  };

  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  R when<R>({
    required R Function(S data) onSuccess,
    required R Function(E error) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Failure(:final error) => onFailure(error),
    };
  }
}

final class Success<S, E> extends Result<S, E> {
  final S data;
  const Success(this.data);

  @override
  String toString() => 'Success($data)';
}

final class Failure<S, E> extends Result<S, E> {
  final E error;
  const Failure(this.error);

  @override
  String toString() => 'Failure($error)';
}
