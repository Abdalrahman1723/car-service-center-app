import 'package:equatable/equatable.dart';
import '../../domain/entities/revenue_expense.dart';

abstract class RevenueExpenseState extends Equatable {
  const RevenueExpenseState();

  @override
  List<Object?> get props => [];
}

class RevenueExpenseInitial extends RevenueExpenseState {}

class RevenueExpenseLoading extends RevenueExpenseState {}

class RevenueExpenseLoaded extends RevenueExpenseState {
  final RevenueExpense revenueExpense;

  const RevenueExpenseLoaded(this.revenueExpense);

  @override
  List<Object?> get props => [revenueExpense];
}

class RevenueExpenseError extends RevenueExpenseState {
  final String message;

  const RevenueExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}
