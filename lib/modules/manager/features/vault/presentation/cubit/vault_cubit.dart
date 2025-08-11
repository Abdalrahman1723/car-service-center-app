import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/vault_repository_impl.dart';
import '../../domain/entities/vault_transaction.dart';
import '../../domain/usecases/add_vault_transaction.dart';
import '../../domain/usecases/delete_vault_transaction.dart';
import '../../domain/usecases/get_vault_transactions.dart';
import '../../domain/usecases/search_vault_transaction.dart';
import '../../domain/usecases/update_vault_transaction.dart';
import 'vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  late final VaultRepositoryImpl _repository;
  late final GetVaultTransactions _getTransactions;
  late final AddVaultTransaction _addTransaction;
  late final UpdateVaultTransaction _updateTransaction;
  late final DeleteVaultTransaction _deleteTransaction;
  late final SearchVaultTransactions _searchTransactions;

  VaultCubit() : super(VaultLoading()) {
    _repository = VaultRepositoryImpl();
    _getTransactions = GetVaultTransactions(_repository);
    _addTransaction = AddVaultTransaction(_repository);
    _updateTransaction = UpdateVaultTransaction(_repository);
    _deleteTransaction = DeleteVaultTransaction(_repository);
    _searchTransactions = SearchVaultTransactions(_repository);
  }

  Future<void> getTransactions({DateTime? fromDate, DateTime? toDate}) async {
    emit(VaultLoading());
    try {
      final transactions = await _getTransactions.execute(
        fromDate: fromDate,
        toDate: toDate,
      );
      final grouped = groupTransactionsByDate(transactions);
      emit(VaultLoaded(transactions, grouped));
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> addTransaction(VaultTransaction transaction) async {
    emit(AddingTransaction());
    try {
      await _addTransaction.execute(transaction);
      await getTransactions(); // Refresh
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> updateTransaction(VaultTransaction transaction) async {
    emit(UpdatingTransaction());
    try {
      await _updateTransaction.execute(transaction);
      await getTransactions(); // Refresh
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> deleteTransaction(String id) async {
    emit(DeletingTransaction());
    try {
      await _deleteTransaction.execute(id);
      await getTransactions(); // Refresh
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> searchTransactions(String query) async {
    emit(SearchingTransactions());
    try {
      final transactions = await _searchTransactions.execute(query);
      final grouped = groupTransactionsByDate(transactions);
      emit(VaultLoaded(transactions, grouped));
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Map<String, List<VaultTransaction>> groupTransactionsByDate(
    List<VaultTransaction> transactions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final Map<String, List<VaultTransaction>> grouped = {};

    for (var tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String group;
      if (txDate == today) {
        group = 'Today';
      } else if (txDate == yesterday) {
        group = 'Yesterday';
      } else if (txDate.isAfter(
        thisWeekStart.subtract(const Duration(days: 1)),
      )) {
        group = 'This Week';
      } else if (txDate.isAfter(
        lastWeekStart.subtract(const Duration(days: 1)),
      )) {
        group = 'Last Week';
      } else {
        group = 'Older';
      }
      grouped.putIfAbsent(group, () => []).add(tx);
    }
    return grouped;
  }
}
