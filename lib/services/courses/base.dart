import '/types/courses.dart';
import '/services/base.dart';

abstract class BaseCoursesService extends BaseService {
  Future<UserInfo> getUserInfo();

  Future<List<CourseGradeItem>> getGrades();

  Future<List<ClassItem>> getCurriculum();

  Future<List<ClassPeriod>> getCoursePeriods();
}
