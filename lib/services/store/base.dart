import '/types/base.dart';

abstract class BaseStoreService {
  Future<void> initialize();

  void ensureInitialized();

  // Config: The common data that may be shared across devices.

  bool hasConfigKey(String key);

  bool putConfig<T extends BaseDataClass>(String key, T value);

  T? getConfig<T extends BaseDataClass>(
    String key,
    T Function(Map<String, dynamic>) factory,
  );

  void delConfig(String key);

  void delAllConfig();

  // Pref: The local-only data that is device-specified and should not be shared.

  bool hasPrefKey(String key);

  bool putPref<T extends BaseDataClass>(String key, T value);

  T? getPref<T extends BaseDataClass>(
    String key,
    T Function(Map<String, dynamic>) factory,
  );

  void delPref(String key);

  void delAllPref();

  // Bulk operations
  Map<String, dynamic> getAllConfigs();

  void updateConfigs(Map<String, dynamic> configs);
}
