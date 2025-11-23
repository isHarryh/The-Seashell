import '/types/sync.dart';

extension DeviceInfoExtension on DeviceInfo {
  static DeviceInfo parse(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId'] as String?,
      deviceOs: json['deviceOs'] as String? ?? '',
      deviceName: json['deviceName'] as String? ?? '',
    );
  }
}

extension PairingInfoExtension on PairingInfo {
  static PairingInfo parse(Map<String, dynamic> json) {
    return PairingInfo(
      pairCode: json['pairCode'] as String? ?? '',
      ttl: (json['ttl'] as num?)?.toInt() ?? 0,
    );
  }
}

extension JoinGroupResultExtension on JoinGroupResult {
  static JoinGroupResult parse(Map<String, dynamic> json) {
    return JoinGroupResult(
      groupId: json['groupId'] as String? ?? '',
      devices:
          (json['devices'] as List<dynamic>?)
              ?.map((e) => DeviceInfoExtension.parse(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
