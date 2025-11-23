import 'dart:math';
import '/services/sync/base.dart';
import '/types/sync.dart';

class SyncServiceMock extends BaseSyncService {
  static const String mockDeviceId = 'mock_device_001';
  static const String mockGroupId = 'mock_group_001';
  static const String mockDeviceName = 'Mock Device';
  static const String mockDeviceOs = 'windows';

  final Random _random = Random();

  @override
  Future<void> login() async {
    setOnline();
  }

  @override
  Future<void> logout() async {
    setOffline();
  }

  String _generatePairCode() {
    return _random.nextInt(900000).toString().padLeft(6, '0');
  }

  @override
  Future<String> registerDevice({
    required String deviceOs,
    required String deviceName,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    setOnline();
    return mockDeviceId;
  }

  @override
  Future<String> createGroup({
    required String deviceId,
    required String byytCookie,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    return mockGroupId;
  }

  @override
  Future<PairingInfo> openPairing({
    required String deviceId,
    required String groupId,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    return PairingInfo(pairCode: _generatePairCode(), ttl: 60);
  }

  @override
  Future<void> closePairing({
    required String pairCode,
    required String groupId,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Future<List<DeviceInfo>> listDevices({
    required String groupId,
    String? deviceId,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      DeviceInfo(
        deviceId: mockDeviceId,
        deviceOs: mockDeviceOs,
        deviceName: mockDeviceName,
      ),
    ];
  }

  @override
  Future<JoinGroupResult> joinGroup({
    required String deviceId,
    required String pairCode,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    return JoinGroupResult(
      groupId: mockGroupId,
      devices: [
        DeviceInfo(
          deviceId: mockDeviceId,
          deviceOs: mockDeviceOs,
          deviceName: mockDeviceName,
        ),
      ],
    );
  }

  @override
  Future<void> leaveGroup({
    required String deviceId,
    required String groupId,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
  }
}
