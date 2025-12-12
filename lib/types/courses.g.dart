// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) =>
    UserInfo(
        userName: json['userName'] as String,
        userNameAlt: json['userNameAlt'] as String,
        userSchool: json['userSchool'] as String,
        userSchoolAlt: json['userSchoolAlt'] as String,
        userId: json['userId'] as String,
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
    instance.$lastUpdateTime,
    const UTCConverter().toJson,
  ),
  'userName': instance.userName,
  'userNameAlt': instance.userNameAlt,
  'userSchool': instance.userSchool,
  'userSchoolAlt': instance.userSchoolAlt,
  'userId': instance.userId,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

UserLoginIntegratedData _$UserLoginIntegratedDataFromJson(
  Map<String, dynamic> json,
) =>
    UserLoginIntegratedData(
        user: json['user'] == null
            ? null
            : UserInfo.fromJson(json['user'] as Map<String, dynamic>),
        method: json['method'] as String?,
        cookie: json['cookie'] as String?,
        lastSmsPhone: json['lastSmsPhone'] as String?,
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$UserLoginIntegratedDataToJson(
  UserLoginIntegratedData instance,
) => <String, dynamic>{
  r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
    instance.$lastUpdateTime,
    const UTCConverter().toJson,
  ),
  'user': instance.user,
  'method': instance.method,
  'cookie': instance.cookie,
  'lastSmsPhone': instance.lastSmsPhone,
};

CourseGradeItem _$CourseGradeItemFromJson(Map<String, dynamic> json) =>
    CourseGradeItem(
        courseId: json['courseId'] as String,
        courseName: json['courseName'] as String,
        courseNameAlt: json['courseNameAlt'] as String?,
        termId: json['termId'] as String,
        termName: json['termName'] as String,
        termNameAlt: json['termNameAlt'] as String,
        type: json['type'] as String,
        category: json['category'] as String,
        schoolName: json['schoolName'] as String?,
        schoolNameAlt: json['schoolNameAlt'] as String?,
        makeupStatus: json['makeupStatus'] as String?,
        makeupStatusAlt: json['makeupStatusAlt'] as String?,
        examType: json['examType'] as String?,
        hours: (json['hours'] as num).toDouble(),
        credit: (json['credit'] as num).toDouble(),
        score: (json['score'] as num).toDouble(),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$CourseGradeItemToJson(CourseGradeItem instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'courseId': instance.courseId,
      'courseName': instance.courseName,
      'courseNameAlt': instance.courseNameAlt,
      'termId': instance.termId,
      'termName': instance.termName,
      'termNameAlt': instance.termNameAlt,
      'type': instance.type,
      'category': instance.category,
      'schoolName': instance.schoolName,
      'schoolNameAlt': instance.schoolNameAlt,
      'makeupStatus': instance.makeupStatus,
      'makeupStatusAlt': instance.makeupStatusAlt,
      'examType': instance.examType,
      'hours': instance.hours,
      'credit': instance.credit,
      'score': instance.score,
    };

ClassItem _$ClassItemFromJson(Map<String, dynamic> json) =>
    ClassItem(
        day: (json['day'] as num).toInt(),
        period: (json['period'] as num).toInt(),
        weeks: (json['weeks'] as List<dynamic>)
            .map((e) => (e as num).toInt())
            .toList(),
        weeksText: json['weeksText'] as String,
        className: json['className'] as String,
        classNameAlt: json['classNameAlt'] as String?,
        teacherName: json['teacherName'] as String,
        teacherNameAlt: json['teacherNameAlt'] as String?,
        locationName: json['locationName'] as String,
        locationNameAlt: json['locationNameAlt'] as String?,
        periodName: json['periodName'] as String,
        periodNameAlt: json['periodNameAlt'] as String?,
        colorId: (json['colorId'] as num?)?.toInt(),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$ClassItemToJson(ClassItem instance) => <String, dynamic>{
  r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
    instance.$lastUpdateTime,
    const UTCConverter().toJson,
  ),
  'day': instance.day,
  'period': instance.period,
  'weeks': instance.weeks,
  'weeksText': instance.weeksText,
  'className': instance.className,
  'classNameAlt': instance.classNameAlt,
  'teacherName': instance.teacherName,
  'teacherNameAlt': instance.teacherNameAlt,
  'locationName': instance.locationName,
  'locationNameAlt': instance.locationNameAlt,
  'periodName': instance.periodName,
  'periodNameAlt': instance.periodNameAlt,
  'colorId': instance.colorId,
};

ClassPeriod _$ClassPeriodFromJson(Map<String, dynamic> json) =>
    ClassPeriod(
        termYear: json['termYear'] as String,
        termSeason: (json['termSeason'] as num).toInt(),
        majorId: (json['majorId'] as num).toInt(),
        minorId: (json['minorId'] as num).toInt(),
        majorName: json['majorName'] as String,
        minorName: json['minorName'] as String,
        majorStartTime: json['majorStartTime'] as String?,
        majorEndTime: json['majorEndTime'] as String?,
        minorStartTime: json['minorStartTime'] as String,
        minorEndTime: json['minorEndTime'] as String,
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$ClassPeriodToJson(ClassPeriod instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'termYear': instance.termYear,
      'termSeason': instance.termSeason,
      'majorId': instance.majorId,
      'minorId': instance.minorId,
      'majorName': instance.majorName,
      'minorName': instance.minorName,
      'majorStartTime': instance.majorStartTime,
      'majorEndTime': instance.majorEndTime,
      'minorStartTime': instance.minorStartTime,
      'minorEndTime': instance.minorEndTime,
    };

CalendarDay _$CalendarDayFromJson(Map<String, dynamic> json) =>
    CalendarDay(
        year: (json['year'] as num).toInt(),
        month: (json['month'] as num).toInt(),
        day: (json['day'] as num).toInt(),
        weekday: (json['weekday'] as num).toInt(),
        weekIndex: (json['weekIndex'] as num).toInt(),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$CalendarDayToJson(CalendarDay instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
      'weekday': instance.weekday,
      'weekIndex': instance.weekIndex,
    };

TermInfo _$TermInfoFromJson(Map<String, dynamic> json) =>
    TermInfo(
        year: json['year'] as String,
        season: (json['season'] as num).toInt(),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$TermInfoToJson(TermInfo instance) => <String, dynamic>{
  r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
    instance.$lastUpdateTime,
    const UTCConverter().toJson,
  ),
  'year': instance.year,
  'season': instance.season,
};

CurriculumIntegratedData _$CurriculumIntegratedDataFromJson(
  Map<String, dynamic> json,
) =>
    CurriculumIntegratedData(
        currentTerm: TermInfo.fromJson(
          json['currentTerm'] as Map<String, dynamic>,
        ),
        allClasses: (json['allClasses'] as List<dynamic>)
            .map((e) => ClassItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        allPeriods: (json['allPeriods'] as List<dynamic>)
            .map((e) => ClassPeriod.fromJson(e as Map<String, dynamic>))
            .toList(),
        calendarDays: (json['calendarDays'] as List<dynamic>?)
            ?.map((e) => CalendarDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$CurriculumIntegratedDataToJson(
  CurriculumIntegratedData instance,
) => <String, dynamic>{
  r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
    instance.$lastUpdateTime,
    const UTCConverter().toJson,
  ),
  'currentTerm': instance.currentTerm,
  'allClasses': instance.allClasses,
  'allPeriods': instance.allPeriods,
  'calendarDays': instance.calendarDays,
};

CourseDetail _$CourseDetailFromJson(Map<String, dynamic> json) =>
    CourseDetail(
        classId: json['classId'] as String,
        extraName: json['extraName'] as String?,
        extraNameAlt: json['extraNameAlt'] as String?,
        detailHtml: json['detailHtml'] as String?,
        detailHtmlAlt: json['detailHtmlAlt'] as String?,
        detailTeacherId: json['detailTeacherId'] as String?,
        detailTeacherName: json['detailTeacherName'] as String?,
        detailTeacherNameAlt: json['detailTeacherNameAlt'] as String?,
        detailSchedule: (json['detailSchedule'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        detailScheduleAlt: (json['detailScheduleAlt'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        detailClasses: json['detailClasses'] as String?,
        detailClassesAlt: json['detailClassesAlt'] as String?,
        detailTarget: (json['detailTarget'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        detailTargetAlt: (json['detailTargetAlt'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        detailExtra: json['detailExtra'] as String?,
        detailExtraAlt: json['detailExtraAlt'] as String?,
        selectionStatus: json['selectionStatus'] as String,
        selectionStartTime: json['selectionStartTime'] as String,
        selectionEndTime: json['selectionEndTime'] as String,
        ugTotal: (json['ugTotal'] as num).toInt(),
        ugReserved: (json['ugReserved'] as num).toInt(),
        pgTotal: (json['pgTotal'] as num).toInt(),
        pgReserved: (json['pgReserved'] as num).toInt(),
        maleTotal: (json['maleTotal'] as num?)?.toInt(),
        maleReserved: (json['maleReserved'] as num?)?.toInt(),
        femaleTotal: (json['femaleTotal'] as num?)?.toInt(),
        femaleReserved: (json['femaleReserved'] as num?)?.toInt(),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$CourseDetailToJson(CourseDetail instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'classId': instance.classId,
      'extraName': instance.extraName,
      'extraNameAlt': instance.extraNameAlt,
      'selectionStatus': instance.selectionStatus,
      'selectionStartTime': instance.selectionStartTime,
      'selectionEndTime': instance.selectionEndTime,
      'ugTotal': instance.ugTotal,
      'ugReserved': instance.ugReserved,
      'pgTotal': instance.pgTotal,
      'pgReserved': instance.pgReserved,
      'maleTotal': instance.maleTotal,
      'maleReserved': instance.maleReserved,
      'femaleTotal': instance.femaleTotal,
      'femaleReserved': instance.femaleReserved,
      'detailHtml': instance.detailHtml,
      'detailHtmlAlt': instance.detailHtmlAlt,
      'detailTeacherId': instance.detailTeacherId,
      'detailTeacherName': instance.detailTeacherName,
      'detailTeacherNameAlt': instance.detailTeacherNameAlt,
      'detailSchedule': instance.detailSchedule,
      'detailScheduleAlt': instance.detailScheduleAlt,
      'detailClasses': instance.detailClasses,
      'detailClassesAlt': instance.detailClassesAlt,
      'detailTarget': instance.detailTarget,
      'detailTargetAlt': instance.detailTargetAlt,
      'detailExtra': instance.detailExtra,
      'detailExtraAlt': instance.detailExtraAlt,
    };

CourseInfo _$CourseInfoFromJson(Map<String, dynamic> json) =>
    CourseInfo(
        courseId: json['courseId'] as String,
        courseName: json['courseName'] as String,
        courseNameAlt: json['courseNameAlt'] as String?,
        courseType: json['courseType'] as String,
        courseTypeAlt: json['courseTypeAlt'] as String?,
        courseCategory: json['courseCategory'] as String,
        courseCategoryAlt: json['courseCategoryAlt'] as String?,
        districtName: json['districtName'] as String,
        districtNameAlt: json['districtNameAlt'] as String?,
        schoolName: json['schoolName'] as String,
        schoolNameAlt: json['schoolNameAlt'] as String?,
        termName: json['termName'] as String,
        termNameAlt: json['termNameAlt'] as String?,
        teachingLanguage: json['teachingLanguage'] as String,
        teachingLanguageAlt: json['teachingLanguageAlt'] as String?,
        credits: (json['credits'] as num).toDouble(),
        hours: (json['hours'] as num).toDouble(),
        classDetail: json['classDetail'] == null
            ? null
            : CourseDetail.fromJson(
                json['classDetail'] as Map<String, dynamic>,
              ),
        fromTabId: json['fromTabId'] as String?,
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$CourseInfoToJson(CourseInfo instance) =>
    <String, dynamic>{
      r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
        instance.$lastUpdateTime,
        const UTCConverter().toJson,
      ),
      'courseId': instance.courseId,
      'courseName': instance.courseName,
      'courseNameAlt': instance.courseNameAlt,
      'courseType': instance.courseType,
      'courseTypeAlt': instance.courseTypeAlt,
      'courseCategory': instance.courseCategory,
      'courseCategoryAlt': instance.courseCategoryAlt,
      'districtName': instance.districtName,
      'districtNameAlt': instance.districtNameAlt,
      'schoolName': instance.schoolName,
      'schoolNameAlt': instance.schoolNameAlt,
      'termName': instance.termName,
      'termNameAlt': instance.termNameAlt,
      'teachingLanguage': instance.teachingLanguage,
      'teachingLanguageAlt': instance.teachingLanguageAlt,
      'credits': instance.credits,
      'hours': instance.hours,
      'classDetail': instance.classDetail,
      'fromTabId': instance.fromTabId,
    };

CourseTab _$CourseTabFromJson(Map<String, dynamic> json) =>
    CourseTab(
        tabId: json['tabId'] as String,
        tabName: json['tabName'] as String,
        tabNameAlt: json['tabNameAlt'] as String?,
        selectionStartTime: json['selectionStartTime'] as String?,
        selectionEndTime: json['selectionEndTime'] as String?,
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$CourseTabToJson(CourseTab instance) => <String, dynamic>{
  r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
    instance.$lastUpdateTime,
    const UTCConverter().toJson,
  ),
  'tabId': instance.tabId,
  'tabName': instance.tabName,
  'tabNameAlt': instance.tabNameAlt,
  'selectionStartTime': instance.selectionStartTime,
  'selectionEndTime': instance.selectionEndTime,
};

CourseSelectionState _$CourseSelectionStateFromJson(
  Map<String, dynamic> json,
) =>
    CourseSelectionState(
        termInfo: json['termInfo'] == null
            ? null
            : TermInfo.fromJson(json['termInfo'] as Map<String, dynamic>),
        wantedCourses:
            (json['wantedCourses'] as List<dynamic>?)
                ?.map((e) => CourseInfo.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$CourseSelectionStateToJson(
  CourseSelectionState instance,
) => <String, dynamic>{
  r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
    instance.$lastUpdateTime,
    const UTCConverter().toJson,
  ),
  'termInfo': instance.termInfo,
  'wantedCourses': instance.wantedCourses,
};

ExamInfo _$ExamInfoFromJson(Map<String, dynamic> json) =>
    ExamInfo(
        courseId: json['courseId'] as String,
        examRange: json['examRange'] as String,
        examRangeAlt: json['examRangeAlt'] as String?,
        courseName: json['courseName'] as String,
        courseNameAlt: json['courseNameAlt'] as String?,
        termYear: json['termYear'] as String,
        termSeason: (json['termSeason'] as num).toInt(),
        examRoom: json['examRoom'] as String,
        examRoomAlt: json['examRoomAlt'] as String?,
        examBuilding: json['examBuilding'] as String?,
        examBuildingAlt: json['examBuildingAlt'] as String?,
        examWeek: (json['examWeek'] as num).toInt(),
        examDate: DateTime.parse(json['examDate'] as String),
        examDateDisplay: json['examDateDisplay'] as String,
        examDateDisplayAlt: json['examDateDisplayAlt'] as String?,
        examDayName: json['examDayName'] as String,
        examDayNameAlt: json['examDayNameAlt'] as String?,
        examTime: json['examTime'] as String,
        minorId: (json['minorId'] as num).toInt(),
      )
      ..$lastUpdateTime = _$JsonConverterFromJson<String, DateTime>(
        json[r'$lastUpdateTime'],
        const UTCConverter().fromJson,
      );

Map<String, dynamic> _$ExamInfoToJson(ExamInfo instance) => <String, dynamic>{
  r'$lastUpdateTime': _$JsonConverterToJson<String, DateTime>(
    instance.$lastUpdateTime,
    const UTCConverter().toJson,
  ),
  'courseId': instance.courseId,
  'examRange': instance.examRange,
  'examRangeAlt': instance.examRangeAlt,
  'courseName': instance.courseName,
  'courseNameAlt': instance.courseNameAlt,
  'termYear': instance.termYear,
  'termSeason': instance.termSeason,
  'examRoom': instance.examRoom,
  'examRoomAlt': instance.examRoomAlt,
  'examBuilding': instance.examBuilding,
  'examBuildingAlt': instance.examBuildingAlt,
  'examWeek': instance.examWeek,
  'examDate': instance.examDate.toIso8601String(),
  'examDateDisplay': instance.examDateDisplay,
  'examDateDisplayAlt': instance.examDateDisplayAlt,
  'examDayName': instance.examDayName,
  'examDayNameAlt': instance.examDayNameAlt,
  'examTime': instance.examTime,
  'minorId': instance.minorId,
};
