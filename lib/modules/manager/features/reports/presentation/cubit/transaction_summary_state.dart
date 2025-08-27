import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_summary.dart';

abstract class TransactionSummaryState extends Equatable {
  const TransactionSummaryState();

  @override
  List<Object?> get props => [];
}

class TransactionSummaryInitial extends TransactionSummaryState {}

class TransactionSummaryLoading extends TransactionSummaryState {}

class TransactionSummaryLoaded extends TransactionSummaryState {
  final List<TransactionSummary> transactions;
  final double totalIncome;
  final double totalExpenses;

  const TransactionSummaryLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  List<Object?> get props => [transactions, totalIncome, totalExpenses];
}

class TransactionSummaryError extends TransactionSummaryState {
  final String message;

  const TransactionSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}
