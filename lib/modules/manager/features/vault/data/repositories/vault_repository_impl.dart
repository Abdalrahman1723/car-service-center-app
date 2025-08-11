import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/vault_transaction.dart';
import '../../domain/repositories/vault_repository.dart';
import '../datasources/vault_datasource.dart';

class VaultRepositoryImpl implements VaultRepository {
  late final VaultFirestoreDatasource _datasource;

  VaultRepositoryImpl() : _datasource = VaultFirestoreDatasource(FirebaseFirestore.instance);

  @override
  Future<List<VaultTransaction>> getTransactions({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return _datasource.getTransactions(fromDate: fromDate, toDate: toDate);
  }

  @override
  Future<void> addTransaction(VaultTransaction transaction) {
    return _datasource.addTransaction(transaction);
  }

  @override
  Future<void> updateTransaction(VaultTransaction transaction) {
    return _datasource.updateTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _datasource.deleteTransaction(id);
  }

  @override
  Future<List<VaultTransaction>> searchTransactions(String query) {
    return _datasource.searchTransactions(query);
  }
}