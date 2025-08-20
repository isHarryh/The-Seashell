class UserInfo {
  final String userName;
  final String userNameAlt;
  final String userSchool;
  final String userSchoolAlt;
  final String userId;

  const UserInfo({
    required this.userName,
    required this.userNameAlt,
    required this.userSchool,
    required this.userSchoolAlt,
    required this.userId,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userName: json['userName'] as String? ?? '',
      userNameAlt: json['userNameAlt'] as String? ?? '',
      userSchool: json['userSchool'] as String? ?? '',
      userSchoolAlt: json['userSchoolAlt'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userNameAlt': userNameAlt,
      'userSchool': userSchool,
      'userSchoolAlt': userSchoolAlt,
      'userId': userId,
    };
  }

  @override
  String toString() {
    return 'UserInfo(userName: $userName, userNameAlt: $userNameAlt, userSchool: $userSchool, userSchoolAlt: $userSchoolAlt, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfo &&
        other.userName == userName &&
        other.userNameAlt == userNameAlt &&
        other.userSchool == userSchool &&
        other.userSchoolAlt == userSchoolAlt &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return userName.hashCode ^
        userNameAlt.hashCode ^
        userSchool.hashCode ^
        userSchoolAlt.hashCode ^
        userId.hashCode;
  }
}

class CourseGradeItem {
  final String courseId;
  final String courseName;
  final String? courseNameAlt;
  final String termId;
  final String termName;
  final String termNameAlt;
  final String type;
  final String category;
  final String? schoolName;
  final String? schoolNameAlt;
  final String? makeupStatus;
  final String? makeupStatusAlt;
  final String? examType;
  final int hours;
  final int credit;
  final int score;

  const CourseGradeItem({
    required this.courseId,
    required this.courseName,
    this.courseNameAlt,
    required this.termId,
    required this.termName,
    required this.termNameAlt,
    required this.type,
    required this.category,
    this.schoolName,
    this.schoolNameAlt,
    this.makeupStatus,
    this.makeupStatusAlt,
    this.examType,
    required this.hours,
    required this.credit,
    required this.score,
  });

  factory CourseGradeItem.fromJson(Map<String, dynamic> json) {
    return CourseGradeItem(
      courseId: json['kcdm'] as String? ?? '',
      courseName: json['kcmc'] as String? ?? '',
      courseNameAlt: json['kcmc_en'] as String?,
      termId: json['xnxq'] as String? ?? '',
      termName: json['xnxqmc'] as String? ?? '',
      termNameAlt: json['xnxqmcen'] as String? ?? '',
      type: json['kcxz'] as String? ?? '',
      category: json['kclb'] as String? ?? '',
      schoolName: json['yxmc'] as String?,
      schoolNameAlt: json['yxmc_en'] as String?,
      makeupStatus: json['bkcx'] as String?,
      makeupStatusAlt: json['bkcx_en'] as String?,
      examType: json['khfs'] as String?,
      hours: int.tryParse(json['xs']?.toString() ?? '0') ?? 0,
      credit: json['xf'] as int? ?? 0,
      score: int.tryParse(json['zpcj']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'courseNameAlt': courseNameAlt,
      'termId': termId,
      'termName': termName,
      'termNameAlt': termNameAlt,
      'type': type,
      'category': category,
      'schoolName': schoolName,
      'schoolNameAlt': schoolNameAlt,
      'makeupStatus': makeupStatus,
      'makeupStatusAlt': makeupStatusAlt,
      'examType': examType,
      'hours': hours,
      'credit': credit,
      'score': score,
    };
  }

  @override
  String toString() {
    return 'CourseGradeItem(courseId: $courseId, courseName: $courseName, termName: $termName, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseGradeItem &&
        other.courseId == courseId &&
        other.termId == termId;
  }

  @override
  int get hashCode {
    return courseId.hashCode ^ termId.hashCode;
  }
}

class ClassItem {
  final int day; // 星期几 (1-7)
  final int period; // 大节节次
  final List<int> weeks; // 周次
  final String weeksText; // 周次文本描述
  final String className; // 课程名称
  final String? classNameAlt; // 课程名称（英文）
  final String teacherName; // 教师名称
  final String? teacherNameAlt; // 教师名称（英文）
  final String locationName; // 地点名称
  final String? locationNameAlt; // 地点名称（英文）
  final String periodName; // 课节文字描述
  final String? periodNameAlt; // 课节文字描述（英文）
  final int? colorId; // 背景颜色编号

  const ClassItem({
    required this.day,
    required this.period,
    required this.weeks,
    required this.weeksText,
    required this.className,
    this.classNameAlt,
    required this.teacherName,
    this.teacherNameAlt,
    required this.locationName,
    this.locationNameAlt,
    required this.periodName,
    this.periodNameAlt,
    this.colorId,
  });

  // 从 JSON 数据解析课程信息
  static ClassItem? fromJson(Map<String, dynamic> json) {
    try {
      final key = json['key'] as String?;
      final kbxx = json['kbxx'] as String?;
      final kbxxEn = json['kbxx_en'] as String?;

      if (key == null || kbxx == null || key == 'bz') {
        // 跳过非正常课程格式或不排课课程
        return null;
      }

      // 从 key 解析 day 和 period
      final keyMatch = RegExp(r'xq(\d+)_jc(\d+)').firstMatch(key);
      if (keyMatch == null) {
        return null;
      }

      final day = int.parse(keyMatch.group(1)!);
      final period = int.parse(keyMatch.group(2)!);

      // 解析 kbxx 内容
      final lines = kbxx.split('\n');
      if (lines.length < 3) {
        return null;
      }

      final className = lines[0];
      final teacherName = lines[1];
      final weeksText = lines[2];
      final locationName = lines.length > 3 ? lines[3] : '';
      final periodName = lines.length > 4 ? lines[4] : '';

      // 解析英文版本
      String? classNameAlt;
      String? teacherNameAlt;
      String? locationNameAlt;
      String? periodNameAlt;

      if (kbxxEn != null) {
        final enLines = kbxxEn.split('\n');
        if (enLines.isNotEmpty) classNameAlt = enLines[0];
        if (enLines.length > 1) teacherNameAlt = enLines[1];
        if (enLines.length > 3) locationNameAlt = enLines[3];
        if (enLines.length > 4) periodNameAlt = enLines[4];
      }

      // 解析周次
      final weeks = _parseWeeks(weeksText);

      // 从课程名称生成颜色ID（简单哈希）
      final colorId = className.hashCode % 10;

      return ClassItem(
        day: day,
        period: period,
        weeks: weeks,
        weeksText: weeksText,
        className: className,
        classNameAlt: classNameAlt,
        teacherName: teacherName,
        teacherNameAlt: teacherNameAlt,
        locationName: locationName,
        locationNameAlt: locationNameAlt,
        periodName: periodName,
        periodNameAlt: periodNameAlt,
        colorId: colorId,
      );
    } catch (e) {
      return null;
    }
  }

  // 解析周次字符串
  static List<int> _parseWeeks(String weeksText) {
    final weeks = <int>[];

    // 移除"周"字符，保留数字、逗号、横线
    final cleanText = weeksText.replaceAll('周', '').trim();

    // 按逗号分割不同的周期段
    final segments = cleanText.split(',');

    for (final segment in segments) {
      final trimmedSegment = segment.trim();
      if (trimmedSegment.isEmpty) continue;

      if (trimmedSegment.contains('-')) {
        // 处理范围，如 "1-8" 或 "9-16"
        final parts = trimmedSegment.split('-');
        if (parts.length == 2) {
          final start = int.tryParse(parts[0].trim());
          final end = int.tryParse(parts[1].trim());
          if (start != null && end != null && start <= end) {
            for (int i = start; i <= end; i++) {
              weeks.add(i);
            }
          }
        }
      } else {
        // 处理单个周次，如 "1" 或 "3"
        final week = int.tryParse(trimmedSegment);
        if (week != null) {
          weeks.add(week);
        }
      }
    }

    // 去重并排序
    return weeks.toSet().toList()..sort();
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'period': period,
      'weeks': weeks,
      'className': className,
      'classNameAlt': classNameAlt,
      'teacherName': teacherName,
      'teacherNameAlt': teacherNameAlt,
      'locationName': locationName,
      'locationNameAlt': locationNameAlt,
      'periodName': periodName,
      'periodNameAlt': periodNameAlt,
      'colorId': colorId,
    };
  }

  @override
  String toString() {
    return 'ClassItem(day: $day, period: $period, weeks: $weeks, className: $className, teacherName: $teacherName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassItem &&
        other.day == day &&
        other.period == period &&
        other.className == className &&
        other.teacherName == teacherName;
  }

  @override
  int get hashCode {
    return day.hashCode ^
        period.hashCode ^
        className.hashCode ^
        teacherName.hashCode;
  }
}

class ClassPeriod {
  final String termYear; // 学年
  final int termSeason; // 学期
  final int majorId; // 大节编号
  final int minorId; // 小节编号
  final String majorName; // 大节名称
  final String minorName; // 小节名称
  final String? majorStartTime; // 大节开始时间
  final String? majorEndTime; // 大节结束时间
  final String minorStartTime; // 小节开始时间
  final String minorEndTime; // 小节结束时间

  const ClassPeriod({
    required this.termYear,
    required this.termSeason,
    required this.majorId,
    required this.minorId,
    required this.majorName,
    required this.minorName,
    this.majorStartTime,
    this.majorEndTime,
    required this.minorStartTime,
    required this.minorEndTime,
  });

  factory ClassPeriod.fromJson(Map<String, dynamic> json) {
    return ClassPeriod(
      termYear: json['xn'] as String? ?? '',
      termSeason: int.tryParse(json['xq']?.toString() ?? '1') ?? 1,
      majorId: int.tryParse(json['dj']?.toString() ?? '1') ?? 1,
      minorId: int.tryParse(json['xj']?.toString() ?? '1') ?? 1,
      majorName: json['djms'] as String? ?? '',
      minorName: json['xjms'] as String? ?? '',
      majorStartTime: json['kskssj'] as String?,
      majorEndTime: json['ksjssj'] as String?,
      minorStartTime: json['kssj'] as String? ?? '',
      minorEndTime: json['jssj'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'termYear': termYear,
      'termSeason': termSeason,
      'majorId': majorId,
      'minorId': minorId,
      'majorName': majorName,
      'minorName': minorName,
      'majorStartTime': majorStartTime,
      'majorEndTime': majorEndTime,
      'minorStartTime': minorStartTime,
      'minorEndTime': minorEndTime,
    };
  }

  // 生成时间段显示文本
  String get timeRange => '$minorStartTime-$minorEndTime';

  @override
  String toString() {
    return 'ClassPeriod(minorId: $minorId, minorName: $minorName, timeRange: $timeRange)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassPeriod &&
        other.termYear == termYear &&
        other.termSeason == termSeason &&
        other.minorId == minorId;
  }

  @override
  int get hashCode {
    return termYear.hashCode ^ termSeason.hashCode ^ minorId.hashCode;
  }
}
