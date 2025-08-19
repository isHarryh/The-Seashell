import 'dart:convert';
import 'package:flutter/services.dart';
import '/types/courses.dart';
import '/services/base.dart';
import '/services/courses/base.dart';

class UstbByytMorkService extends BaseCoursesService {
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
    } catch (e) {
      setNetworkError('Failed to logout: $e');
      rethrow;
    }
  }
}
