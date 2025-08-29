import '/types/base.dart';
import '/types/caching.dart';

abstract class BaseStoreService {
  Future<void> initialize();

  void ensureInitialized();

  bool hasCacheKey(String key);

  bool putCache<T extends Serializable>(String key, T value);

  CacheHolder<T> getCache<T extends Serializable>(String key, Function factory);

  void removeCache(String key);

  void removeAllCache();

  bool hasPrefKey(String key);

  bool putPref<T extends Serializable>(String key, T value);

  T? getPref<T extends Serializable>(String key, Function factory);

  void removePref(String key);

  void removeAllPref();
}
