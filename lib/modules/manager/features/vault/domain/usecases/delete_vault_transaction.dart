import '../repositories/vault_repository.dart';

class DeleteVaultTransaction {
  final VaultRepository repository;

  DeleteVaultTransaction(this.repository);

  Future<void> execute(String id) {
    return repository.deleteTransaction(id);
  }
}
