import 'package:m_world/shared/models/item.dart';

class Invoice {
  final String id;
  final String clientId; //phone number
  final String maintenanceBy; //worker name
  final double amount;
  final DateTime creatDate;
  final DateTime issueDate;
  final List<Item> items;
  final String? notes;
  final bool isPaid;
  final String? paymentMethod; //in a drop down menu
  final double? discount; //as a percentage or amount of money

  Invoice({
    required this.id,
    required this.clientId,
    required this.amount,
    this.maintenanceBy = '',
    DateTime? creatDate,
    DateTime? issueDate,
    this.items = const [],
    this.notes,
    this.isPaid = false,
    this.paymentMethod,
    this.discount,
  }) : creatDate = creatDate ?? DateTime.now(),
       issueDate = issueDate ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'clientId': clientId,
    'amount': amount,
    'maintenanceBy': maintenanceBy,
    'creatDate': creatDate.toIso8601String(),
    'issueDate': issueDate.toIso8601String(),
    'items': items.map((item) => item.toMap()).toList(),
    'notes': notes,
    'isPaid': isPaid,
    'paymentMethod': paymentMethod,
    'discount': discount,
  };

  factory Invoice.fromMap(String id, Map<String, dynamic> map) => Invoice(
    id: id,
    clientId: map['clientId'],
    amount: map['amount'],
    maintenanceBy: map['maintenanceBy'] ?? '',
    creatDate: map['creatDate'] != null
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
