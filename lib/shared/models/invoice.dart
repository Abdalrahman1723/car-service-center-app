import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/shared/models/item.dart';

class Invoice {
  final String id;
  final String clientId;
  final String maintenanceBy;
  final DateTime issueDate;
  final DateTime createdAt;
  final double amount;
  final List<Item> items;
  final String? notes;
  final bool isPaid;
  final String? paymentMethod;
  final double? discount;
  final String? selectedCar; // Added

  Invoice({
    required this.id,
    required this.clientId,
    required this.maintenanceBy,
    required this.issueDate,
    required this.createdAt,
    required this.amount,
    required this.items,
    this.notes,
    required this.isPaid,
    this.paymentMethod,
    this.discount,
    this.selectedCar,
  });

  factory Invoice.fromFirestore(Map<String, dynamic> data, String id) {
    return Invoice(
      id: id,
      clientId: data['clientId'] ?? '',
      maintenanceBy: data['maintenanceBy'] ?? '',
      createdAt: DateTime.now(),
      issueDate: data['issueDate'] != null
          ? (data['issueDate'] as Timestamp).toDate()
          : DateTime.now(),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => Item.fromMap("", item))
              .toList() ??
          [],
      notes: data['notes'],
      isPaid: data['isPaid'] ?? false,
      paymentMethod: data['paymentMethod'],
      discount: (data['discount'] as num?)?.toDouble(),
      selectedCar: data['selectedCar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'maintenanceBy': maintenanceBy,
      'issueDate': Timestamp.fromDate(issueDate),
      'amount': amount,
      'items': items.map((item) => item.toMap()).toList(),
      'notes': notes,
      'isPaid': isPaid,
      'paymentMethod': paymentMethod,
      'discount': discount,
      'selectedCar': selectedCar,
    };
  }

  factory Invoice.fromMap(String id, Map<String, dynamic> map) => Invoice(
    id: id,
    clientId: map['clientId'],
    amount: map['amount'],
    maintenanceBy: map['maintenanceBy'] ?? '',
    createdAt: map['creatDate'] != null
        ? DateTime.parse(map['creatDate'])
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
    isPaid: map['isPaid'] ?? false,
    paymentMethod: map['paymentMethod'],
    discount: (map['discount'] is int)
        ? (map['discount'] as int).toDouble()
        : map['discount'],
  );
}
