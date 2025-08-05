import 'package:m_world/shared/models/item.dart';

class Inventory {
  final String id;
  final String name;
  final List<Item> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  Inventory({
    required this.id,
    required this.name,
    this.items = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notes,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'name': name,
        'items': items.map((item) => item.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'notes': notes,
      };

  factory Inventory.fromMap(String id, Map<String, dynamic> map) => Inventory(
        id: id,
        name: map['name'] ?? '',
        items: (map['items'] != null && map['items'] is List)
            ? List<Item>.from(
                (map['items'] as List).asMap().entries.map((entry) {
                  final e = entry.value;
                  if (e is Map<String, dynamic>) {
                    // If item has an id field, use it, else use index as id
                    return Item.fromMap(e['id'] ?? entry.key.toString(), e);
                  }
                  return e;
                }),
              )
            : [],
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : DateTime.now(),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'])
            : DateTime.now(),
        notes: map['notes'],
      );
}
