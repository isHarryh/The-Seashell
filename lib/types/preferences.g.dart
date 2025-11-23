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
    )..$lastUpdateTime = DateTime.parse(json[r'$lastUpdateTime'] as String);

Map<String, dynamic> _$CurriculumSettingsToJson(CurriculumSettings instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': instance.$lastUpdateTime.toIso8601String(),
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
  AnimationMode.slide: 'slide',
};

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) =>
    AppSettings(themeMode: $enumDecode(_$ThemeModeEnumMap, json['themeMode']))
      ..$lastUpdateTime = DateTime.parse(json[r'$lastUpdateTime'] as String);

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': instance.$lastUpdateTime.toIso8601String(),
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};
