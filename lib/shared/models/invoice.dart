import 'package:m_world/shared/models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  final String id;
  final String clientId;
  final String maintenanceBy;
  final DateTime issueDate;
  final DateTime createdAt;
  final double amount;
  final List<Item> items;
  final String? notes;
  final double serviceFees;
  final bool isPayLater;
  final String? paymentMethod;
  final double? discount;
  final String selectedCar; // Added
  final double? downPayment; // Added for partial payments

  Invoice({
    required this.id,
    required this.clientId,
    required this.maintenanceBy,
    required this.issueDate,
    required this.createdAt,
    required this.amount,
    required this.serviceFees,
    required this.items,
    required this.selectedCar,
    this.notes,
    required this.isPayLater,
    this.paymentMethod,
    this.discount,
    this.downPayment,
  });

  factory Invoice.fromFirestore(Map<String, dynamic> data, String id) {
    return Invoice(
      id: id,
      clientId: data['clientId'] ?? '',
      maintenanceBy: data['maintenanceBy'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      issueDate: data['issueDate'] != null
          ? (data['issueDate'] as Timestamp).toDate()
          : DateTime.now(),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      serviceFees: (data['serviceFees'] as num?)?.toDouble() ?? 0.0,
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => Item.fromMap("", item))
              .toList() ??
          [],
      notes: data['notes'],
      isPayLater: data['isPayLater'] ?? false,
      paymentMethod: data['paymentMethod'],
      discount: (data['discount'] as num?)?.toDouble(),
      selectedCar: data['selectedCar'],
      downPayment: (data['downPayment'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'maintenanceBy': maintenanceBy,
      'createdAt': createdAt.toIso8601String(),
      'issueDate': issueDate.toIso8601String(),
      'amount': amount,
      'items': items.map((item) => item.toMap()).toList(),
      'notes': notes,
      'serviceFees': serviceFees,
      'isPayLater': isPayLater,
      'paymentMethod': paymentMethod,
      'discount': discount,
      'selectedCar': selectedCar,
      'downPayment': downPayment,
    };
  }

  factory Invoice.fromMap(String id, Map<String, dynamic> map) => Invoice(
    id: id,
    clientId: map['clientId'],
    amount: map['amount'],
    serviceFees: (map['serviceFees'] as num?)?.toDouble() ?? 0.0,
    maintenanceBy: map['maintenanceBy'] ?? '',
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : DateTime.now(),
    issueDate: map['issueDate'] != null
        ? DateTime.parse(map['issueDate'])
        : DateTime.now(),
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
    notes: map['notes'],
    isPayLater: map['isPayLater'] ?? false,
    paymentMethod: map['paymentMethod'],
    discount: (map['discount'] is int)
        ? (map['discount'] as int).toDouble()
        : map['discount'],
    selectedCar: map['selectedCar'] ?? '',
    downPayment: (map['downPayment'] as num?)?.toDouble(),
  );
}
