import 'dart:async';
import 'package:flutter/foundation.dart';
import '/services/courses/base.dart';
import '/services/courses/ustb_byyt_mock.dart';
import '/services/courses/ustb_byyt_prod.dart';

enum ServiceType { mock, production }

class ServiceProvider extends ChangeNotifier {
  static final ServiceProvider _instance = ServiceProvider._internal();

  BaseCoursesService? _coursesService;
  Timer? _heartbeatTimer;
  ServiceType _currentServiceType = ServiceType.mock;

  ServiceProvider._internal();

  factory ServiceProvider() => _instance;

  static ServiceProvider get instance => _instance;

  BaseCoursesService get coursesService {
    _coursesService ??= _createService();
    return _coursesService!;
  }

  ServiceType get currentServiceType => _currentServiceType;

  BaseCoursesService _createService() {
    switch (_currentServiceType) {
      case ServiceType.mock:
        return UstbByytMockService();
      case ServiceType.production:
        return UstbByytProdService();
    }
  }

  void switchToMockService() {
    if (_currentServiceType != ServiceType.mock) {
      _stopHeartbeat();
      _coursesService = null;
      _currentServiceType = ServiceType.mock;
      notifyListeners();
    }
  }

  void switchToProductionService() {
    if (_currentServiceType != ServiceType.production) {
      _stopHeartbeat();
      _coursesService = null;
      _currentServiceType = ServiceType.production;
      notifyListeners();
    }
  }

  void clearCache() {
    _stopHeartbeat();
    _coursesService = null;
    notifyListeners();
  }

  Future<void> loginToService() async {
    await coursesService.login();

    if (coursesService.isOnline) {
      _startHeartbeat();
    }

    notifyListeners();
  }

  Future<void> loginWithCookie(String cookie) async {
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

  Future<void> logoutFromService() async {
    _stopHeartbeat();
    await coursesService.logout();
    notifyListeners();
  }

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

  @override
  void dispose() {
    _stopHeartbeat();
    super.dispose();
  }
}
