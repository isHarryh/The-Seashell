import 'package:flutter/foundation.dart';
import '/services/courses/base.dart';
import '/services/courses/ustb_byyt_mock.dart';

class ServiceProvider extends ChangeNotifier {
  static final ServiceProvider _instance = ServiceProvider._internal();

  BaseCoursesService? _coursesService;

  ServiceProvider._internal();

  factory ServiceProvider() => _instance;

  static ServiceProvider get instance => _instance;

  BaseCoursesService get coursesService {
    _coursesService ??= UstbByytMorkService();
    return _coursesService!;
  }

  void clearCache() {
    _coursesService = null;
    notifyListeners();
  }

  Future<void> loginToService() async {
    await coursesService.login();
    notifyListeners();
  }

  Future<void> logoutFromService() async {
    await coursesService.logout();
    notifyListeners();
  }
}
