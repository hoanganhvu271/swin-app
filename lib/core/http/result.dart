sealed class Result<T> {
  const Result();

  /// Success
  const factory Result.success({T? data}) = Success;

  /// Failure
  const factory Result.failure({
    int code,
    String message,
    Map<String, dynamic> data,
  }) = Failure;

  bool get isSuccessful => this is Success<T>;

  T? get dataOrNull => this is Success<T> ? (this as Success).data : null;

  Failure? get errorOrNull => this is Failure ? (this as Failure) : null;

  T unwrap() {
    if (this is Success<T>) {
      return (this as Success<T>).data as T;
    }
    final f = this as Failure;
    throw Exception("Error(${f.code}): ${f.message}");
  }

  /// Pattern matching có return value
  R when<R>({
    required R Function(T? data) onSuccess,
    required R Function(int code, String message, Map<String, dynamic> data)
    onFailure,
  }) {
    if (this is Success<T>) {
      final s = this as Success<T>;
      return onSuccess(s.data);
    } else {
      final f = this as Failure;
      return onFailure(f.code, f.message, f.data);
    }
  }

  /// Mapping data → kiểu mới
  Result<R> map<R>(R Function(T? data) mapper) {
    if (this is Success<T>) {
      final s = this as Success<T>;
      return Result.success(data: mapper(s.data));
    }
    final f = this as Failure;
    return Result.failure(code: f.code, message: f.message, data: f.data);
  }
}

final class Success<T> extends Result<T> {
  const Success({this.data});
  final T? data;
}

final class Failure<T> extends Result<T> {
  const Failure({
    this.code = -1,
    this.message = "",
    this.data = const {},
  });

  final int code;
  final String message;
  final Map<String, dynamic> data;
}
