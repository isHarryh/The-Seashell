// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => DeviceInfo(
  deviceId: json['deviceId'] as String?,
  deviceOs: json['deviceOs'] as String,
  deviceName: json['deviceName'] as String,
);

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'deviceOs': instance.deviceOs,
      'deviceName': instance.deviceName,
    };

PairingInfo _$PairingInfoFromJson(Map<String, dynamic> json) => PairingInfo(
  pairCode: json['pairCode'] as String,
  ttl: (json['ttl'] as num).toInt(),
);

Map<String, dynamic> _$PairingInfoToJson(PairingInfo instance) =>
    <String, dynamic>{'pairCode': instance.pairCode, 'ttl': instance.ttl};

JoinGroupResult _$JoinGroupResultFromJson(Map<String, dynamic> json) =>
    JoinGroupResult(
      groupId: json['groupId'] as String,
      devices: (json['devices'] as List<dynamic>)
          .map((e) => DeviceInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JoinGroupResultToJson(JoinGroupResult instance) =>
    <String, dynamic>{'groupId': instance.groupId, 'devices': instance.devices};

SyncDeviceData _$SyncDeviceDataFromJson(Map<String, dynamic> json) =>
    SyncDeviceData(
      deviceId: json['deviceId'] as String?,
      groupId: json['groupId'] as String?,
      deviceOs: json['deviceOs'] as String?,
      deviceName: json['deviceName'] as String?,
    );

Map<String, dynamic> _$SyncDeviceDataToJson(SyncDeviceData instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'groupId': instance.groupId,
      'deviceOs': instance.deviceOs,
      'deviceName': instance.deviceName,
    };
