// Use case to delete a supplier
import '../repositories/supplier_repository.dart';

class DeleteSupplier {
  final SupplierRepository repository;

  DeleteSupplier(this.repository);

  Future<void> call(String supplierId) async {
    await repository.deleteSupplier(supplierId);
  }
}