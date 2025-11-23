import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '/types/base.dart';

part 'net.g.dart';

/// Network connectivity status for topology display
enum NetworkStatus {
  /// No data available
  noData,

  /// Connected (has recent records within 2x request interval)
  connected,

  /// Disconnected (no recent records)
  disconnected,
}

extension NetworkStatusExtension on NetworkStatus {
  Color get color {
    switch (this) {
      case NetworkStatus.noData:
        return Colors.grey;
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.disconnected:
        return Colors.red;
    }
  }

  String get label {
    switch (this) {
      case NetworkStatus.noData:
        return '无数据';
      case NetworkStatus.connected:
        return '连通';
      case NetworkStatus.disconnected:
        return '不连通';
    }
  }
}

@JsonSerializable()
class LoginRequirements extends BaseDataClass {
  final String checkCode;
  final int tryTimes;
  final int tryTimesThreshold;

  LoginRequirements({
    required this.checkCode,
    required this.tryTimes,
    required this.tryTimesThreshold,
  });

  bool get isNeedExtraCode => tryTimes >= tryTimesThreshold;

  @override
  Map<String, dynamic> getEssentials() {
    return {
      'checkCode': checkCode,
      'tryTimes': tryTimes,
      'tryTimesThreshold': tryTimesThreshold,
    };
  }

  factory LoginRequirements.fromJson(Map<String, dynamic> json) =>
      _$LoginRequirementsFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequirementsToJson(this);
}

@JsonSerializable()
class NetUserInfo extends BaseDataClass {
  final String account;
  final String subscription;
  final String status;
  final String? leftFlow;
  final String? leftTime;
  final String? leftMoney;
  final String? overDate;
  final String? onlineState;

  NetUserInfo({
    required this.account,
    required this.subscription,
    required this.status,
    this.leftFlow,
    this.leftTime,
    this.leftMoney,
    this.overDate,
    this.onlineState,
  });

  @override
  Map<String, dynamic> getEssentials() {
    return {
      'account': account,
      'subscription': subscription,
      'status': status,
      'leftFlow': leftFlow,
      'leftTime': leftTime,
      'leftMoney': leftMoney,
      'overDate': overDate,
      'onlineState': onlineState,
    };
  }

  factory NetUserInfo.fromJson(Map<String, dynamic> json) =>
      _$NetUserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$NetUserInfoToJson(this);
}

@JsonSerializable()
class NetUserIntegratedData extends BaseDataClass {
  final String account;
  final String password;

  NetUserIntegratedData({required this.account, required this.password});

  @override
  Map<String, dynamic> getEssentials() {
    return {'account': account, 'password': password};
  }

  factory NetUserIntegratedData.fromJson(Map<String, dynamic> json) =>
      _$NetUserIntegratedDataFromJson(json);
  Map<String, dynamic> toJson() => _$NetUserIntegratedDataToJson(this);
}

@JsonSerializable()
class MacDevice extends BaseDataClass {
  final String name;
  final String mac;

  MacDevice({required this.name, required this.mac});

  @override
  Map<String, dynamic> getEssentials() {
    return {'name': name, 'mac': mac};
  }

  factory MacDevice.fromJson(Map<String, dynamic> json) =>
      _$MacDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$MacDeviceToJson(this);
}

@JsonSerializable()
class MonthlyBill extends BaseDataClass {
  final DateTime startDate;
  final DateTime endDate;
  final String packageName;
  final double monthlyFee;
  final double usageFee;
  final double usageDurationMinutes;
  final double usageFlowMb;
  final DateTime createTime;

  MonthlyBill({
    required this.startDate,
    required this.endDate,
    required this.packageName,
    required this.monthlyFee,
    required this.usageFee,
    required this.usageDurationMinutes,
    required this.usageFlowMb,
    required this.createTime,
  });

  @override
  Map<String, dynamic> getEssentials() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'packageName': packageName,
      'monthlyFee': monthlyFee,
      'usageFee': usageFee,
      'usageDurationMinutes': usageDurationMinutes,
      'usageFlowMb': usageFlowMb,
      'createTime': createTime.toIso8601String(),
    };
  }

  factory MonthlyBill.fromJson(Map<String, dynamic> json) =>
      _$MonthlyBillFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyBillToJson(this);
}

@JsonSerializable()
class RealtimeUsage extends BaseDataClass {
  final double v4;
  final double v6;
  final DateTime time;

  RealtimeUsage({required this.v4, required this.v6, required this.time});

  @override
  Map<String, dynamic> getEssentials() {
    return {'v4': v4, 'v6': v6, 'time': time.toIso8601String()};
  }

  factory RealtimeUsage.fromJson(Map<String, dynamic> json) =>
      _$RealtimeUsageFromJson(json);
  Map<String, dynamic> toJson() => _$RealtimeUsageToJson(this);
}
