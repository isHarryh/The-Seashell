import '/types/base.dart';

class CacheHolder<T extends Serializable> extends Serializable {
  T? _value;
  DateTime? _lastUpdateTime;

  CacheHolder([T? initialValue]) {
    if (initialValue != null) {
      update(initialValue);
    }
  }

  void update(T? newValue) {
    _value = newValue;
    _lastUpdateTime = DateTime.now();
  }

  void clear() {
    _value = null;
    _lastUpdateTime = null;
  }

  T? get value => _value;

  DateTime? get lastUpdateTime => _lastUpdateTime;

  Duration? get retentionTime => _lastUpdateTime == null
      ? null
      : DateTime.now().difference(_lastUpdateTime!);

  bool get isEmpty => _lastUpdateTime == null || _value == null;

  bool get isNotEmpty => !isEmpty;

  @override
  Map<String, dynamic> toJson() => {
    'value': _value?.toJson(),
    'lastUpdateTime': _lastUpdateTime?.toIso8601String(),
  };

  static CacheHolder<T> fromJson<T extends Serializable>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) valueFactory,
  ) {
    final valueJson = json['value'];
    final lastUpdateTimeStr = json['lastUpdateTime'] as String?;
    final lastUpdateTime = lastUpdateTimeStr != null
        ? DateTime.parse(lastUpdateTimeStr)
        : null;

    final value = valueJson != null ? valueFactory(valueJson) : null;

    final holder = CacheHolder<T>(value);
    holder._lastUpdateTime = lastUpdateTime;
    return holder;
  }

  @override
  String toString() {
    if (_lastUpdateTime == null) {
      return 'CacheHolder<$T>(value not set)';
    }
    return 'CacheHolder<$T>(value: $_value)';
  }
}
