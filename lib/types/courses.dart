import 'base.dart';

class UserInfo extends BaseDataClass {
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

  @override
  Map<String, dynamic> getEssentials() {
    return {
      'userName': userName,
      'userNameAlt': userNameAlt,
      'userSchool': userSchool,
      'userSchoolAlt': userSchoolAlt,
      'userId': userId,
    };
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userName: json['userName'] as String? ?? '',
      userNameAlt: json['userNameAlt'] as String? ?? '',
      userSchool: json['userSchool'] as String? ?? '',
      userSchoolAlt: json['userSchoolAlt'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
    );
  }
}

class CourseGradeItem extends BaseDataClass {
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
  final double hours;
  final double credit;
  final double score;

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

  @override
  Map<String, dynamic> getEssentials() {
    return {'courseId': courseId, 'termId': termId};
  }

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
      hours: double.parse(json['xs']?.toString() ?? '0'),
      credit: double.parse(json['xf']?.toString() ?? '0'),
      score: double.parse(json['zpcj']?.toString() ?? '0'),
    );
  }
}

class ClassItem extends BaseDataClass {
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

  @override
  Map<String, dynamic> getEssentials() {
    return {
      'day': day,
      'period': period,
      'className': className,
      'teacherName': teacherName,
    };
  }

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
}

class ClassPeriod extends BaseDataClass {
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

  @override
  Map<String, dynamic> getEssentials() {
    return {'termYear': termYear, 'termSeason': termSeason, 'minorId': minorId};
  }

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

  String get timeRange => '$minorStartTime-$minorEndTime';
}

class TermInfo extends BaseDataClass {
  final String year; // eg. "2024-2025"
  final int season;

  const TermInfo({required this.year, required this.season});

  @override
  Map<String, dynamic> getEssentials() {
    return {'year': year, 'season': season};
  }

  factory TermInfo.fromJson(Map<String, dynamic> json) {
    return TermInfo(
      year: json['xn'] as String,
      season: int.parse(json['xq'].toString()),
    );
  }
}

class CourseDetail extends BaseDataClass {
  final String classId; // 讲台代码
  final String? extraName; // 额外名称
  final String? extraNameAlt; // 额外名称英文
  final String selectionStatus; // 选课状态
  final String selectionStartTime; // 讲台选课开始时间
  final String selectionEndTime; // 讲台选课结束时间
  final int ugTotal; // 本科生容量
  final int ugReserved; // 本科生已选
  final int pgTotal; // 研究生容量
  final int pgReserved; // 研究生已选
  final int? maleTotal; // 男生容量
  final int? maleReserved; // 男生已选
  final int? femaleTotal; // 女生容量
  final int? femaleReserved; // 女生已选

  final String? detailHtml; // 详情描述HTML
  final String? detailHtmlAlt; // 详情描述HTML英文
  final String? detailTeacherId; // 教师内部ID
  final String? detailTeacherName; // 教师名称
  final String? detailTeacherNameAlt; // 教师名称英文
  final List<String>? detailSchedule; // 上课时间列表
  final List<String>? detailScheduleAlt; // 上课时间列表英文
  final String? detailClasses; // 生效班级
  final String? detailClassesAlt; // 生效班级英文
  final List<String>? detailTarget; // 面向对象列表
  final List<String>? detailTargetAlt; // 面向对象列表英文
  final String? detailExtra; // 额外信息
  final String? detailExtraAlt; // 额外信息英文

  const CourseDetail({
    required this.classId,
    this.extraName,
    this.extraNameAlt,
    this.detailHtml,
    this.detailHtmlAlt,
    this.detailTeacherId,
    this.detailTeacherName,
    this.detailTeacherNameAlt,
    this.detailSchedule,
    this.detailScheduleAlt,
    this.detailClasses,
    this.detailClassesAlt,
    this.detailTarget,
    this.detailTargetAlt,
    this.detailExtra,
    this.detailExtraAlt,
    required this.selectionStatus,
    required this.selectionStartTime,
    required this.selectionEndTime,
    required this.ugTotal,
    required this.ugReserved,
    required this.pgTotal,
    required this.pgReserved,
    this.maleTotal,
    this.maleReserved,
    this.femaleTotal,
    this.femaleReserved,
  });

  @override
  Map<String, dynamic> getEssentials() {
    return {'classId': classId};
  }

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final detailHtml = json['kcxx'] as String?;
    final detailHtmlAlt = json['kcxx_en'] as String?;

    final parsedDetail = _parseDetailHtml(detailHtml);
    final parsedDetailAlt = _parseDetailHtml(detailHtmlAlt);

    return CourseDetail(
      classId: json['id'] as String? ?? '',
      extraName: json['tyxmmc'] as String?,
      extraNameAlt: json['tyxmmc_en'] as String?,
      detailHtml: detailHtml,
      detailHtmlAlt: detailHtmlAlt,
      detailTeacherId: parsedDetail['teacherId'],
      detailTeacherName: parsedDetail['teacherName'],
      detailTeacherNameAlt: parsedDetailAlt['teacherName'],
      detailSchedule: parsedDetail['schedule'] as List<String>?,
      detailScheduleAlt: parsedDetailAlt['schedule'] as List<String>?,
      detailClasses: parsedDetail['classes'],
      detailClassesAlt: parsedDetailAlt['classes'],
      detailTarget: parsedDetail['target'] as List<String>?,
      detailTargetAlt: parsedDetailAlt['target'] as List<String>?,
      detailExtra: parsedDetail['extra'],
      detailExtraAlt: parsedDetailAlt['extra'],
      selectionStatus: json['xkzt'] as String? ?? '',
      selectionStartTime: json['ktxkkssj'] as String? ?? '',
      selectionEndTime: json['ktxkjssj'] as String? ?? '',
      ugTotal: int.tryParse(json['bksrl']?.toString() ?? '0') ?? 0,
      ugReserved: int.tryParse(json['bksyxrlrs']?.toString() ?? '0') ?? 0,
      pgTotal: int.tryParse(json['yjsrl']?.toString() ?? '0') ?? 0,
      pgReserved: int.tryParse(json['yjsyxrlrs']?.toString() ?? '0') ?? 0,
      maleTotal: json['nansrl'] != null
          ? int.tryParse(json['nansrl'].toString())
          : null,
      maleReserved: json['nansyxrlrs'] != null
          ? int.tryParse(json['nansyxrlrs'].toString())
          : null,
      femaleTotal: json['nvsrl'] != null
          ? int.tryParse(json['nvsrl'].toString())
          : null,
      femaleReserved: json['nvsyxrlrs'] != null
          ? int.tryParse(json['nvsyxrlrs'].toString())
          : null,
    );
  }

  static Map<String, dynamic> _parseDetailHtml(String? html) {
    if (html == null || html.isEmpty) {
      return {
        'teacherId': null,
        'teacherName': null,
        'schedule': null,
        'classes': null,
        'target': null,
        'extra': null,
      };
    }

    String? teacherId;
    String? teacherName;
    List<String>? schedule;
    String? classes;
    List<String>? target;
    String? extra;

    try {
      // teacherId and teacherName
      if (html.contains('queryJsxx')) {
        final start = html.indexOf("queryJsxx('") + 12;
        if (start > 11) {
          final end = html.indexOf("')", start);
          if (end > start) {
            teacherId = html.substring(start, end);
          }
        }

        final nameStart = html.indexOf('>', html.indexOf('queryJsxx')) + 1;
        if (nameStart > 0) {
          final nameEnd = html.indexOf('</a>', nameStart);
          if (nameEnd > nameStart) {
            final rawName = html.substring(nameStart, nameEnd).trim();
            teacherName = _cleanHtmlContent(rawName);
          }
        }
      }

      // schedule: .ivu-tag-cyan p
      if (html.contains('ivu-tag-cyan')) {
        final cyanStart = html.indexOf('ivu-tag-cyan');
        final spanStart = html.indexOf('<span', cyanStart);
        if (spanStart > 0) {
          final spanContentStart = html.indexOf('>', spanStart) + 1;
          final spanEnd = html.indexOf('</span>', spanContentStart);
          if (spanEnd > spanContentStart) {
            final spanContent = html.substring(spanContentStart, spanEnd);
            final scheduleList = <String>[];

            int searchStart = 0;
            while (true) {
              final pStart = spanContent.indexOf('<p>', searchStart);
              if (pStart == -1) break;

              final pEnd = spanContent.indexOf('</p>', pStart);
              if (pEnd == -1) break;

              final pContent = spanContent.substring(pStart + 3, pEnd).trim();
              final cleanedContent = _cleanHtmlContent(pContent);
              if (cleanedContent != null && cleanedContent.isNotEmpty) {
                scheduleList.add(cleanedContent);
              }

              searchStart = pEnd + 4;
            }

            if (scheduleList.isNotEmpty) {
              schedule = scheduleList;
            }
          }
        }
      }

      // classes: .ivu-tag-green p
      if (html.contains('ivu-tag-green')) {
        final greenStart = html.indexOf('ivu-tag-green');
        final pStart = html.indexOf('<p', greenStart);
        if (pStart > 0) {
          final contentStart = html.indexOf('>', pStart) + 1;
          final contentEnd = html.indexOf('</p>', contentStart);
          if (contentEnd > contentStart) {
            final rawClasses = html.substring(contentStart, contentEnd).trim();
            classes = _cleanHtmlContent(rawClasses);
          }
        }
      }

      // target: .ivu-tag-orange
      final targetList = <String>[];
      int searchStart = 0;
      while (true) {
        final orangeStart = html.indexOf('ivu-tag-orange', searchStart);
        if (orangeStart == -1) break;

        final tagStart = html.lastIndexOf('<div', orangeStart);
        if (tagStart != -1) {
          final tagEnd = html.indexOf('</div>', orangeStart);
          if (tagEnd != -1) {
            final tagContent = html.substring(tagStart, tagEnd);
            final contentStart = tagContent.lastIndexOf('>') + 1;
            if (contentStart > 0) {
              final rawTarget = tagContent.substring(contentStart).trim();
              final cleanedTarget = _cleanHtmlContent(rawTarget);
              if (cleanedTarget != null && cleanedTarget.isNotEmpty) {
                targetList.add(cleanedTarget);
              }
            }
          }
        }

        searchStart = orangeStart + 14; // len of "ivu-tag-orange"
      }

      if (targetList.isNotEmpty) {
        target = targetList;
      }

      // extra: last <p> content if valid
      final lastPStart = html.lastIndexOf('<p>');
      if (lastPStart > 0) {
        final lastPEnd = html.indexOf('</p>', lastPStart);
        if (lastPEnd > lastPStart) {
          final rawText = html.substring(lastPStart + 3, lastPEnd).trim();
          if (rawText.isNotEmpty &&
              !rawText.contains('queryJsxx') &&
              !rawText.contains('上课信息') &&
              !rawText.contains('Class Information') &&
              !rawText.contains('面向对象')) {
            extra = _cleanHtmlContent(rawText);
          }
        }
      }
    } catch (e) {
      // ignored
    }

    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'schedule': schedule,
      'classes': classes,
      'target': target,
      'extra': extra,
    };
  }

  static String? _cleanHtmlContent(String? content) {
    if (content == null || content.isEmpty) {
      return null;
    }
    String cleaned = content
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty ||
        cleaned == '&nbsp;' ||
        cleaned == ' ' ||
        RegExp(r'^[\s\u00A0]*$').hasMatch(cleaned)) {
      return null;
    }
    return cleaned;
  }

  bool get hasUg => ugTotal > 0;

  bool get hasPg => pgTotal > 0;

  bool get hasMale => (maleTotal ?? 0) > 0;

  bool get hasFemale => (femaleTotal ?? 0) > 0;

  bool get isAllFull {
    bool hasSomeCapacity = false;
    bool allCapacitiesFull = true;

    if (hasUg) {
      hasSomeCapacity = true;
      if (ugReserved < ugTotal) {
        allCapacitiesFull = false;
      }
    }

    if (hasPg) {
      hasSomeCapacity = true;
      if (pgReserved < pgTotal) {
        allCapacitiesFull = false;
      }
    }

    if (hasMale) {
      hasSomeCapacity = true;
      if ((maleReserved ?? 0) < (maleTotal ?? 0)) {
        allCapacitiesFull = false;
      }
    }

    if (hasFemale) {
      hasSomeCapacity = true;
      if ((femaleReserved ?? 0) < (femaleTotal ?? 0)) {
        allCapacitiesFull = false;
      }
    }

    return hasSomeCapacity && allCapacitiesFull;
  }
}

class CourseInfo extends BaseDataClass {
  final String courseId; // 课程代码
  final String courseName; // 课程名称
  final String? courseNameAlt; // 课程名称英文
  final String courseType; // 课程限制类型
  final String? courseTypeAlt; // 课程限制类型英文
  final String courseCategory; // 课程类别
  final String? courseCategoryAlt; // 课程类别英文
  final String districtName; // 校区名称
  final String? districtNameAlt; // 校区名称英文
  final String schoolName; // 开课院系名称
  final String? schoolNameAlt; // 开课院系名称英文
  final String termName; // 学年学期
  final String? termNameAlt; // 学年学期英文
  final String teachingLanguage; // 授课语言
  final String? teachingLanguageAlt; // 授课语言英文
  final double credits; // 学分
  final double hours; // 学时
  final CourseDetail? classDetail; // 讲台详情
  final String? fromTabId; // 来源标签页ID

  const CourseInfo({
    required this.courseId,
    required this.courseName,
    this.courseNameAlt,
    required this.courseType,
    this.courseTypeAlt,
    required this.courseCategory,
    this.courseCategoryAlt,
    required this.districtName,
    this.districtNameAlt,
    required this.schoolName,
    this.schoolNameAlt,
    required this.termName,
    this.termNameAlt,
    required this.teachingLanguage,
    this.teachingLanguageAlt,
    required this.credits,
    required this.hours,
    this.classDetail,
    this.fromTabId,
  });

  @override
  Map<String, dynamic> getEssentials() {
    return {'courseId': courseId, 'classDetail': classDetail?.classId};
  }

  factory CourseInfo.fromJson(Map<String, dynamic> json, {String? fromTabId}) {
    // Check if id is present and valid
    CourseDetail? classDetail;
    if (json['id'] != null && json['id'].toString().isNotEmpty) {
      classDetail = CourseDetail.fromJson(json);
    }

    return CourseInfo(
      courseId: json['kcdm'] as String? ?? '',
      courseName: json['kcmc'] as String? ?? '',
      courseNameAlt: json['kcmc_en'] as String?,
      courseType: json['kcxzmc'] as String? ?? '',
      courseTypeAlt: json['kcxzmc_en'] as String?,
      courseCategory: json['kclbmc'] as String? ?? '',
      courseCategoryAlt: json['kclbmc_en'] as String?,
      districtName: json['xiaoqumc'] as String? ?? '',
      districtNameAlt: json['xiaoqumc_en'] as String?,
      schoolName: json['kkyxmc'] as String? ?? '',
      schoolNameAlt: json['kkyxmc_en'] as String?,
      termName: json['xnxqmc'] as String? ?? '',
      termNameAlt: json['xnxqmc_en'] as String?,
      teachingLanguage: json['skyymc'] as String? ?? '',
      teachingLanguageAlt: json['skyymc_en'] as String?,
      credits: double.tryParse(json['xf']?.toString() ?? '0') ?? 0.0,
      hours:
          double.tryParse(
            json['zxs']?.toString() ?? json['xs']?.toString() ?? '0',
          ) ??
          0.0,
      classDetail: classDetail,
      fromTabId: fromTabId,
    );
  }
}

class CourseTab extends BaseDataClass {
  final String tabId; // 选课标签页代码
  final String tabName; // 标签页名称
  final String? tabNameAlt; // 标签页名称英文
  final String? selectionStartTime; // 选课开始时间
  final String? selectionEndTime; // 选课结束时间

  const CourseTab({
    required this.tabId,
    required this.tabName,
    this.tabNameAlt,
    this.selectionStartTime,
    this.selectionEndTime,
  });

  @override
  Map<String, dynamic> getEssentials() {
    return {'tabId': tabId};
  }

  factory CourseTab.fromJson(Map<String, dynamic> json) {
    return CourseTab(
      tabId: json['xkfsdm'] as String? ?? '',
      tabName: json['xkfsmc'] as String? ?? '',
      tabNameAlt: json['xkfsmc_en'] as String?,
      selectionStartTime: json['ktxkkssj'] as String?,
      selectionEndTime: json['ktxkjssj'] as String?,
    );
  }
}

class CourseSelectionState extends BaseDataClass {
  final TermInfo? termInfo;
  final List<CourseInfo> wantedCourses;

  const CourseSelectionState({this.termInfo, this.wantedCourses = const []});

  @override
  Map<String, dynamic> getEssentials() {
    return {
      'termInfo': termInfo?.toString(),
      'wantedCoursesCount': wantedCourses.length,
    };
  }

  CourseSelectionState addCourse(CourseInfo course) {
    if (wantedCourses.any(
      (c) =>
          c.courseId == course.courseId &&
          c.classDetail?.classId == course.classDetail?.classId,
    )) {
      // Do nothing
      return this;
    }
    return CourseSelectionState(
      termInfo: termInfo,
      wantedCourses: [...wantedCourses, course],
    );
  }

  CourseSelectionState removeCourse(String courseId, [String? classId]) {
    return CourseSelectionState(
      termInfo: termInfo,
      wantedCourses: wantedCourses
          .where(
            (c) =>
                !(c.courseId == courseId &&
                    (classId == null || c.classDetail?.classId == classId)),
          )
          .toList(),
    );
  }

  CourseSelectionState setTermInfo(TermInfo termInfo) {
    return CourseSelectionState(
      termInfo: termInfo,
      wantedCourses: wantedCourses,
    );
  }

  CourseSelectionState clear() {
    return const CourseSelectionState();
  }

  bool containsCourse(String courseId, [String? classId]) {
    return wantedCourses.any(
      (c) =>
          c.courseId == courseId &&
          (classId == null || c.classDetail?.classId == classId),
    );
  }
}
