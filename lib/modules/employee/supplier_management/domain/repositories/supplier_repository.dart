// Abstract repository for supplier operations
import '../entities/supplier.dart';

abstract class SupplierRepository {
  Future<List<SupplierEntity>> getSuppliers();
  Future<void> addSupplier(SupplierEntity supplier);
  Future<void> updateSupplier(SupplierEntity supplier);
  Future<void> deleteSupplier(String supplierId);
  Future<bool> isPhoneNumberUnique(String phoneNumber);
}
