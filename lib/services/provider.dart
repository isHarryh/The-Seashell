import 'dart:async';
import 'package:flutter/foundation.dart';
import '/services/courses/base.dart';
import '/services/courses/ustb_byyt_mock.dart';
import '/services/courses/ustb_byyt_prod.dart';
import '/services/store/base.dart';
import '/services/store/general.dart';
import '/types/courses.dart';

enum ServiceType { mock, production }

class ServiceProvider extends ChangeNotifier {
  // Course Service
  late BaseCoursesService _coursesService;
  Timer? _heartbeatTimer;
  ServiceType _currentServiceType = ServiceType.mock;

  // Store Service
  late BaseStoreService _storeService;

  // Singleton
  static final ServiceProvider _instance = ServiceProvider();
  static ServiceProvider get instance => _instance;

  ServiceProvider() {
    _coursesService = _currentServiceType == ServiceType.mock
        ? UstbByytMockService()
        : UstbByytProdService();
    _storeService = GeneralStoreService();

    // Initialize services asynchronously
    _initializeServices();
  }

  /// Initialize services and try auto-login
  Future<void> _initializeServices() async {
    await _storeService.initialize();

    // Try to restore login from cache after store service is initialized
    await _tryAutoLogin();
  }

  BaseCoursesService get coursesService => _coursesService;

  BaseStoreService get storeService => _storeService;

  ServiceType get currentServiceType => _currentServiceType;

  void switchToMockService() {
    if (_currentServiceType != ServiceType.mock) {
      _stopHeartbeat();
      _coursesService = UstbByytMockService();
      _currentServiceType = ServiceType.mock;
      notifyListeners();
    }
  }

  void switchToProductionService() {
    if (_currentServiceType != ServiceType.production) {
      _stopHeartbeat();
      _coursesService = UstbByytProdService();
      _currentServiceType = ServiceType.production;
      notifyListeners();
    }
  }

  //

  Future<void> loginToCoursesService() async {
    await coursesService.login();

    if (coursesService.isOnline) {
      _startHeartbeat();
    }

    notifyListeners();
  }

  Future<void> loginToCoursesServiceWithCookie(String cookie) async {
    if (_currentServiceType == ServiceType.production) {
      final prodService = coursesService as UstbByytProdService;
      await prodService.loginWithCookie(cookie);

      if (coursesService.isOnline) {
        _startHeartbeat();
      }

      notifyListeners();
    } else {
      throw Exception('Cookie login is only available for production service');
    }
  }

  Future<void> logoutFromCoursesService() async {
    _stopHeartbeat();
    await coursesService.logout();
    notifyListeners();
  }

  //

  void _startHeartbeat() {
    _stopHeartbeat();
    _sendHeartbeat();

    _heartbeatTimer = Timer.periodic(
      Duration(seconds: BaseCoursesService.heartbeatInterval),
      (timer) => _sendHeartbeat(),
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _sendHeartbeat() async {
    try {
      if (coursesService.isOnline) {
        final success = await coursesService.sendHeartbeat();
        if (kDebugMode) {
          print('Heartbeat ${success ? 'success' : 'failed'}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Heartbeat error: $e');
      }
    }
  }

  /// Try to restore login from cache on app startup
  Future<void> _tryAutoLogin() async {
    try {
      final cachedData = _storeService.getCache<UserLoginIntegratedData>(
        "course_account_data",
        UserLoginIntegratedData.fromJson,
      );

      if (cachedData.isEmpty) return;

      final data = cachedData.value!;
      final method = data.method;

      if (method == "mock") {
        switchToMockService();
        await loginToCoursesService();
      } else if (method == "cookie" || method == "sso") {
        if (data.cookie != null && data.user != null) {
          switchToProductionService();
          await loginToCoursesServiceWithCookie(data.cookie!);
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
    _stopHeartbeat();
    super.dispose();
  }
}
