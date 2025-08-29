import 'dart:convert';

/// A base class for data classes.
///
/// It provides automatic implementation for `toString`, `==`
/// and `hashCode` methods based on the specified essential fields.
///
/// Note that subclasses should implement the `getEssentials` method.
/// Fields in subclasses should be `final` to ensure immutability.
abstract class BaseDataClass {
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

/// A base class for classes that needs to be serialized to and from JSON.
///
/// It provides automatic implementation for `toString`, `==`
/// and `hashCode` methods.
///
/// Note that subclasses should implement the `dump` method and the `load` factory.
/// Fields in subclasses need not to be `final`.
abstract class BaseSerializableClass {
  BaseSerializableClass();

  Map<String, dynamic> dump();

  String dumps() {
    return json.encode(dump());
  }

  factory BaseSerializableClass.load(Map<String, dynamic> data) {
    throw UnimplementedError('Subclasses must implement the load method.');
  }

  factory BaseSerializableClass.loads(String jsonString) {
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return BaseSerializableClass.load(data);
  }

  @override
  String toString() {
    return dumps();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return dumps() == (other as BaseSerializableClass).dumps();
  }

  @override
  int get hashCode {
    return dumps().hashCode;
  }
}
