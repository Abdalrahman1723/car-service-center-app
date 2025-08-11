import '../entities/vault_transaction.dart';
import '../repositories/vault_repository.dart';

class GetVaultTransactions {
  final VaultRepository repository;

  GetVaultTransactions(this.repository);

  Future<List<VaultTransaction>> execute({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return repository.getTransactions(fromDate: fromDate, toDate: toDate);
  }
}
