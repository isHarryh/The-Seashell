import 'dart:convert';
import 'package:flutter/services.dart';
import '/types/courses.dart';
import '/services/base.dart';
import '/services/courses/base.dart';

class UstbByytMorkService extends BaseCoursesService {
  DateTime? _lastHeartbeatTime;
  CourseSelectionState _selectionState = const CourseSelectionState();

  @override
  Future<UserInfo> getUserInfo() async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/me.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      return UserInfo(
        userName: jsonData['xm'] as String? ?? '',
        userNameAlt: jsonData['xm_en'] as String? ?? '',
        userSchool: jsonData['bmmc'] as String? ?? '',
        userSchoolAlt: jsonData['bmmc_en'] as String? ?? '',
        userId: jsonData['yhdm'] as String? ?? '',
      );
    } catch (e) {
      setNetworkError('Failed to load user info: $e');
      throw Exception('Failed to load user info: $e');
    }
  }

  @override
  Future<List<CourseGradeItem>> getGrades() async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }
      await Future.delayed(Duration(seconds: 1));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/queryGrade.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (jsonData['code'] != 200) {
        throw Exception(
          'API returned error: ${jsonData['msg'] ?? 'Unknown error'}',
        );
      }

      final List<dynamic> gradeList =
          jsonData['content']['list'] as List<dynamic>? ?? [];

      return gradeList
          .map((item) => CourseGradeItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      setNetworkError('Failed to load grades: $e');
      throw Exception('Failed to load grades: $e');
    }
  }

  @override
  Future<List<ClassItem>> getCurriculum() async {
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
        final classItem = ClassItem.fromJson(item as Map<String, dynamic>);
        if (classItem != null) {
          classList.add(classItem);
        }
      }

      return classList;
    } catch (e) {
      setNetworkError('Failed to load curriculum: $e');
      throw Exception('Failed to load curriculum: $e');
    }
  }

  @override
  Future<List<ClassPeriod>> getCoursePeriods() async {
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

      final List<dynamic> periodsList =
          jsonData['content'] as List<dynamic>? ?? [];

      return periodsList
          .map((item) => ClassPeriod.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      setNetworkError('Failed to load course periods: $e');
      throw Exception('Failed to load course periods: $e');
    }
  }

  @override
  Future<void> login() async {
    try {
      setPending();
      await Future.delayed(Duration(seconds: 2));
      final rand = DateTime.now().microsecond;
      if (rand < 100) {
        setAuthError('Auth error occurred');
        throw Exception('Auth error occurred');
      } else if (rand < 200) {
        setNetworkError('Network error occurred');
        throw Exception('Network error occurred');
      }
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
  Future<void> logout() async {
    try {
      setPending();
      await Future.delayed(Duration(seconds: 1));
      setOffline();
      _lastHeartbeatTime = null;
    } catch (e) {
      setNetworkError('Failed to logout: $e');
      rethrow;
    }
  }

  @override
  Future<bool> sendHeartbeat() async {
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
        _lastHeartbeatTime = DateTime.now();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  DateTime? getLastHeartbeatTime() {
    return _lastHeartbeatTime;
  }

  @override
  Future<List<CourseInfo>> getSelectedCourses() async {
    try {
      if (status == ServiceStatus.offline) {
        throw Exception('Not logged in');
      }

      await Future.delayed(Duration(milliseconds: 800));

      final String jsonString = await rootBundle.loadString(
        'assets/mock/ustb_byyt/queryCourseAdded.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (jsonData['code'] != 200) {
        throw Exception(
          'API returned error: ${jsonData['msg'] ?? 'Unknown error'}',
        );
      }

      final List<dynamic> courseList =
          jsonData['yxkcList'] as List<dynamic>? ?? [];

      return courseList.map((courseJson) {
        return CourseInfo.fromJson(courseJson as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      setNetworkError('Failed to load selected courses: $e');
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

      final Map<String, dynamic>? kxrwList =
          jsonData['kxrwList'] as Map<String, dynamic>?;
      final List<dynamic> courseList =
          kxrwList?['list'] as List<dynamic>? ?? [];

      return courseList.map((courseJson) {
        return CourseInfo.fromJson(courseJson as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      setNetworkError('Failed to load selectable courses: $e');
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

      final List<dynamic> tabList =
          jsonData['xkgzszList'] as List<dynamic>? ?? [];

      return tabList.map((tabJson) {
        return CourseTab.fromJson(tabJson as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      setNetworkError('Failed to load course tabs: $e');
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

      final List<dynamic> termList =
          jsonData['content'] as List<dynamic>? ?? [];

      return termList.map((termJson) {
        return TermInfo.fromJson(termJson as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      setNetworkError('Failed to load terms: $e');
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

      final Map<String, dynamic>? kxrwList =
          jsonData['kxrwList'] as Map<String, dynamic>?;
      final List<dynamic> courseList =
          kxrwList?['list'] as List<dynamic>? ?? [];

      // Filter
      List<CourseInfo> results = [];
      for (var courseJson in courseList) {
        try {
          final courseDetail = CourseInfo.fromJson(
            courseJson as Map<String, dynamic>,
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
      setNetworkError('Failed to load course detail: $e');
      throw Exception('Failed to load course detail: $e');
    }
  }

  @override
  CourseSelectionState getCourseSelectionState() {
    return _selectionState;
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
