import '/types/base.dart';

abstract class BaseStoreService {
  Future<void> initialize();

  void ensureInitialized();

  bool hasCacheKey(String key);

  bool putCache<T extends BaseDataClass>(String key, T value);

  T? getCache<T extends BaseDataClass>(
    String key,
    T Function(Map<String, dynamic>) factory,
  );

  void removeCache(String key);

  void removeAllCache();

  bool hasPrefKey(String key);

  bool putPref<T extends BaseDataClass>(String key, T value);

  T? getPref<T extends BaseDataClass>(
    String key,
    T Function(Map<String, dynamic>) factory,
  );

  void removePref(String key);

  void removeAllPref();
}
