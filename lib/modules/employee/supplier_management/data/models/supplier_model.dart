import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/supplier.dart';

// Supplier model for Firestore serialization
class SupplierModel {
  final String id;
  final String name;
  final String phoneNumber;
  final double balance;
  final String? notes;
  final DateTime createdAt;

  SupplierModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.balance = 0.0,
    this.notes,
    required this.createdAt,
  });

  // Convert to domain entity
  SupplierEntity toEntity() => SupplierEntity(
        id: id,
        name: name,
        phoneNumber: phoneNumber,
        balance: balance,
        notes: notes,
        createdAt: createdAt,
      );

  // Convert from domain entity
  factory SupplierModel.fromEntity(SupplierEntity entity) => SupplierModel(
        id: entity.id,
        name: entity.name,
        phoneNumber: entity.phoneNumber,
        balance: entity.balance,
        notes: entity.notes,
        createdAt: entity.createdAt,
      );

  // Convert to Firestore map
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'balance': balance,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  // Convert from Firestore map
  factory SupplierModel.fromMap(String id, Map<String, dynamic> map) =>
      SupplierModel(
        id: id,
        name: map['name'] as String,
        phoneNumber: map['phoneNumber'] as String,
        balance: (map['balance'] is int)
            ? (map['balance'] as int).toDouble()
            : (map['balance'] as double?) ?? 0.0,
        notes: map['notes'] as String?,
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );
}