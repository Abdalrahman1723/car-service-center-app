import 'package:m_world/shared/models/item.dart';

// Shipment entity for domain layer
class ShipmentEntity {
  final String id;
  final String supplierId;
  final List<Item> items;
  final String paymentMethod;
  final double totalAmount;
  final double paidAmount;
  final DateTime date;
  final String? notes;

  ShipmentEntity({
    required this.id,
    required this.supplierId,
    required this.items,
    required this.paymentMethod,
    required this.totalAmount,
    required this.paidAmount,
    required this.date,
    this.notes,
  });
}