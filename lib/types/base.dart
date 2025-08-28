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
