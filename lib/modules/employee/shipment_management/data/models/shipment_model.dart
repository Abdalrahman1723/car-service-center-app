import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/shared/models/item.dart';
import '../../domain/entities/shipment.dart';

// Shipment model for Firestore serialization
class ShipmentModel {
  final String id;
  final String supplierId;
  final List<Item> items;
  final String paymentMethod;
  final double totalAmount;
  final double paidAmount;
  final DateTime date;
  final String? notes;

  ShipmentModel({
    required this.id,
    required this.supplierId,
    required this.items,
    required this.paymentMethod,
    required this.totalAmount,
    required this.paidAmount,
    required this.date,
    this.notes,
  });

  // Convert to domain entity
  ShipmentEntity toEntity() => ShipmentEntity(
    id: id,
    supplierId: supplierId,
    items: items,
    paymentMethod: paymentMethod,
    totalAmount: totalAmount,
    paidAmount: paidAmount,
    date: date,
    notes: notes,
  );

  // Convert from domain entity
  factory ShipmentModel.fromEntity(ShipmentEntity entity) => ShipmentModel(
    id: entity.id,
    supplierId: entity.supplierId,
    items: entity.items,
    paymentMethod: entity.paymentMethod,
    totalAmount: entity.totalAmount,
    paidAmount: entity.paidAmount,
    date: entity.date,
    notes: entity.notes,
  );

    // Convert to Firestore map
  Map<String, dynamic> toMap() => {
        'id': id,
        'supplierId': supplierId,
        'items': items
            .map(
              (item) => {
                'itemId': item.id,
                'name': item.name,
                'quantity': item.quantity,
                'cost': item.cost, // Changed from 'price' to 'cost'
                'code': item.code,
              },
            )
            .toList(),
        'paymentMethod': paymentMethod,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'date': Timestamp.fromDate(date),
        'notes': notes,
      };

  // Convert from Firestore map
  factory ShipmentModel.fromMap(String id, Map<String, dynamic> map) =>
      ShipmentModel(
        id: id,
        supplierId: map['supplierId'] as String? ?? '',
        items: (map['items'] as List<dynamic>? ?? [])
            .map(
              (item) => Item(
                id: item['itemId'] as String? ?? '',
                name: item['name'] as String? ?? '',
                quantity: item['quantity'] as int? ?? 0,
                cost: _parseDouble(item['cost']), // Changed from 'price' to 'cost'
                timeAdded: DateTime.now(), // Not stored in shipment
                code: item['code'] as String?,
              ),
            )
            .toList(),
        paymentMethod: map['paymentMethod'] as String? ?? 'Cash',
        totalAmount: _parseDouble(map['totalAmount']),
        paidAmount: _parseDouble(map['paidAmount']),
        date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        notes: map['notes'] as String?,
      );

  // Helper method to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }
}
