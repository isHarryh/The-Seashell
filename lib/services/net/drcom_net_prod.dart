import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:the_seashell/services/net/drcom_net.dart';
import 'package:the_seashell/types/net.dart';
import '/services/net/base.dart';
import '/services/net/exceptions.dart';

class DrcomNetProdService extends BaseNetService {
  DrcomNetProdService({http.Client? client})
    : _client = client ?? http.Client();

  static const String _baseUrl = 'http://zifuwu.ustb.edu.cn:8080';
  final http.Client _client;
  String? _cookie;

  Map<String, String> _buildHeaders({bool includeFormContentType = false}) {
    final headers = <String, String>{
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
    };
    if (includeFormContentType) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    }
    if (_cookie != null && _cookie!.isNotEmpty) {
      headers['Cookie'] = _cookie!;
    }
    return headers;
  }

  void _updateCookie(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      _cookie = setCookie.split(';').first;
    }
  }

  Uri _buildUri(String path, [Map<String, String>? query]) {
    return Uri.parse('$_baseUrl/$path').replace(queryParameters: query);
  }

  @override
  Future<LoginRequirements> doGetLoginRequirements() async {
    final response = await _client.get(
      _buildUri('nav_login'),
      headers: _buildHeaders(),
    );
    NetServiceException.raiseForStatus(response.statusCode);
    _updateCookie(response);
    return LoginRequirementsExtension.parse(response.body);
  }

  @override
  Future<void> doLogin({
    required String username,
    required String passwordMd5,
    required String checkCode,
    String? extraCode,
  }) async {
    final response = await _client.post(
      _buildUri('LoginAction.action'),
      headers: _buildHeaders(includeFormContentType: true),
      body: {
        'account': username,
        'password': passwordMd5,
        'code': extraCode ?? '',
        'checkcode': checkCode,
        'Submit': 'Login',
      },
    );
    NetServiceException.raiseForStatus(response.statusCode, setOffline);
    _updateCookie(response);
    if (!response.body.contains('class="account"')) {
      throw const NetServiceBadResponse('Unexpected login response');
    }
  }

  @override
  Future<void> doLogout() async {
    final response = await _client.get(
      _buildUri('LogoutAction.action'),
      headers: _buildHeaders(),
    );
    if (response.statusCode >= 400) {
      if (kDebugMode) {
        print('Net service logout failed: ${response.statusCode}');
      }
    }
    _cookie = null;
  }

  @override
  Future<Uint8List> getCodeImage() async {
    final randomNum = Random().nextDouble().toString();
    final response = await _client.get(
      _buildUri('RandomCodeAction.action', {'randomNum': randomNum}),
      headers: _buildHeaders(),
    );
    NetServiceException.raiseForStatus(response.statusCode);
    _updateCookie(response);
    return response.bodyBytes;
  }

  @override
  Future<NetUserInfo> getUser() async {
    if (isOffline) {
      throw const NetServiceOffline();
    }

    try {
      final jsonStr = await _loadUserInfoJson();
      return NetUserInfoExtension.parse(jsonStr);
    } on NetServiceException {
      rethrow;
    } catch (e) {
      throw NetServiceNetworkError('Failed to load net user info', e);
    }
  }

  @override
  Future<void> doRetainMacs(List<String> normalizedMacs) async {
    // Drcom's f**king API only supports passing the MACs you want to retain
    // to archive the effect of unbinding other MACs, LOL. 😝 What a shit!
    final response = await _client.post(
      _buildUri('nav_unbindMACAction.action'),
      headers: _buildHeaders(includeFormContentType: true),
      body: {'macStr': normalizedMacs.join(';'), 'Submit': '解绑'},
    );
    NetServiceException.raiseForStatus(response.statusCode, setOffline);
  }

  @override
  Future<List<MacDevice>> getBoundedMac() async {
    final html = await () async {
      final response = await _client.get(
        _buildUri('nav_unBandMacJsp'),
        headers: _buildHeaders(),
      );
      NetServiceException.raiseForStatus(response.statusCode, setOffline);
      return response.body;
    }();
    return MacDeviceExtension.parse(html);
  }

  Future<Map<String, dynamic>> _loadUserInfoJson({String? macAddress}) async {
    final query = <String, String>{
      't': Random().nextDouble().toStringAsFixed(6),
    };
    if (macAddress != null && macAddress.isNotEmpty) {
      query['macStr'] = macAddress;
    }
    query['Submit'] = '解绑';

    final response = await _client.get(
      _buildUri('refreshaccount', query),
      headers: _buildHeaders(),
    );
    NetServiceException.raiseForStatus(response.statusCode, setOffline);
    _updateCookie(response);
    try {
      final decoded = json.decode(response.body);
      return decoded['note'] as Map<String, dynamic>;
    } catch (e) {
      if (e is NetServiceException) rethrow;
      throw NetServiceBadResponse('Failed to parse user info', e);
    }
  }

  @override
  Future<List<MonthlyBill>> getMonthlyBill({required int year}) async {
    if (year <= 0) {
      throw const NetServiceException('Invalid year');
    }
    if (isOffline) {
      throw const NetServiceOffline();
    }

    try {
      final response = await _client.post(
        _buildUri('MonthPayAction.action'),
        headers: _buildHeaders(includeFormContentType: true),
        body: {'type': '1', 'year': year.toString()},
      );
      NetServiceException.raiseForStatus(response.statusCode, setOffline);
      _updateCookie(response);
      final html = response.body;
      return MonthlyBillExtension.parse(html, year);
    } on NetServiceException {
      rethrow;
    } catch (e) {
      throw NetServiceNetworkError('Failed to load net monthly bill', e);
    }
  }

  void dispose() {
    _client.close();
  }
}
