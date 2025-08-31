import 'package:json_annotation/json_annotation.dart';
import 'base.dart';

part 'preferences.g.dart';

enum WeekendDisplayMode {
  always, // 始终显示 (min=7, max=7)
  auto, // 自动显示 (min=5, max=7)
  never, // 从不显示 (min=5, max=5)
}

enum TableSize {
  small, // 中等尺寸 (h=80)
  medium, // 大尺寸 (h=100)
  large, // 超大尺寸 (h=120)
}

extension WeekendDisplayModeExtension on WeekendDisplayMode {
  String get displayName {
    switch (this) {
      case WeekendDisplayMode.always:
        return '始终';
      case WeekendDisplayMode.auto:
        return '自动';
      case WeekendDisplayMode.never:
        return '从不';
    }
  }

  String get description {
    switch (this) {
      case WeekendDisplayMode.always:
        return '始终显示周末';
      case WeekendDisplayMode.auto:
        return '有课时显示周末';
      case WeekendDisplayMode.never:
        return '从不显示周末';
    }
  }
}

extension TableSizeExtension on TableSize {
  String get displayName {
    switch (this) {
      case TableSize.small:
        return '中';
      case TableSize.medium:
        return '大';
      case TableSize.large:
        return '超大';
    }
  }

  double get height {
    switch (this) {
      case TableSize.small:
        return 80.0;
      case TableSize.medium:
        return 100.0;
      case TableSize.large:
        return 120.0;
    }
  }
}

@JsonSerializable()
class CurriculumSettings extends Serializable {
  WeekendDisplayMode weekendMode;
  TableSize tableSize;
  bool activated;

  CurriculumSettings({
    required this.weekendMode, 
    required this.tableSize,
    this.activated = true,
  });

  static final CurriculumSettings defaultSettings = CurriculumSettings(
    weekendMode: WeekendDisplayMode.auto,
    tableSize: TableSize.small,
    activated: true,
  );

  int get minWeekdays {
    switch (weekendMode) {
      case WeekendDisplayMode.always:
        return 7;
      case WeekendDisplayMode.auto:
        return 5;
      case WeekendDisplayMode.never:
        return 5;
    }
  }

  int get maxWeekdays {
    switch (weekendMode) {
      case WeekendDisplayMode.always:
        return 7;
      case WeekendDisplayMode.auto:
        return 7;
      case WeekendDisplayMode.never:
        return 5;
    }
  }

  int calculateDisplayDays(List<int> courseDays) {
    if (courseDays.isEmpty) {
      return minWeekdays;
    }
    final maxCourseDay = courseDays.reduce((a, b) => a > b ? a : b);
    final requiredDays = maxCourseDay.clamp(minWeekdays, maxWeekdays);
    return requiredDays;
  }

  Map<String, dynamic> toJson() => _$CurriculumSettingsToJson(this);
  factory CurriculumSettings.fromJson(Map<String, dynamic> json) =>
      _$CurriculumSettingsFromJson(json);
}
