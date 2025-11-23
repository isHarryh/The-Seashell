import '/types/base.dart';

abstract class BaseStoreService {
  Future<void> initialize();

  void ensureInitialized();

  // Store: The common data that may be shared across devices.

  bool hasStoreKey(String key);

  bool putStore<T extends BaseDataClass>(String key, T value);

  T? getStore<T extends BaseDataClass>(
    String key,
    T Function(Map<String, dynamic>) factory,
  );

  void delStore(String key);

  void delAllStore();

  // Pref: The local-only data that is device-specified and should not be shared.

  bool hasPrefKey(String key);

  bool putPref<T extends BaseDataClass>(String key, T value);

  T? getPref<T extends BaseDataClass>(
    String key,
    T Function(Map<String, dynamic>) factory,
  );

  void delPref(String key);

  void delAllPref();
}
