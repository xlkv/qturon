sealed class AppException implements Exception {
  const AppException(this.code, [this.message]);

  final String code;
  final String? message;

  @override
  String toString() => 'AppException($code${message != null ? ': $message' : ''})';
}

class NetworkException extends AppException {
  const NetworkException([String? message]) : super('network', message);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([String? message]) : super('permission_denied', message);
}

class NotFoundException extends AppException {
  const NotFoundException([String? message]) : super('not_found', message);
}

class ValidationException extends AppException {
  const ValidationException(super.code, [super.message]);
}

class AuthException extends AppException {
  const AuthException(super.code, [super.message]);
}

class FunctionsException extends AppException {
  const FunctionsException(super.code, [super.message]);
}

class UnknownException extends AppException {
  const UnknownException([String? message]) : super('unknown', message);
}
