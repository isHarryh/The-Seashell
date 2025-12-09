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
    case 1001:
      return '无效的 Cookie';
    case 1002:
      return '无效的参数';
    case 1003:
      return '无效的 User Agent';
    case 1011:
      return '操作不允许';
    case 1012:
      return '未授权';
    case 1013:
      return '方法不允许';
    case 1014:
      return '请求过于频繁';
    case 2001:
      return '服务器内部错误';
    case 2002:
      return '数据库错误';
    case 2003:
      return '上游服务错误';
    case 2011:
      return '服务繁忙';
    case 2012:
      return '服务已关闭';
    case 10101:
      return '此设备ID未被注册';
    case 10102:
      return '此设备ID已被删除';
    case 10103:
      return '此设备ID已被禁用';
    case 10104:
      return '此设备ID已被封存';
    case 10111:
      return '此同步组ID未被注册';
    case 10112:
      return '此同步组ID已被删除';
    case 10113:
      return '此同步组ID已被禁用';
    case 10114:
      return '此同步组ID已被封存';
    case 10115:
      return '此设备已在指定的同步组中';
    case 10116:
      return '同步组已满员';
    case 10117:
      return '此设备不在指定的同步组中';
    case 10201:
      return '配对码无效或已过期';
    case 10202:
      return '无法进行身份核验';
    case 10203:
      return '配对码与同步组不匹配';
    case 10301:
      return '不支持的编码';
    case 10302:
      return '客户端版本过旧';
    case 10303:
      return '无效的数据结构';
    default:
      return '未知错误（$errorCode）';
  }
}
