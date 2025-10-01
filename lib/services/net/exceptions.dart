/// Base exception class for net services.
class NetServiceException implements Exception {
  final String message;
  final dynamic originalError;

  const NetServiceException(this.message, [this.originalError]);

  static void raiseForStatus(
    int statusCode, [
    void Function()? setOfflineCallback,
  ]) {
    if (statusCode < 200 || statusCode >= 300) {
      throw NetServiceNetworkError('HTTP $statusCode');
    }
  }

  @override
  String toString() => 'NetServiceException: $message';
}

class NetServiceOffline extends NetServiceException {
  const NetServiceOffline([
    super.message = 'Service is offline or not logged in',
  ]);

  @override
  String toString() => 'NetServiceOffline: $message';
}

class NetServiceNetworkError extends NetServiceException {
  const NetServiceNetworkError(super.message, [super.originalError]);

  @override
  String toString() => 'NetServiceNetworkError: $message';
}

class NetServiceBadResponse extends NetServiceException {
  const NetServiceBadResponse(super.message, [super.originalError]);

  @override
  String toString() => 'NetServiceBadResponse: $message';
}
