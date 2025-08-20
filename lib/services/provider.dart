import 'dart:async';
import 'package:flutter/foundation.dart';
import '/services/courses/base.dart';
import '/services/courses/ustb_byyt_mock.dart';

class ServiceProvider extends ChangeNotifier {
  static final ServiceProvider _instance = ServiceProvider._internal();

  BaseCoursesService? _coursesService;
  Timer? _heartbeatTimer;

  ServiceProvider._internal();

  factory ServiceProvider() => _instance;

  static ServiceProvider get instance => _instance;

  BaseCoursesService get coursesService {
    _coursesService ??= UstbByytMorkService();
    return _coursesService!;
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
