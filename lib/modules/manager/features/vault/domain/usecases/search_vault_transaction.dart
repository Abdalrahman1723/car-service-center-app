import '../entities/vault_transaction.dart';
import '../repositories/vault_repository.dart';

class SearchVaultTransactions {
  final VaultRepository repository;

  SearchVaultTransactions(this.repository);

  Future<List<VaultTransaction>> execute(String query) {
    return repository.searchTransactions(query);
  }
}
