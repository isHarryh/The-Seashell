import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '/services/base.dart';
import '/services/net/exceptions.dart';
import '/types/net.dart';

abstract class BaseNetService with BaseService {
  LoginRequirements? _cachedLoginRequirements;

  // Methods need to be implemented:

  Future<LoginRequirements> doGetLoginRequirements();

  Future<void> doLogin({
    required String username,
    required String passwordMd5,
    required String checkCode,
    String? extraCode,
  });

  Future<void> doLogout();

  Future<Uint8List> getCodeImage();

  Future<NetUserInfo> getUser();

  Future<void> doRetainMacs(List<String> normalizedMacs);

  Future<List<MacDevice>> getBoundedMac();

  Future<List<MonthlyBill>> getMonthlyBill({required int year});

  Future<void> doChangePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<RealtimeUsage> getRealtimeUsage(
    String username, {
    required bool viaVpn,
  });

  // Methods that already implemented:

  Future<LoginRequirements> getLoginRequirements() async {
    try {
      final requirements = await doGetLoginRequirements();
      _cachedLoginRequirements = requirements;
      return requirements;
    } on NetServiceException {
      rethrow;
    } catch (e) {
      throw NetServiceNetworkError('Failed to load login requirements', e);
    }
  }

  Future<void> loginWithPassword(
    String username,
    String password, {
    String? extraCode,
  }) async {
    try {
      setPending();
      if (_cachedLoginRequirements == null) {
        throw const NetServiceException('Login requirements not initialized');
      }
      if (_cachedLoginRequirements!.isNeedExtraCode &&
          (extraCode == null || extraCode.isEmpty)) {
        throw const NetServiceException('Missing extra code');
      }

      final passwordMd5 = md5.convert(utf8.encode(password)).toString();
      await doLogin(
        username: username,
        passwordMd5: passwordMd5,
        checkCode: _cachedLoginRequirements!.checkCode,
        extraCode: extraCode,
      );
      setOnline();
    } on NetServiceException {
      setOffline();
      rethrow;
    } catch (e) {
      setError(e.toString());
      throw NetServiceNetworkError('Failed to login', e);
    }
  }

  Future<void> logout() async {
    try {
      await doLogout();
    } catch (e) {
      if (kDebugMode) {
        print('Net service logout error: $e');
      }
    } finally {
      _cachedLoginRequirements = null;
      setOffline();
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (isOffline) {
      throw const NetServiceOffline();
    }

    try {
      await doChangePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } on NetServiceException {
      rethrow;
    } catch (e) {
      throw NetServiceNetworkError('Failed to change password', e);
    }
  }

  Future<void> setMacBounded(String mac) async {
    if (isOffline) {
      throw const NetServiceOffline();
    }

    final normalizedMac = normalizeMac(mac);
    if (normalizedMac == null) {
      throw const NetServiceException('Invalid MAC address');
    }

    final allDevices = await getBoundedMac();
    if (allDevices.any(
      (e) => e.mac.toLowerCase() == normalizedMac.toLowerCase(),
    )) {
      // Already bounded
      return;
    }

    final retainMacs = allDevices.map((e) => e.mac.toLowerCase()).toList();
    retainMacs.add(normalizedMac.toLowerCase());
    await doRetainMacs(retainMacs);
  }

  Future<void> setMacUnbounded(String mac) async {
    if (isOffline) {
      throw const NetServiceOffline();
    }

    final normalizedMac = normalizeMac(mac);
    if (normalizedMac == null) {
      throw const NetServiceException('Invalid MAC address');
    }

    final allDevices = await getBoundedMac();
    final retainMacs = allDevices
        .where((e) => e.mac.toLowerCase() != normalizedMac.toLowerCase())
        .map((e) => e.mac.toLowerCase())
        .toList();
    await doRetainMacs(retainMacs);
  }

  @protected
  String? normalizeMac(String raw) {
    final filtered = raw.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toLowerCase();
    if (filtered.length != 12) {
      return null;
    }
    return filtered;
  }
}
