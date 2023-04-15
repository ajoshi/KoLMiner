/// Any consumable that consumes an organ (so not potions, for example)
class OrganConsumable {
  final String id;
  final int size;

  OrganConsumable(this.id, {this.size = 0});

  /// Convert to serial string
  String serialize() {
    return id;
  }

  bool hasSize() {
    // every Organ Consumable MUST have a size
    return (size > 0);
  }

  /// Convert from serialized string
  static OrganConsumable deserialize(String serialized) {
    return OrganConsumable(serialized);
  }
}
