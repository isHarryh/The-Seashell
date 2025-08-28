/// Base exception class for course services.
class CourseServiceException implements Exception {
  final String message;
  final dynamic originalError;

  const CourseServiceException(this.message, [this.originalError]);

  static void raiseForStatus(
    int statusCode, [
    void Function()? setOfflineCallback,
  ]) {
    if (statusCode == 401) {
      // 401 Unauthorized
      setOfflineCallback?.call();
      throw CourseServiceNetworkError('HTTP 401 - Authentication failed');
    } else if (statusCode < 200 || statusCode >= 300) {
      throw CourseServiceNetworkError('HTTP $statusCode');
    }
  }

  @override
  String toString() => 'CourseServiceException: $message';
}

/// Exception thrown when the service is offline or not logged in.
class CourseServiceOffline extends CourseServiceException {
  const CourseServiceOffline([
    super.message = 'Service is offline or not logged in',
  ]);

  @override
  String toString() => 'CourseServiceOffline: $message';
}

/// Exception thrown when a network error occurs during a network request.
class CourseServiceNetworkError extends CourseServiceException {
  const CourseServiceNetworkError(super.message, [super.originalError]);

  @override
  String toString() => 'CourseServiceNetworkError: $message';
}

/// Exception thrown when the server returns a business error code.
class CourseServiceBadRequest extends CourseServiceException {
  final int? errorCode;

  const CourseServiceBadRequest(
    super.message, [
    this.errorCode,
    super.originalError,
  ]);

  @override
  String toString() =>
      'CourseServiceBadRequest: $message${errorCode != null ? ' (code: $errorCode)' : ''}';
}

/// Exception thrown when a response cannot be parsed or is invalid.
class CourseServiceBadResponse extends CourseServiceException {
  const CourseServiceBadResponse(super.message, [super.originalError]);

  @override
  String toString() => 'CourseServiceBadResponse: $message';
}
