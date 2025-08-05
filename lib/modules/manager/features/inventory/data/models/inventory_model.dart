import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import 'package:m_world/shared/models/item.dart';

class InventoryModel extends InventoryEntity {
  InventoryModel({
    required super.id,
    required super.name,
    super.items = const [],
    super.createdAt,
    super.updatedAt,
    super.notes,
  });

  factory InventoryModel.fromEntity(InventoryEntity entity) {
    return InventoryModel(
      id: entity.id,
      name: entity.name,
      items: entity.items,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      notes: entity.notes,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'items': items.map((item) => item.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'notes': notes,
  };

  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      items: (map['items'] != null && map['items'] is List)
          ? List<Item>.from(
              (map['items'] as List).asMap().entries.map((entry) {
                final e = entry.value;
                if (e is Map<String, dynamic>) {
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

  InventoryModel copyWith({
    String? id,
    String? name,
    List<Item>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}
