import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '/services/base.dart';
import '/services/net/exceptions.dart';
import '/types/net.dart';

abstract class BaseNetService extends BaseService {
  LoginRequirements? _cachedLoginRequirements;

  Future<LoginRequirements> doGetLoginRequirements();

  Future<void> doLogin({
    required String username,
    required String passwordMd5,
    required String checkcode,
  });

  Future<void> doLogout();

  Future<Uint8List> getCheckcodeImage();

  Future<NetUserInfo> getUser();

  Future<void> doRetainMacs(List<String> normalizedMacs);

  Future<List<MacDevice>> getBoundedMac();

  Future<List<MonthlyBill>> getMonthlyBill({required int year});

  Future<LoginRequirements> getLoginRequirements() async {
    if (_cachedLoginRequirements != null) {
      return _cachedLoginRequirements!;
    }

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
    String? checkcode,
  }) async {
    try {
      setPending();
      if (username.isEmpty) {
        throw const NetServiceException('Missing username');
      }
      if (password.isEmpty) {
        throw const NetServiceException('Missing password');
      }

      var effectiveCheckcode = checkcode;
      if (effectiveCheckcode == null || effectiveCheckcode.isEmpty) {
        if (_cachedLoginRequirements == null ||
            _cachedLoginRequirements!.isNeedExtraCheckcode) {
          throw const NetServiceException('Missing extra checkcode');
        }
        effectiveCheckcode = _cachedLoginRequirements!.defaultCheckcode;
      }

      final passwordMd5 = md5.convert(utf8.encode(password)).toString();
      await doLogin(
        username: username,
        passwordMd5: passwordMd5,
        checkcode: effectiveCheckcode,
      );
      setOnline();
    } on NetServiceException {
      setOffline();
      rethrow;
    } catch (e) {
      setNetworkError(e.toString());
      throw NetServiceNetworkError('Failed to login', e);
    }
  }

  @override
  Future<void> login() async {
    throw UnimplementedError('Use loginWithCredential for net service');
  }

  @override
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
