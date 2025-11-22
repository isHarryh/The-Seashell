class SyncServiceException implements Exception {
  final String message;
  final int? errorCode;

  const SyncServiceException(this.message, [this.errorCode]);

  @override
  String toString() => 'SyncServiceException: $message (code: $errorCode)';
}

class SyncServiceNetworkError extends SyncServiceException {
  final Object? cause;

  SyncServiceNetworkError(super.message, [this.cause, super.errorCode]);

  @override
  String toString() => 'SyncServiceNetworkError: $message\nCaused by: $cause';
}

class SyncServiceBadResponse extends SyncServiceException {
  final Object? cause;

  SyncServiceBadResponse(super.message, [this.cause, super.errorCode]);

  @override
  String toString() => 'SyncServiceBadResponse: $message\nCaused by: $cause';
}

class SyncServiceAuthError extends SyncServiceException {
  const SyncServiceAuthError(super.message, [super.errorCode]);
}

class SyncServiceBadRequest extends SyncServiceException {
  const SyncServiceBadRequest(super.message, [super.errorCode]);
}

/// Get human-readable error message
String getSyncErrorMessage(int? errorCode) {
  switch (errorCode) {
    case 10101:
      return '设备ID未找到';
    case 10102:
      return '设备ID已删除';
    case 10103:
      return '设备ID已封禁';
    case 10104:
      return '设备ID已归档';
    case 10111:
      return '同步组ID未找到';
    case 10112:
      return '同步组ID已删除';
    case 10113:
      return '同步组ID已封禁';
    case 10114:
      return '同步组ID已归档';
    case 10115:
      return '此设备已在同步组中';
    case 10116:
      return '同步组已满员';
    case 10117:
      return '此设备不在同步组中';
    case 10201:
      return '配对码无效或已过期';
    case 10202:
      return '无法进行身份核验';
    case 10203:
      return '配对码与同步组不匹配';
    default:
      return '未知错误（$errorCode）';
  }
}
