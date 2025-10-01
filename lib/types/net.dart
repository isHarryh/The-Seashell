import 'package:json_annotation/json_annotation.dart';
import '/types/base.dart';

part 'net.g.dart';

@JsonSerializable()
class LoginRequirements extends BaseDataClass {
  final String checkCode;
  final int tryTimes;
  final int tryTimesThreshold;

  const LoginRequirements({
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

  const NetUserInfo({
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
class MacDevice extends BaseDataClass {
  final String name;
  final String mac;

  const MacDevice({required this.name, required this.mac});

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

  const MonthlyBill({
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
