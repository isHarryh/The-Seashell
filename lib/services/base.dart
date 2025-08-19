enum ServiceStatus {
  online, // Logged in
  offline, // Not logged in
  pending, // Transaction in progress
  errorAuth, // Authentication error (like expired token)
  errorNetwork, // Network error
}

abstract class BaseService {
  ServiceStatus _status = ServiceStatus.offline;
  String? _errorMessage;

  ServiceStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _status == ServiceStatus.online;
  bool get isOffline => _status == ServiceStatus.offline;
  bool get isPending => _status == ServiceStatus.pending;
  bool get hasError =>
      _status == ServiceStatus.errorAuth ||
      _status == ServiceStatus.errorNetwork;

  void setStatus(ServiceStatus status, [String? errorMessage]) {
    _status = status;
    _errorMessage = errorMessage;
    onStatusChanged(status, errorMessage);
  }

  void setOnline() {
    setStatus(ServiceStatus.online);
  }

  void setOffline() {
    setStatus(ServiceStatus.offline);
  }

  void setPending() {
    setStatus(ServiceStatus.pending);
  }

  void setAuthError([String? message]) {
    setStatus(ServiceStatus.errorAuth, message);
  }

  void setNetworkError([String? message]) {
    setStatus(ServiceStatus.errorNetwork, message);
  }

  /// Override this method to handle status changes
  void onStatusChanged(ServiceStatus status, String? errorMessage) {}

  Future<void> login();
  Future<void> logout();
}
