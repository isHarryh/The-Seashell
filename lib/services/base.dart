enum ServiceStatus {
  online, // Logged in
  offline, // Not logged in
  pending, // Transaction in progress
  error, // Error occurred
}

/// A mixin that provides common service status management functionality.
mixin BaseService {
  ServiceStatus _status = ServiceStatus.offline;
  String? _errorMessage;

  ServiceStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _status == ServiceStatus.online;
  bool get isOffline => _status == ServiceStatus.offline;
  bool get isPending => _status == ServiceStatus.pending;
  bool get hasError => _status == ServiceStatus.error;

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

  void setError([String? message]) {
    setStatus(ServiceStatus.error, message);
  }

  /// Override this method to handle status changes.
  void onStatusChanged(ServiceStatus status, String? errorMessage) {}
}
