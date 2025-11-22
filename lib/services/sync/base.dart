import '/services/base.dart';
import '/types/sync.dart';

abstract class BaseSyncService extends BaseService {
  /// Registers a new device and get a unique device ID.
  Future<String> registerDevice({
    required String deviceOs,
    required String deviceName,
  });

  /// Creates a new sync group.
  Future<String> createGroup({
    required String deviceId,
    required String byytCookie,
  });

  /// Opens pairing mode and get a pair code.
  Future<PairingInfo> openPairing({
    required String deviceId,
    required String groupId,
  });

  /// Makes the pair code deleted immediately.
  Future<void> closePairing({
    required String pairCode,
    required String groupId,
  });

  /// Gets normal devices that have joined the sync group.
  Future<List<DeviceInfo>> listDevices({
    required String groupId,
    String? deviceId,
  });

  /// Joins a sync group using the given pair code.
  Future<JoinGroupResult> joinGroup({
    required String deviceId,
    required String pairCode,
  });

  /// Removes the given device from a sync group.
  Future<void> leaveGroup({required String deviceId, required String groupId});
}
