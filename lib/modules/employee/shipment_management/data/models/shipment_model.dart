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
        'items': items.map((item) => {
              'itemId': item.id,
              'name': item.name,
              'quantity': item.quantity,
              'price': item.price,
              'code': item.code,
            }).toList(),
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
        supplierId: map['supplierId'] as String,
        items: (map['items'] as List<dynamic>)
            .map((item) => Item(
                  id: item['itemId'] as String,
                  name: item['name'] as String,
                  quantity: item['quantity'] as int,
                  cost: (item['price'] is int)
                      ? (item['price'] as int).toDouble()
                      : item['price'] as double,
                  timeAdded: DateTime.now(), // Not stored in shipment
                  code: item['code'] as String?,
                ))
            .toList(),
        paymentMethod: map['paymentMethod'] as String,
        totalAmount: (map['totalAmount'] is int)
            ? (map['totalAmount'] as int).toDouble()
            : map['totalAmount'] as double,
        paidAmount: (map['paidAmount'] is int)
            ? (map['paidAmount'] as int).toDouble()
            : map['paidAmount'] as double,
        date: (map['date'] as Timestamp).toDate(),
        notes: map['notes'] as String?,
      );
}