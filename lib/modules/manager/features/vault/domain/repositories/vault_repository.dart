import '../entities/vault_transaction.dart';

abstract class VaultRepository {
  Future<List<VaultTransaction>> getTransactions({
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<void> addTransaction(VaultTransaction transaction);

  Future<void> updateTransaction(VaultTransaction transaction);

  Future<void> deleteTransaction(String id);

  Future<List<VaultTransaction>> searchTransactions(String query);
}
