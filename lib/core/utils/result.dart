/// A type-safe result wrapper for operations that can fail
///
/// This is a functional programming approach to error handling,
/// avoiding exceptions where possible and making error states explicit.
sealed class Result<T> {
  const Result();

  /// Returns true if the result is a success
  bool get isSuccess => this is Success<T>;

  /// Returns true if the result is a failure
  bool get isFailure => this is Failure<T>;

  /// Returns the value if success, null otherwise
  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  /// Returns the error if failure, null otherwise
  String? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final message) => message,
      };

  /// Maps the value if success
  Result<R> map<R>(R Function(T value) mapper) => switch (this) {
        Success<T>(:final value) => Success(mapper(value)),
        Failure<T>(:final message) => Failure(message),
      };

  /// Maps the error if failure
  Result<T> mapError(String Function(String error) mapper) => switch (this) {
        Success<T>() => this,
        Failure<T>(:final message) => Failure(mapper(message)),
      };

  /// Executes a function if success
  Result<T> onSuccess(void Function(T value) action) {
    if (this case Success<T>(:final value)) {
      action(value);
    }
    return this;
  }

  /// Executes a function if failure
  Result<T> onFailure(void Function(String error) action) {
    if (this case Failure<T>(:final message)) {
      action(message);
    }
    return this;
  }
}

/// Represents a successful operation
final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed operation
final class Failure<T> extends Result<T> {
  final String message;

  const Failure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Failure<T> && message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Failure($message)';
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Unwraps the value, throwing if failure
  T unwrap() => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>(:final message) => throw Exception(message),
      };

  /// Unwraps the value or returns a default
  T unwrapOr(T defaultValue) => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => defaultValue,
      };

  /// Unwraps the value or computes a default
  T unwrapOrElse(T Function() defaultValue) => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => defaultValue(),
      };
}
