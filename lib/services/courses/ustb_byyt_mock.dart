import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '/types/courses.dart';
import '/services/base.dart';
import '/services/courses/base.dart';
import '/services/courses/exceptions.dart';
import '/services/courses/ustb_byyt.dart';

class UstbByytMockService extends BaseCoursesService {
  CourseSelectionState _selectionState = CourseSelectionState();

  @override
  Future<void> doLogin() async {
    try {
      setPending();
      await Future.delayed(Duration(seconds: 1));
      setOnline();
    } catch (e) {
      if (e.toString().contains('Auth error')) {
        setAuthError('Failed to login: $e');
      } else if (e.toString().contains('Network error')) {
        setNetworkError('Failed to login: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> doLogout() async {
    setPending();
    await Future.delayed(Duration(milliseconds: 500));
    setOffline();
  }

  @override
  Future<bool> doSendHeartbeat() async {
    try {
      if (status == ServiceStatus.offline) {
        return false;
      }

      await Future.delayed(Duration(milliseconds: 500));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/heartbeatSuccess.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (jsonData['code'] == 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserInfo> getUserInfo() async {
    try {
      if (status == ServiceStatus.offline) {
        throw const CourseServiceOffline();
      }

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/me.json',
      );

      return UserInfoUstbByytExtension.parse(json.decode(jsonString));
    } on CourseServiceException {
      rethrow;
    } catch (e) {
      throw CourseServiceNetworkError('Failed to load user info from mock', e);
    }
  }

  @override
  Future<List<CourseGradeItem>> getGrades() async {
    try {
      if (status == ServiceStatus.offline) {
        throw const CourseServiceOffline();
      }
      await Future.delayed(Duration(seconds: 1));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/queryGrade.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (jsonData['code'] != 200) {
        throw CourseServiceBadRequest(
          'Mock API returned error: ${jsonData['msg'] ?? 'Unknown error'}',
          jsonData['code'] as int?,
        );
      }

      final gradeList = jsonData['content']['list'] as List<dynamic>? ?? [];

      return gradeList
          .map(
            (item) => CourseGradeItemUstbByytExtension.parse(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on CourseServiceException {
      rethrow;
    } catch (e) {
      throw CourseServiceNetworkError('Failed to load grades from mock', e);
    }
  }

  @override
  Future<List<ClassItem>> getCurriculum(TermInfo termInfo) async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }
      await Future.delayed(Duration(seconds: 1));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/queryCurriculumPersonal.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      final classList = <ClassItem>[];
      for (final item in jsonData) {
        final classItem = ClassItemUstbByytExtension.parse(
          item as Map<String, dynamic>,
        );
        if (classItem != null) {
          classList.add(classItem);
        }
      }

      return classList;
    } catch (e) {
      throw Exception('Failed to load curriculum: $e');
    }
  }

  @override
  Future<List<ClassPeriod>> getCoursePeriods(TermInfo termInfo) async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }
      await Future.delayed(Duration(seconds: 1));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/queryCoursePeriods.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (jsonData['code'] != 200) {
        throw Exception(
          'API returned error: ${jsonData['msg'] ?? 'Unknown error'}',
        );
      }

      final periodsList = jsonData['content'] as List<dynamic>? ?? [];

      return periodsList
          .map(
            (item) => ClassPeriodUstbByytExtension.parse(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load course periods: $e');
    }
  }

  @override
  Future<List<CalendarDay>> getCalendarDays(TermInfo termInfo) async {
    try {
      if (status == ServiceStatus.offline) {
        throw const CourseServiceOffline();
      }

      await Future.delayed(Duration(milliseconds: 300));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/queryCalendar.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> xlListJson = jsonData['xlList'] as List<dynamic>;
      final List<CalendarDay> calendarDays = xlListJson
          .map(
            (item) => CalendarDayUstbByytExtension.parse(
              item as Map<String, dynamic>,
            ),
          )
          .toList();

      return calendarDays;
    } on CourseServiceException {
      rethrow;
    } catch (e) {
      throw CourseServiceNetworkError(
        'Failed to load calendar days from mock',
        e,
      );
    }
  }

  @override
  Future<List<CourseInfo>> getSelectedCourses(
    TermInfo termInfo, [
    String? tab,
  ]) async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }

      await Future.delayed(Duration(milliseconds: 800));

      String jsonString;
      if (tab != null) {
        jsonString = await rootBundle.loadString(
          'assets/mock/ustb_byyt/queryCourseList[$tab].json',
        );
      } else {
        jsonString = await rootBundle.loadString(
          'assets/mock/ustb_byyt/queryCourseAdded.json',
        );
      }
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Handle different response formats - some mock files don't have code field
      if (jsonData.containsKey('code') && jsonData['code'] != 200) {
        throw Exception(
          'API returned error: ${jsonData['msg'] ?? 'Unknown error'}',
        );
      }

      final courseList = jsonData['yxkcList'] as List<dynamic>? ?? [];

      return courseList.map((courseJson) {
        return CourseInfoUstbByytExtension.parse(
          courseJson as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load selected courses: $e');
    }
  }

  @override
  Future<List<CourseInfo>> getSelectableCourses(
    TermInfo termInfo,
    String tab,
  ) async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }

      await Future.delayed(Duration(milliseconds: 800));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/queryCourseList[$tab].json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final kxrwList = jsonData['kxrwList'] as Map<String, dynamic>?;
      final courseList = kxrwList?['list'] as List<dynamic>? ?? [];

      return courseList.map((courseJson) {
        return CourseInfoUstbByytExtension.parse(
          courseJson as Map<String, dynamic>,
          fromTabId: tab,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load selectable courses: $e');
    }
  }

  @override
  Future<List<CourseTab>> getCourseTabs(TermInfo termInfo) async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }

      await Future.delayed(Duration(milliseconds: 600));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/queryCourseAdded.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final tabList = jsonData['xkgzszList'] as List<dynamic>? ?? [];

      return tabList.map((tabJson) {
        return CourseTabUstbByytExtension.parse(
          tabJson as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load course tabs: $e');
    }
  }

  @override
  Future<List<TermInfo>> getTerms() async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }

      await Future.delayed(Duration(milliseconds: 400));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/queryCourseTerms.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (jsonData['code'] != 200) {
        throw Exception(
          'API returned error: ${jsonData['msg'] ?? 'Unknown error'}',
        );
      }

      final termList = jsonData['content'] as List<dynamic>? ?? [];

      return termList.map((termJson) {
        return TermInfoUstbByytExtension.parse(
          termJson as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load terms: $e');
    }
  }

  @override
  Future<List<CourseInfo>> getCourseDetail(
    TermInfo termInfo,
    CourseInfo courseInfo,
  ) async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }

      await Future.delayed(Duration(milliseconds: 600));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/queryCourseListDetail.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final kxrwList = jsonData['kxrwList'] as Map<String, dynamic>?;
      final courseList = kxrwList?['list'] as List<dynamic>? ?? [];

      // Filter
      List<CourseInfo> results = [];
      for (var courseJson in courseList) {
        try {
          final courseDetail = CourseInfoUstbByytExtension.parse(
            courseJson as Map<String, dynamic>,
            fromTabId: courseInfo.fromTabId,
          );

          if (courseDetail.courseId == courseInfo.courseId &&
              courseDetail.classDetail != null) {
            results.add(courseDetail);
          }
        } catch (e) {
          continue;
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to load course detail: $e');
    }
  }

  @override
  CourseSelectionState getCourseSelectionState() {
    return _selectionState;
  }

  @override
  Future<bool> sendCourseSelection(
    TermInfo termInfo,
    CourseInfo courseInfo,
  ) async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }

      await Future.delayed(
        Duration(milliseconds: 500 + Random().nextInt(3000)),
      );

      final random = Random().nextInt(100);
      if (random < 60) {
        return true;
      } else if (random < 70) {
        throw Exception('课程容量已满');
      } else if (random < 80) {
        throw Exception('未到选课时间');
      } else if (random < 90) {
        throw Exception('选课时间冲突');
      } else {
        await Future.delayed(Duration(seconds: 15)); // Timeout simulation
        throw Exception('超时');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void updateCourseSelectionState(CourseSelectionState state) {
    _selectionState = state;
  }

  @override
  void addCourseToSelection(CourseInfo course) {
    _selectionState = _selectionState.addCourse(course);
  }

  @override
  void removeCourseFromSelection(String courseId, [String? classId]) {
    _selectionState = _selectionState.removeCourse(courseId, classId);
  }

  @override
  void setSelectionTermInfo(TermInfo termInfo) {
    _selectionState = _selectionState.setTermInfo(termInfo);
  }

  @override
  void clearCourseSelection() {
    _selectionState = _selectionState.clear();
  }
}
