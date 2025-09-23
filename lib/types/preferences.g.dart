// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurriculumSettings _$CurriculumSettingsFromJson(Map<String, dynamic> json) =>
    CurriculumSettings(
      weekendMode: $enumDecode(
        _$WeekendDisplayModeEnumMap,
        json['weekendMode'],
      ),
      tableSize: $enumDecode(_$TableSizeEnumMap, json['tableSize']),
      animationMode: $enumDecode(_$AnimationModeEnumMap, json['animationMode']),
      activated: json['activated'] as bool? ?? true,
    );

Map<String, dynamic> _$CurriculumSettingsToJson(CurriculumSettings instance) =>
    <String, dynamic>{
      'weekendMode': _$WeekendDisplayModeEnumMap[instance.weekendMode]!,
      'tableSize': _$TableSizeEnumMap[instance.tableSize]!,
      'animationMode': _$AnimationModeEnumMap[instance.animationMode]!,
      'activated': instance.activated,
    };

const _$WeekendDisplayModeEnumMap = {
  WeekendDisplayMode.always: 'always',
  WeekendDisplayMode.auto: 'auto',
  WeekendDisplayMode.never: 'never',
};

const _$TableSizeEnumMap = {
  TableSize.small: 'small',
  TableSize.medium: 'medium',
  TableSize.large: 'large',
};

const _$AnimationModeEnumMap = {
  AnimationMode.none: 'none',
  AnimationMode.fade: 'fade',
};
