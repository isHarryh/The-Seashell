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

extension ReleaseInfoExtension on ReleaseInfo {
  String getDisplayPlatformName(String platform) {
    return switch (platform.toLowerCase()) {
      'windows' => 'Windows',
      'macos' => 'macOS',
      'linux' => 'Linux',
      'android' => 'Android',
      'ios' => 'iOS',
      _ => platform,
    };
  }

  String getDisplayDownloadChannelName(String channel) {
    return switch (channel.toLowerCase()) {
      'github' => 'GitHub 仓库',
      'yunpan' => '北科云盘镜像',
      _ => channel,
    };
  }

  String getDisplayDownloadChannelTip(String channel) {
    return switch (channel.toLowerCase()) {
      'github' => '从 GitHub 官方仓库中下载，网络连接可能不稳定',
      'yunpan' => '从北科内网云盘下载，速度快且不消耗校园网流量',
      _ => '',
    };
  }

  bool getIsRecommendedChannel(String channel) {
    return switch (channel.toLowerCase()) {
      'yunpan' => true,
      _ => false,
    };
  }
}
