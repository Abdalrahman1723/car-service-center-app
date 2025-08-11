import '../entities/vault_transaction.dart';
import '../repositories/vault_repository.dart';

class UpdateVaultTransaction {
  final VaultRepository repository;

  UpdateVaultTransaction(this.repository);

  Future<void> execute(VaultTransaction transaction) {
    return repository.updateTransaction(transaction);
  }
}
