// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

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
