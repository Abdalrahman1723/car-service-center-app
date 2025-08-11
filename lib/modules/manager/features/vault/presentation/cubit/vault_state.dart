import 'package:equatable/equatable.dart';

import '../../domain/entities/vault_transaction.dart';

abstract class VaultState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VaultLoading extends VaultState {}

class VaultLoaded extends VaultState {
  final List<VaultTransaction> transactions;
  final Map<String, List<VaultTransaction>> groupedTransactions;

  VaultLoaded(this.transactions, this.groupedTransactions);

  @override
  List<Object?> get props => [transactions, groupedTransactions];
}

class VaultError extends VaultState {
  final String message;

  VaultError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddingTransaction extends VaultState {}

class UpdatingTransaction extends VaultState {}

class DeletingTransaction extends VaultState {}

class SearchingTransactions extends VaultState {}
