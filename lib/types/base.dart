/// A base class for serializable objects.
///
/// Subclasses may use `json_annotation` library for JSON serialization.
abstract class Serializable {
  Serializable();

  Map<String, dynamic> toJson() {
    throw UnimplementedError('toJson not implemented yet');
  }

  factory Serializable.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson not implemented yet');
  }
}

/// A base class for data classes.
///
/// It provides automatic implementation for `toString`, `==`
/// and `hashCode` methods based on the specified essential fields.
///
/// Note that subclasses should implement the `getEssentials` method.
/// Fields in subclasses should be `final` to ensure immutability.
abstract class BaseDataClass implements Serializable {
  const BaseDataClass();

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
