import 'package:equatable/equatable.dart';

enum DebtTransactionType {
  clientPayment, // Client pays money to us (reduces their debt)
  clientReceipt, // We receive money from client (reduces their debt)
  supplierPayment, // We pay money to supplier (reduces our debt to them)
  supplierReceipt, // Supplier receives money from us (reduces our debt to them)
}

enum DebtTransactionStatus { pending, completed, cancelled }

class DebtTransaction extends Equatable {
  final String? id;
  final String entityId; // Client ID or Supplier ID
  final String entityName; // Client name or Supplier name
  final String entityType; // 'client' or 'supplier'
  final DebtTransactionType type;
  final double amount;
  final double previousBalance;
  final double newBalance;
  final DateTime date;
  final String? notes;
  final DebtTransactionStatus status;
  final String? vaultTransactionId; // Reference to vault transaction

  const DebtTransaction({
    this.id,
    required this.entityId,
    required this.entityName,
    required this.entityType,
    required this.type,
    required this.amount,
    required this.previousBalance,
    required this.newBalance,
    required this.date,
    this.notes,
    this.status = DebtTransactionStatus.completed,
    this.vaultTransactionId,
  });

  @override
  List<Object?> get props => [
    id,
    entityId,
    entityName,
    entityType,
    type,
    amount,
    previousBalance,
    newBalance,
    date,
    notes,
    status,
    vaultTransactionId,
  ];

  Map<String, dynamic> toMap() => {
    'id': id,
    'entityId': entityId,
    'entityName': entityName,
    'entityType': entityType,
    'type': type.name,
    'amount': amount,
    'previousBalance': previousBalance,
    'newBalance': newBalance,
    'date': date.toIso8601String(),
    'notes': notes,
    'status': status.name,
    'vaultTransactionId': vaultTransactionId,
  };

  factory DebtTransaction.fromMap(String id, Map<String, dynamic> map) {
    return DebtTransaction(
      id: id,
      entityId: map['entityId'] ?? '',
      entityName: map['entityName'] ?? '',
      entityType: map['entityType'] ?? '',
      type: DebtTransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DebtTransactionType.clientPayment,
      ),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      previousBalance: (map['previousBalance'] as num?)?.toDouble() ?? 0.0,
      newBalance: (map['newBalance'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      notes: map['notes'],
      status: DebtTransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DebtTransactionStatus.completed,
      ),
      vaultTransactionId: map['vaultTransactionId'],
    );
  }

  DebtTransaction copyWith({
    String? id,
    String? entityId,
    String? entityName,
    String? entityType,
    DebtTransactionType? type,
    double? amount,
    double? previousBalance,
    double? newBalance,
    DateTime? date,
    String? notes,
    DebtTransactionStatus? status,
    String? vaultTransactionId,
  }) {
    return DebtTransaction(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityName: entityName ?? this.entityName,
      entityType: entityType ?? this.entityType,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      previousBalance: previousBalance ?? this.previousBalance,
      newBalance: newBalance ?? this.newBalance,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      vaultTransactionId: vaultTransactionId ?? this.vaultTransactionId,
    );
  }

  // Helper methods
  bool get isClientTransaction => entityType == 'client';
  bool get isSupplierTransaction => entityType == 'supplier';
  bool get isPayment =>
      type == DebtTransactionType.clientPayment ||
      type == DebtTransactionType.supplierPayment;
  bool get isReceipt =>
      type == DebtTransactionType.clientReceipt ||
      type == DebtTransactionType.supplierReceipt;

  // Get the vault transaction type for this debt transaction
  String get vaultTransactionType {
    switch (type) {
      case DebtTransactionType.clientPayment:
      case DebtTransactionType.clientReceipt:
        return 'income'; // We receive money
      case DebtTransactionType.supplierPayment:
      case DebtTransactionType.supplierReceipt:
        return 'expense'; // We pay money
    }
  }

  // Get the vault transaction category
  String get vaultTransactionCategory {
    switch (type) {
      case DebtTransactionType.clientPayment:
      case DebtTransactionType.clientReceipt:
        return 'دفع عميل';
      case DebtTransactionType.supplierPayment:
      case DebtTransactionType.supplierReceipt:
        return 'دفع مورد';
    }
  }

  // Get the vault transaction notes
  String get vaultTransactionNotes {
    switch (type) {
      case DebtTransactionType.clientPayment:
        return 'تم استلام دفعة من العميل: $entityName';
      case DebtTransactionType.clientReceipt:
        return 'استلام من العميل: $entityName';
      case DebtTransactionType.supplierPayment:
        return 'تم دفع مبلغ للمورد: $entityName';
      case DebtTransactionType.supplierReceipt:
        return 'استلام للمورد: $entityName';
    }
  }
}
