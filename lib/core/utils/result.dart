abstract class Result<S, F> {
  const Result();

  bool get isSuccess;
  bool get isFailure;

  S get success => throw StateError('Not a success');
  F get failure => throw StateError('Not a failure');

  R fold<R>(R Function(S success) onSuccess, R Function(F failure) onFailure);
}

class Success<S, F> extends Result<S, F> {
  final S value;

  const Success(this.value);

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  S get success => value;

  @override
  R fold<R>(R Function(S success) onSuccess, R Function(F failure) onFailure) {
    return onSuccess(value);
  }
}

class FailureResult<S, F> extends Result<S, F> {
  final F value;

  const FailureResult(this.value);

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  F get failure => value;

  @override
  R fold<R>(R Function(S success) onSuccess, R Function(F failure) onFailure) {
    return onFailure(value);
  }
}
