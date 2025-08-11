import '../entities/vault_transaction.dart';
import '../repositories/vault_repository.dart';

class AddVaultTransaction {
  final VaultRepository repository;

  AddVaultTransaction(this.repository);

  Future<void> execute(VaultTransaction transaction) {
    return repository.addTransaction(transaction);
  }
}
