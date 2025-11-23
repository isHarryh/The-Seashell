import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '/types/base.dart';
import 'base.dart';

class GeneralStoreService extends BaseStoreService {
  static const String _cacheDir = 'cache';
  static const String _prefDir = 'pref';

  late final String _rootPath;
  late final Directory _cacheDirectory;
  late final Directory _prefDirectory;

  final Map<String, BaseDataClass> _memoryCache = {};
  final Map<String, BaseDataClass> _memoryPref = {};

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final rootDir = await getApplicationSupportDirectory();
      _rootPath = rootDir.path;

      _cacheDirectory = Directory('$_rootPath/$_cacheDir');
      _prefDirectory = Directory('$_rootPath/$_prefDir');

      await _cacheDirectory.create(recursive: true);
      await _prefDirectory.create(recursive: true);

      _initialized = true;
    } catch (e) {
      _initialized = false;
    }
  }

  @override
  void ensureInitialized() {
    if (!_initialized) {
      throw Exception('Store service is not initialized.');
    }
  }

  String _getCacheFilePath(String key) {
    return '${_cacheDirectory.path}/$key.json';
  }

  String _getPrefFilePath(String key) {
    return '${_prefDirectory.path}/$key.json';
  }

  @override
  bool putCache<T extends BaseDataClass>(String key, T value) {
    ensureInitialized();

    try {
      value.updateLastUpdateTime();

      final jsonData = value.toJson();
      final file = File(_getCacheFilePath(key));
      file.writeAsStringSync(json.encode(jsonData));

      _memoryCache[key] = value;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  T? getCache<T extends BaseDataClass>(
    String key,
    T Function(Map<String, dynamic>) factory,
  ) {
    ensureInitialized();

    try {
      if (_memoryCache.containsKey(key)) {
        return _memoryCache[key] as T;
      }

      final file = File(_getCacheFilePath(key));
      if (!file.existsSync()) {
        return null;
      }

      final content = file.readAsStringSync();
      final jsonData = json.decode(content) as Map<String, dynamic>;
      final value = factory(jsonData);

      _memoryCache[key] = value;
      return value;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> removeCache(String key) async {
    ensureInitialized();

    try {
      final file = File(_getCacheFilePath(key));
      if (file.existsSync()) {
        file.deleteSync();
      }

      _memoryCache.remove(key);
    } catch (e) {
      print('Failed to remove cache for key $key: $e');
    }
  }

  @override
  void removeAllCache() async {
    ensureInitialized();

    try {
      final files = await _cacheDirectory.list().toList();
      for (final file in files) {
        if (file is File) {
          file.deleteSync();
        }
      }

      _memoryCache.clear();
    } catch (e) {
      print('Failed to remove all cache: $e');
    }
  }

  @override
  bool putPref<T extends BaseDataClass>(String key, T value) {
    ensureInitialized();

    try {
      final jsonData = value.toJson();
      final file = File(_getPrefFilePath(key));
      file.writeAsStringSync(json.encode(jsonData));

      _memoryPref[key] = value;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  T? getPref<T extends BaseDataClass>(
    String key,
    T Function(Map<String, dynamic>) factory,
  ) {
    ensureInitialized();

    try {
      if (_memoryPref.containsKey(key)) {
        return _memoryPref[key] as T;
      }

      final file = File(_getPrefFilePath(key));
      if (!file.existsSync()) {
        return null;
      }

      final content = file.readAsStringSync();
      final jsonData = json.decode(content) as Map<String, dynamic>;
      final value = factory(jsonData);

      _memoryPref[key] = value;
      return value;
    } catch (e) {
      return null;
    }
  }

  @override
  void removePref(String key) {
    ensureInitialized();

    try {
      final file = File(_getPrefFilePath(key));
      if (file.existsSync()) {
        file.deleteSync();
      }

      _memoryPref.remove(key);
    } catch (e) {
      print('Failed to remove preference for key $key: $e');
    }
  }

  @override
  void removeAllPref() {
    ensureInitialized();

    try {
      final files = _prefDirectory.listSync().toList();
      for (final file in files) {
        if (file is File) {
          file.delete();
        }
      }

      _memoryPref.clear();
    } catch (e) {
      print('Failed to remove all preferences: $e');
    }
  }

  @override
  bool hasCacheKey(String key) {
    ensureInitialized();

    if (_memoryCache.containsKey(key)) {
      return true;
    }

    final file = File(_getCacheFilePath(key));
    return file.existsSync();
  }

  @override
  bool hasPrefKey(String key) {
    ensureInitialized();

    if (_memoryPref.containsKey(key)) {
      return true;
    }

    final file = File(_getPrefFilePath(key));
    return file.existsSync();
  }
}
