import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:the_seashell/services/net/drcom_net.dart';
import '/services/net/base.dart';
import '/services/net/exceptions.dart';
import '/types/net.dart';

class DrcomNetMockService extends BaseNetService {
  static const String _assetPrefix = 'assets/mock/ustb_net/';

  @override
  Future<LoginRequirements> doGetLoginRequirements() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return LoginRequirementsExtension.parse(
      await rootBundle.loadString('${_assetPrefix}drcom.html'),
    );
  }

  @override
  Future<void> doLogin({
    required String username,
    required String passwordMd5,
    required String checkCode,
    String? extraCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await rootBundle.loadString('${_assetPrefix}drcomLoginSuccess.html');
  }

  @override
  Future<void> doLogout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<Uint8List> getCodeImage() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final data = await rootBundle.load('${_assetPrefix}drcomCheckcode.png');
    return data.buffer.asUint8List();
  }

  @override
  Future<NetUserInfo> getUser() async {
    if (isOffline) {
      throw const NetServiceOffline();
    }

    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final jsonStr = await rootBundle.loadString(
        '${_assetPrefix}drcomUser.json',
      );
      final data = json.decode(jsonStr)['note'] as Map<String, dynamic>;
      return NetUserInfoExtension.parse(data);
    } on NetServiceException {
      rethrow;
    } catch (e) {
      throw NetServiceNetworkError('Failed to load net user info', e);
    }
  }

  @override
  Future<void> doRetainMacs(List<String> normalizedMacs) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await rootBundle.loadString('${_assetPrefix}drcomMacUnbound.html');
  }

  @override
  Future<List<MacDevice>> getBoundedMac() async {
    if (isOffline) {
      throw const NetServiceOffline();
    }

    await Future.delayed(const Duration(milliseconds: 200));
    return MacDeviceExtension.parse(
      await rootBundle.loadString('${_assetPrefix}drcomMac.html'),
    );
  }

  @override
  Future<List<MonthlyBill>> getMonthlyBill({required int year}) async {
    if (year <= 0) {
      throw const NetServiceException('Invalid year');
    }
    if (isOffline) {
      throw const NetServiceOffline();
    }
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final html = await rootBundle.loadString(
        '${DrcomNetMockService._assetPrefix}drcomMonthlyBill.html',
      );
      return MonthlyBillExtension.parse(html, year);
    } on NetServiceException {
      rethrow;
    } catch (e) {
      throw NetServiceNetworkError('Failed to load net monthly bill', e);
    }
  }

  @override
  Future<void> doChangePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock implementation: always succeeds
  }

  @override
  Future<RealtimeUsage> getRealtimeUsage(
    String username, {
    required bool viaVpn,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final jsStr = await rootBundle.loadString(
        '${_assetPrefix}netRealtimeUsage.js',
      );
      return RealtimeUsageExtension.parse(jsStr);
    } on NetServiceException {
      rethrow;
    } catch (e) {
      throw NetServiceNetworkError('Failed to load realtime usage', e);
    }
  }
}
