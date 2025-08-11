import 'package:equatable/equatable.dart';

class VaultTransaction extends Equatable {
  final String? id;
  final String type; // 'income' or 'expense'
  final String category;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? sourceId; // optional shipmentId or invoiceId
  final double runningBalance;

  const VaultTransaction({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    this.sourceId,
    required this.runningBalance,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        category,
        amount,
        date,
        notes,
        sourceId,
        runningBalance,
      ];

  // FIX: Add the copyWith method here.
  VaultTransaction copyWith({
    String? id,
    String? type,
    String? category,
    double? amount,
    DateTime? date,
    String? notes,
    String? sourceId,
    double? runningBalance,
  }) {
    return VaultTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      sourceId: sourceId ?? this.sourceId,
      runningBalance: runningBalance ?? this.runningBalance,
    );
  }
}