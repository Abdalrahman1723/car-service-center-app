import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_datasource.dart';
import '../models/supplier_model.dart';

// Repository implementation for supplier management
class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierDataSource dataSource;

  SupplierRepositoryImpl(this.dataSource);

  @override
  Future<List<SupplierEntity>> getSuppliers() async {
    final models = await dataSource.getSuppliers();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addSupplier(SupplierEntity supplier) async {
    await dataSource.addSupplier(SupplierModel.fromEntity(supplier));
  }

  @override
  Future<void> updateSupplier(SupplierEntity supplier) async {
    await dataSource.updateSupplier(SupplierModel.fromEntity(supplier));
  }

  @override
  Future<void> deleteSupplier(String supplierId) async {
    await dataSource.deleteSupplier(supplierId);
  }

  @override
  Future<bool> isPhoneNumberUnique(String phoneNumber) async {
    return await dataSource.isPhoneNumberUnique(phoneNumber);
  }
}
