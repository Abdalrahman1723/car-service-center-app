// Use case to update a supplier
import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';

class UpdateSupplier {
  final SupplierRepository repository;

  UpdateSupplier(this.repository);

  Future<void> call(SupplierEntity supplier) async {
    await repository.updateSupplier(supplier);
  }
}
