import 'package:m_world/shared/models/item.dart';

class InventoryEntity {
  final String id;
  final String name;
  final List<Item> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  InventoryEntity({
    required this.id,
    required this.name,
    this.items = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalValue =>
      items.fold(0.0, (sum, item) => sum + (item.cost * item.quantity));

  List<Item> get lowStockItems =>
      items.where((item) => item.quantity <= 10).toList();

  List<Item> get outOfStockItems =>
      items.where((item) => item.quantity == 0).toList();
}
