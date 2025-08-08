import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';

// Use case to fetch all suppliers
class GetSuppliers {
  final SupplierRepository repository;

  GetSuppliers(this.repository);

  Future<List<SupplierEntity>> call() async {
    return await repository.getSuppliers();
  }
}
