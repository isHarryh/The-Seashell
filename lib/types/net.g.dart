// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequirements _$LoginRequirementsFromJson(Map<String, dynamic> json) =>
    LoginRequirements(
        checkCode: json['checkCode'] as String,
        tryTimes: (json['tryTimes'] as num).toInt(),
        tryTimesThreshold: (json['tryTimesThreshold'] as num).toInt(),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$LoginRequirementsToJson(LoginRequirements instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'checkCode': instance.checkCode,
      'tryTimes': instance.tryTimes,
      'tryTimesThreshold': instance.tryTimesThreshold,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

NetUserInfo _$NetUserInfoFromJson(Map<String, dynamic> json) =>
    NetUserInfo(
        account: json['account'] as String,
        subscription: json['subscription'] as String,
        status: json['status'] as String,
        leftFlow: json['leftFlow'] as String?,
        leftTime: json['leftTime'] as String?,
        leftMoney: json['leftMoney'] as String?,
        overDate: json['overDate'] as String?,
        onlineState: json['onlineState'] as String?,
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$NetUserInfoToJson(NetUserInfo instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'account': instance.account,
      'subscription': instance.subscription,
      'status': instance.status,
      'leftFlow': instance.leftFlow,
      'leftTime': instance.leftTime,
      'leftMoney': instance.leftMoney,
      'overDate': instance.overDate,
      'onlineState': instance.onlineState,
    };

NetUserIntegratedData _$NetUserIntegratedDataFromJson(
  Map<String, dynamic> json,
) =>
    NetUserIntegratedData(
        account: json['account'] as String,
        password: json['password'] as String,
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$NetUserIntegratedDataToJson(
  NetUserIntegratedData instance,
) => <String, dynamic>{
  r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
    instance.$lastUpdateTime,
    const UTCConverter().toJson,
  ),
  'account': instance.account,
  'password': instance.password,
};

MacDevice _$MacDeviceFromJson(Map<String, dynamic> json) =>
    MacDevice(name: json['name'] as String, mac: json['mac'] as String)
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$MacDeviceToJson(MacDevice instance) => <String, dynamic>{
  r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
    instance.$lastUpdateTime,
    const UTCConverter().toJson,
  ),
  'name': instance.name,
  'mac': instance.mac,
};

MonthlyBill _$MonthlyBillFromJson(Map<String, dynamic> json) =>
    MonthlyBill(
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        packageName: json['packageName'] as String,
        monthlyFee: (json['monthlyFee'] as num).toDouble(),
        usageFee: (json['usageFee'] as num).toDouble(),
        usageDurationMinutes: (json['usageDurationMinutes'] as num).toDouble(),
        usageFlowMb: (json['usageFlowMb'] as num).toDouble(),
        createTime: DateTime.parse(json['createTime'] as String),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$MonthlyBillToJson(MonthlyBill instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'packageName': instance.packageName,
      'monthlyFee': instance.monthlyFee,
      'usageFee': instance.usageFee,
      'usageDurationMinutes': instance.usageDurationMinutes,
      'usageFlowMb': instance.usageFlowMb,
      'createTime': instance.createTime.toIso8601String(),
    };

RealtimeUsage _$RealtimeUsageFromJson(Map<String, dynamic> json) =>
    RealtimeUsage(
        v4: (json['v4'] as num).toDouble(),
        v6: (json['v6'] as num).toDouble(),
        time: DateTime.parse(json['time'] as String),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$RealtimeUsageToJson(RealtimeUsage instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'v4': instance.v4,
      'v6': instance.v6,
      'time': instance.time.toIso8601String(),
    };
