import 'package:json_annotation/json_annotation.dart';

/// A base class for serializable objects.
///
/// Subclasses may use `json_annotation` library for JSON serialization.
abstract class Serializable {
  Serializable();

  Map<String, dynamic> toJson() =>
      throw UnimplementedError('toJson not implemented yet');
}

/// A base class for data classes.
///
/// It provides automatic implementation for `toString`, `==`
/// and `hashCode` methods based on the specified essential fields.
///
/// Note that subclasses should implement the `getEssentials` method.
/// Fields in subclasses should be `final` to ensure immutability.
abstract class BaseDataClass implements Serializable {
  @UTCConverter()
  DateTime? $lastUpdateTime;

  BaseDataClass() : $lastUpdateTime = DateTime.now().toUtc();

  void updateLastUpdateTime() {
    $lastUpdateTime = DateTime.now().toUtc();
  }

  Map<String, dynamic> getEssentials();

  @override
  String toString() {
    final essentials = getEssentials();
    final entries = essentials.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return '$runtimeType($entries)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    final otherEssentials = (other as BaseDataClass).getEssentials();
    final thisEssentials = getEssentials();

    if (thisEssentials.length != otherEssentials.length) return false;

    for (final entry in thisEssentials.entries) {
      if (!otherEssentials.containsKey(entry.key) ||
          otherEssentials[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    final essentials = getEssentials();
    return Object.hashAll(essentials.values);
  }
}

/// A helper class to convert [DateTime] to and from UTC ISO 8601 string in JSON.
///
/// If we upload local time to server, it may cause confusion when
/// devices are in different time zones, so we should convert [DateTime] to UTC.
class UTCConverter implements JsonConverter<DateTime, String> {
  const UTCConverter();

  @override
  DateTime fromJson(String json) {
    return DateTime.parse(json).toUtc().toLocal();
  }

  @override
  String toJson(DateTime object) {
    return object.toUtc().toIso8601String();
  }
}
