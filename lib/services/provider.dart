import 'package:flutter/foundation.dart';
import '/services/courses/base.dart';
import '/services/courses/ustb_byyt_mock.dart';
import '/services/courses/ustb_byyt_prod.dart';
import '/services/courses/exceptions.dart';
import '/services/store/base.dart';
import '/services/store/general.dart';
import '/services/net/base.dart';
import '/services/net/drcom_net_mock.dart';
import '/services/net/drcom_net_prod.dart';
import '/services/sync/base.dart';
import '/services/sync/sync_service_mock.dart';
import '/services/sync/sync_service_prod.dart';
import '/types/courses.dart';

enum CoursesServiceType { mock, production }

enum NetServiceType { mock, production }

enum SyncServiceType { mock, production }

class ServiceProvider extends ChangeNotifier {
  // Course Service
  late BaseCoursesService _coursesService;
  CoursesServiceType _currentServiceType = kDebugMode
      ? CoursesServiceType.mock
      : CoursesServiceType.production;

  // Net Service
  late BaseNetService _netService;
  NetServiceType _currentNetServiceType = kDebugMode
      ? NetServiceType.mock
      : NetServiceType.production;

  // Sync Service
  late BaseSyncService _syncService;
  SyncServiceType _currentSyncServiceType = kDebugMode
      ? SyncServiceType.mock
      : SyncServiceType.production;

  // Store Service
  late BaseStoreService _storeService;

  // Singleton
  static final ServiceProvider _instance = ServiceProvider._internal();
  static ServiceProvider get instance => _instance;

  ServiceProvider._internal() {
    _coursesService = _currentServiceType == CoursesServiceType.mock
        ? UstbByytMockService()
        : UstbByytProdService();
    _netService = _currentNetServiceType == NetServiceType.mock
        ? DrcomNetMockService()
        : DrcomNetProdService();
    _syncService = _currentSyncServiceType == SyncServiceType.mock
        ? SyncServiceMock()
        : SyncServiceProd();
    _storeService = GeneralStoreService();
  }

  BaseCoursesService get coursesService => _coursesService;

  BaseNetService get netService => _netService;

  NetServiceType get currentNetServiceType => _currentNetServiceType;

  BaseSyncService get syncService => _syncService;

  SyncServiceType get currentSyncServiceType => _currentSyncServiceType;

  BaseStoreService get storeService => _storeService;

  Future<void> initializeServices() async {
    await _storeService.initialize();

    // Try to restore login from cache after store service is initialized
    await _tryAutoLogin();

    // Try to load curriculum data after login
    if (coursesService.isOnline) {
      await _loadCurriculumData();
    }
  }

  /// Switch the courses service to the specified type.
  /// This method provides a unified way to switch between mock and production services.
  void switchCoursesService(CoursesServiceType type) {
    _switchCoursesService(type);
  }

  void _switchCoursesService(CoursesServiceType type) {
    if (_currentServiceType == type) return;

    _coursesService = type == CoursesServiceType.mock
        ? UstbByytMockService()
        : UstbByytProdService();
    _currentServiceType = type;
    notifyListeners();
  }

  void switchNetService(NetServiceType type) {
    _switchNetService(type);
  }

  void _switchNetService(NetServiceType type) {
    if (_currentNetServiceType == type) return;

    _disposeNetService();
    _netService = type == NetServiceType.mock
        ? DrcomNetMockService()
        : DrcomNetProdService();
    _currentNetServiceType = type;
    notifyListeners();
  }

  void switchSyncService(SyncServiceType type) {
    _switchSyncService(type);
  }

  void _switchSyncService(SyncServiceType type) {
    if (_currentSyncServiceType == type) return;

    _syncService = type == SyncServiceType.mock
        ? SyncServiceMock()
        : SyncServiceProd();
    _currentSyncServiceType = type;
    notifyListeners();
  }

  void _disposeNetService() {
    if (_netService is DrcomNetProdService) {
      (_netService as DrcomNetProdService).dispose();
    }
  }

  Future<void> _loadCurriculumData() async {
    try {
      // Check cache
      final cachedData = storeService.getCache<CurriculumIntegratedData>(
        "curriculum_data",
        CurriculumIntegratedData.fromJson,
      );

      if (cachedData == null) {
        // Load fresh curriculum data
        await getCurriculumData();
      }
    } catch (e) {
      // Ignore errors during background loading
    }
  }

  Future<CurriculumIntegratedData?> getCurriculumData([
    TermInfo? termInfo,
  ]) async {
    final cachedData = storeService.getCache<CurriculumIntegratedData>(
      "curriculum_data",
      CurriculumIntegratedData.fromJson,
    );

    if (cachedData != null) {
      return cachedData;
    }

    if (!coursesService.isOnline) {
      return null;
    }

    if (termInfo != null) {
      try {
        return await loadCurriculumForTerm(termInfo);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  Future<CurriculumIntegratedData> loadCurriculumForTerm(
    TermInfo termInfo,
  ) async {
    if (!coursesService.isOnline) {
      throw const CourseServiceOffline();
    }

    final futures = await Future.wait([
      coursesService.getCurriculum(termInfo),
      coursesService.getCoursePeriods(termInfo),
      coursesService
          .getCalendarDays(termInfo)
          .catchError((e) => <CalendarDay>[]),
    ]);

    final classes = futures[0] as List<ClassItem>;
    final periods = futures[1] as List<ClassPeriod>;
    final calendarDays = futures[2] as List<CalendarDay>;

    final integratedData = CurriculumIntegratedData(
      currentTerm: termInfo,
      allClasses: classes,
      allPeriods: periods,
      calendarDays: calendarDays.isEmpty ? null : calendarDays,
    );

    // Cache the data
    storeService.putCache<CurriculumIntegratedData>(
      "curriculum_data",
      integratedData,
    );

    return integratedData;
  }

  //

  Future<void> loginToCoursesService({String? cookie}) async {
    if (_currentServiceType == CoursesServiceType.production) {
      if (cookie == null) {
        throw Exception('Cookie is required for production service login');
      }
      final prodService = coursesService as UstbByytProdService;
      await prodService.loginWithCookie(cookie);
      await prodService.login();
      notifyListeners();
    } else {
      await coursesService.login();
      notifyListeners();
    }
  }

  Future<void> logoutFromCoursesService() async {
    await coursesService.logout();
    notifyListeners();
  }

  //

  Future<void> loginToNetService(
    String username,
    String password, {
    String? extraCode,
  }) async {
    await netService.loginWithPassword(
      username,
      password,
      extraCode: extraCode,
    );
    notifyListeners();
  }

  Future<void> logoutFromNetService() async {
    await netService.logout();
    notifyListeners();
  }

  //

  /// Try to restore login from cache on app startup
  Future<void> _tryAutoLogin() async {
    try {
      final cachedData = _storeService.getCache<UserLoginIntegratedData>(
        "course_account_data",
        UserLoginIntegratedData.fromJson,
      );

      if (cachedData == null) return;

      final data = cachedData;
      final method = data.method;

      if (method == "mock") {
        switchCoursesService(CoursesServiceType.mock);
        await loginToCoursesService();
      } else if (method == "cookie" || method == "sso") {
        if (data.cookie != null && data.user != null) {
          switchCoursesService(CoursesServiceType.production);
          await loginToCoursesService(cookie: data.cookie!);
          // Get new user info and verify consistency
          final newUserInfo = await coursesService.getUserInfo();
          assert(
            newUserInfo == data.user,
            "User info mismatch after auto-login with cached cookie",
          );
        }
      }
      // Other methods: do nothing, remain logged out
    } catch (e) {
      // On any exception, remain logged out, auto-login should be silent
      if (kDebugMode) {
        print('Auto-login failed: $e');
      }
    }
  }

  @override
  void dispose() {
    _disposeNetService();
    super.dispose();
  }
}
