// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) =>
    Announcement(
        title: json['title'] as String,
        date: json['date'] as String?,
        group: json['group'] as String,
        language: json['language'] as String?,
        markdown: json['markdown'] as String,
        source: json['source'] as String?,
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'title': instance.title,
      'date': instance.date,
      'group': instance.group,
      'language': instance.language,
      'markdown': instance.markdown,
      'source': instance.source,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) =>
    DeviceInfo(
        deviceId: json['deviceId'] as String?,
        deviceOs: json['deviceOs'] as String,
        deviceName: json['deviceName'] as String,
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'deviceId': instance.deviceId,
      'deviceOs': instance.deviceOs,
      'deviceName': instance.deviceName,
    };

PairingInfo _$PairingInfoFromJson(Map<String, dynamic> json) =>
    PairingInfo(
        pairCode: json['pairCode'] as String,
        ttl: (json['ttl'] as num).toInt(),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$PairingInfoToJson(PairingInfo instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'pairCode': instance.pairCode,
      'ttl': instance.ttl,
    };

JoinGroupResult _$JoinGroupResultFromJson(Map<String, dynamic> json) =>
    JoinGroupResult(
        groupId: json['groupId'] as String,
        devices: (json['devices'] as List<dynamic>)
            .map((e) => DeviceInfo.fromJson(e as Map<String, dynamic>))
            .toList(),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$JoinGroupResultToJson(JoinGroupResult instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'groupId': instance.groupId,
      'devices': instance.devices,
    };

SyncDeviceData _$SyncDeviceDataFromJson(Map<String, dynamic> json) =>
    SyncDeviceData(
        deviceId: json['deviceId'] as String?,
        groupId: json['groupId'] as String?,
        deviceOs: json['deviceOs'] as String?,
        deviceName: json['deviceName'] as String?,
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$SyncDeviceDataToJson(SyncDeviceData instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'deviceId': instance.deviceId,
      'groupId': instance.groupId,
      'deviceOs': instance.deviceOs,
      'deviceName': instance.deviceName,
    };

ReleaseInfo _$ReleaseInfoFromJson(Map<String, dynamic> json) =>
    ReleaseInfo(
        stableVersion: json['stableVersion'] as String,
        stableDownloads: (json['stableDownloads'] as Map<String, dynamic>).map(
          (k, e) => MapEntry(k, Map<String, String>.from(e as Map)),
        ),
        betaVersion: json['betaVersion'] as String?,
        betaDownloads: (json['betaDownloads'] as Map<String, dynamic>).map(
          (k, e) => MapEntry(k, Map<String, String>.from(e as Map)),
        ),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$ReleaseInfoToJson(ReleaseInfo instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'stableVersion': instance.stableVersion,
      'stableDownloads': instance.stableDownloads,
      'betaVersion': instance.betaVersion,
      'betaDownloads': instance.betaDownloads,
    };
