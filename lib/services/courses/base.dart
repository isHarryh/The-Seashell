import '/types/courses.dart';
import '/services/base.dart';

abstract class BaseCoursesService extends BaseService {
  static const int heartbeatInterval = 300;

  Future<UserInfo> getUserInfo();

  Future<List<CourseGradeItem>> getGrades();

  Future<List<ClassItem>> getCurriculum();

  Future<List<ClassPeriod>> getCoursePeriods();

  Future<bool> sendHeartbeat();

  DateTime? getLastHeartbeatTime();

  Future<List<CourseInfo>> getSelectedCourses();

  Future<List<CourseInfo>> getSelectableCourses(TermInfo termInfo, String tab);

  Future<List<CourseTab>> getCourseTabs(TermInfo termInfo);

  Future<List<TermInfo>> getTerms();
}
