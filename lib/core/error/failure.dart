/// Domain-level failures. Data sources translate backend/storage exceptions
/// into these so the presentation layer never depends on a specific vendor's
/// error types — part of keeping the architecture portable.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
