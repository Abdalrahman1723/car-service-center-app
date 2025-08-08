// Use case to add a supplier
import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';

class AddSupplier {
  final SupplierRepository repository;

  AddSupplier(this.repository);

  Future<void> call(SupplierEntity supplier) async {
    if (!await repository.isPhoneNumberUnique(supplier.phoneNumber)) {
      throw Exception('Phone number already exists');
    }
    await repository.addSupplier(supplier);
  }
}
