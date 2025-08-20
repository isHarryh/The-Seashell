enum WeekendDisplayMode {
  always, // 始终显示 (min=7, max=7)
  auto, // 自动显示 (min=5, max=7)
  never, // 从不显示 (min=5, max=5)
}

enum TableSize {
  medium, // 中等尺寸 (h=80)
  large, // 大尺寸 (h=100)
  extraLarge, // 超大尺寸 (h=120)
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
      case TableSize.medium:
        return '中';
      case TableSize.large:
        return '大';
      case TableSize.extraLarge:
        return '超大';
    }
  }

  double get height {
    switch (this) {
      case TableSize.medium:
        return 80.0;
      case TableSize.large:
        return 100.0;
      case TableSize.extraLarge:
        return 120.0;
    }
  }
}

class CurriculumSettings {
  final WeekendDisplayMode weekendMode;
  final TableSize tableSize;

  const CurriculumSettings({
    required this.weekendMode,
    required this.tableSize,
  });

  static const CurriculumSettings defaultSettings = CurriculumSettings(
    weekendMode: WeekendDisplayMode.auto,
    tableSize: TableSize.medium,
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

  CurriculumSettings copyWith({
    WeekendDisplayMode? weekendMode,
    TableSize? tableSize,
  }) {
    return CurriculumSettings(
      weekendMode: weekendMode ?? this.weekendMode,
      tableSize: tableSize ?? this.tableSize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurriculumSettings &&
        other.weekendMode == weekendMode &&
        other.tableSize == tableSize;
  }

  @override
  int get hashCode {
    return weekendMode.hashCode ^ tableSize.hashCode;
  }

  @override
  String toString() {
    return 'CurriculumSettings(mode: $weekendMode, size: $tableSize)';
  }
}
