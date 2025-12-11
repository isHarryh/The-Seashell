import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '/services/sync/base.dart';
import '/services/sync/exceptions.dart';
import '/services/sync/sync_service.dart';
import '/types/sync.dart';
import '/utils/meta_info.dart';

class SyncServiceProd extends BaseSyncService {
  String get baseUrl => 'https://thebeike.cn/api/client';
  String get userAgent => 'TheBeike-GUI/${MetaInfo.instance.appVersion}';

  @override
  Future<List<Announcement>> getAnnouncements() async {
    final response = await _sendRequest('announcement', {});

    if (response == null || response['contents'] == null) {
      return [];
    }

    final announcements = response['contents'] as List<dynamic>;
    return announcements
        .map((a) => Announcement.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>?> _sendRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    http.Response response;

    try {
      response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json', 'User-Agent': userAgent},
        body: json.encode(body),
      );
    } catch (e) {
      throw SyncServiceNetworkError('Network error: $e', e);
    }

    int responseBusinessCode;
    Map<String, dynamic>? responseData;

    try {
      final responseJson = json.decode(response.body) as Map<String, dynamic>;
      responseBusinessCode = responseJson['code'] as int;
      responseData = responseJson['data'] as Map<String, dynamic>?;
    } catch (e) {
      throw SyncServiceBadResponse('Invalid response format', e);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseData;
    } else if (response.statusCode == 400) {
      throw SyncServiceBadRequest(
        getSyncErrorMessage(responseBusinessCode),
        responseBusinessCode,
      );
    } else if (response.statusCode == 401) {
      throw SyncServiceAuthError(
        getSyncErrorMessage(responseBusinessCode),
        responseBusinessCode,
      );
    } else {
      throw SyncServiceException(
        'Server error: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  @override
  Future<String> registerDevice({
    required String deviceOs,
    required String deviceName,
  }) async {
    final response = await _sendRequest('device/register', {
      'deviceOs': deviceOs,
      'deviceName': deviceName,
    });

    setOnline();
    return response!['deviceId'] as String;
  }

  @override
  Future<String> createGroup({
    required String deviceId,
    required String byytCookie,
  }) async {
    final response = await _sendRequest('sync/create', {
      'deviceId': deviceId,
      'byytCookie': byytCookie,
    });

    return response!['groupId'] as String;
  }

  @override
  Future<PairingInfo> openPairing({
    required String deviceId,
    required String groupId,
  }) async {
    final response = await _sendRequest('sync/open', {
      'deviceId': deviceId,
      'groupId': groupId,
    });

    return PairingInfoExtension.parse(response!);
  }

  @override
  Future<void> closePairing({
    required String pairCode,
    required String groupId,
  }) async {
    await _sendRequest('sync/close', {
      'pairCode': pairCode,
      'groupId': groupId,
    });
  }

  @override
  Future<List<DeviceInfo>> listDevices({
    required String groupId,
    String? deviceId,
  }) async {
    final body = {'groupId': groupId};
    if (deviceId != null) {
      body['deviceId'] = deviceId;
    }
    final response = await _sendRequest('sync/list', body);

    final devices = response!['devices'] as List<dynamic>;
    return devices
        .map((d) => DeviceInfoExtension.parse(d as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<JoinGroupResult> joinGroup({
    required String deviceId,
    required String pairCode,
  }) async {
    final response = await _sendRequest('sync/join', {
      'deviceId': deviceId,
      'pairCode': pairCode,
    });

    return JoinGroupResultExtension.parse(response!);
  }

  @override
  Future<void> leaveGroup({
    required String deviceId,
    required String groupId,
  }) async {
    await _sendRequest('sync/leave', {
      'deviceId': deviceId,
      'groupId': groupId,
    });
  }

  @override
  Future<Map<String, dynamic>?> update({
    required String deviceId,
    required String groupId,
    required Map<String, dynamic> config,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/sync/update',
    ).replace(queryParameters: {'deviceId': deviceId, 'groupId': groupId});

    List<int> bodyBytes;
    if (config.isEmpty) {
      bodyBytes = [];
    } else {
      final jsonString = json.encode(config);
      bodyBytes = gzip.encode(utf8.encode(jsonString));
    }

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/octet-stream',
          'Content-Encoding': 'gzip',
          'User-Agent': userAgent,
        },
        body: bodyBytes,
      );
    } catch (e) {
      recordSyncStatus(SyncStatusType.failure);
      throw SyncServiceNetworkError('Network error: $e', e);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.bodyBytes.isEmpty) {
        recordSyncStatus(SyncStatusType.success);
        return null;
      }
      try {
        final decodedBytes = gzip.decode(response.bodyBytes);
        final decodedString = utf8.decode(decodedBytes);
        final result = json.decode(decodedString) as Map<String, dynamic>;
        recordSyncStatus(SyncStatusType.success);
        return result;
      } catch (e) {
        recordSyncStatus(SyncStatusType.failure);
        throw SyncServiceBadResponse('Invalid response format', e);
      }
    } else {
      // Try to parse error from JSON if possible
      int responseBusinessCode = -1;
      try {
        final responseJson = json.decode(response.body) as Map<String, dynamic>;
        responseBusinessCode = responseJson['code'] as int;
      } catch (_) {
        // Ignore if not JSON
      }

      final errorMsg = getSyncErrorMessage(responseBusinessCode);
      recordSyncStatus(SyncStatusType.failure);

      if (response.statusCode == 400) {
        throw SyncServiceBadRequest(errorMsg, responseBusinessCode);
      } else if (response.statusCode == 401) {
        throw SyncServiceAuthError(errorMsg, responseBusinessCode);
      } else {
        throw SyncServiceException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    }
  }
}
