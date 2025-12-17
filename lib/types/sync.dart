import 'package:json_annotation/json_annotation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'base.dart';

part 'sync.g.dart';

@JsonSerializable()
class Announcement extends BaseDataClass {
  final String title;
  final String? date;
  final String group;
  final String? language;
  final String markdown;
  final String? source;

  Announcement({
    required this.title,
    this.date,
    required this.group,
    this.language,
    required this.markdown,
    this.source,
  });

  @override
  Map<String, dynamic> getEssentials() {
    return {
      'title': title,
      'date': date,
      'group': group,
      'language': language,
      'markdown': markdown,
      'source': source,
    };
  }

  /// Calculate unique key for this announcement based on essential fields
  String calculateKey() {
    final essentials = getEssentials();
    final jsonString = json.encode(essentials);
    final bytes = utf8.encode(jsonString);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);
}

@JsonSerializable()
class DeviceInfo extends BaseDataClass {
  final String? deviceId; // UUID
  final String deviceOs;
  final String deviceName;

  DeviceInfo({
    required this.deviceId,
    required this.deviceOs,
    required this.deviceName,
  });

  @override
  Map<String, dynamic> getEssentials() {
    return {
      'deviceId': deviceId,
      'deviceOs': deviceOs,
      'deviceName': deviceName,
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);
}

@JsonSerializable()
class PairingInfo extends BaseDataClass {
  final String pairCode;
  final int ttl; // Time to live in seconds

  PairingInfo({required this.pairCode, required this.ttl});

  @override
  Map<String, dynamic> getEssentials() {
    return {'pairCode': pairCode, 'ttl': ttl};
  }

  factory PairingInfo.fromJson(Map<String, dynamic> json) =>
      _$PairingInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PairingInfoToJson(this);
}

@JsonSerializable()
class JoinGroupResult extends BaseDataClass {
  final String groupId; // UUID
  final List<DeviceInfo> devices;

  JoinGroupResult({required this.groupId, required this.devices});

  @override
  Map<String, dynamic> getEssentials() {
    return {'groupId': groupId, 'devices': devices};
  }

  factory JoinGroupResult.fromJson(Map<String, dynamic> json) =>
      _$JoinGroupResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$JoinGroupResultToJson(this);
}

@JsonSerializable()
class SyncDeviceData extends BaseDataClass {
  final String? deviceId;
  final String? groupId;
  final String? deviceOs;
  final String? deviceName;

  SyncDeviceData({this.deviceId, this.groupId, this.deviceOs, this.deviceName});

  @override
  Map<String, dynamic> getEssentials() {
    return {
      'deviceId': deviceId,
      'groupId': groupId,
      'deviceOs': deviceOs,
      'deviceName': deviceName,
    };
  }

  factory SyncDeviceData.fromJson(Map<String, dynamic> json) =>
      _$SyncDeviceDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SyncDeviceDataToJson(this);

  SyncDeviceData copyWith({
    String? deviceId,
    String? groupId,
    String? deviceOs,
    String? deviceName,
  }) {
    return SyncDeviceData(
      deviceId: deviceId ?? this.deviceId,
      groupId: groupId ?? this.groupId,
      deviceOs: deviceOs ?? this.deviceOs,
      deviceName: deviceName ?? this.deviceName,
    );
  }
}

@JsonSerializable()
class ReleaseInfo extends BaseDataClass {
  final String stableVersion;
  final Map<String, Map<String, String>> stableDownloads;
  final String? betaVersion;
  final Map<String, Map<String, String>> betaDownloads;

  ReleaseInfo({
    required this.stableVersion,
    required this.stableDownloads,
    this.betaVersion,
    required this.betaDownloads,
  });

  @override
  Map<String, dynamic> getEssentials() {
    return {
      'stableVersion': stableVersion,
      'stableDownloads': stableDownloads,
      'betaVersion': betaVersion,
      'betaDownloads': betaDownloads,
    };
  }

  factory ReleaseInfo.fromJson(Map<String, dynamic> json) =>
      _$ReleaseInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReleaseInfoToJson(this);
}
