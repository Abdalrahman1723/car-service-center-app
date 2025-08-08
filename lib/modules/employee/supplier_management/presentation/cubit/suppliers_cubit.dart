import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/usecases/add_supplier.dart';
import '../../domain/usecases/delete_supplier.dart';
import '../../domain/usecases/get_suppliers.dart';
import '../../domain/usecases/update_supplier.dart';

part 'suppliers_state.dart';

// Cubit for managing supplier operations
class SuppliersCubit extends Cubit<SuppliersState> {
  final GetSuppliers getSuppliersUseCase;
  final AddSupplier addSupplierUseCase;
  final UpdateSupplier updateSupplierUseCase;
  final DeleteSupplier deleteSupplierUseCase;

  SuppliersCubit({
    required this.getSuppliersUseCase,
    required this.addSupplierUseCase,
    required this.updateSupplierUseCase,
    required this.deleteSupplierUseCase,
  }) : super(SuppliersInitial());

  // Load all suppliers
  Future<void> loadSuppliers() async {
    emit(SuppliersLoading());
    try {
      final suppliers = await getSuppliersUseCase();
      emit(SuppliersLoaded(suppliers));
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }

  // Add a new supplier
  Future<void> addSupplier(SupplierEntity supplier) async {
    emit(SuppliersAdding());
    try {
      await addSupplierUseCase(supplier);
      await loadSuppliers();
      emit(SuppliersSuccess('Supplier added successfully'));
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }

  // Update an existing supplier
  Future<void> updateSupplier(SupplierEntity supplier) async {
    emit(SuppliersUpdating());
    try {
      await updateSupplierUseCase(supplier);
      await loadSuppliers();
      emit(SuppliersSuccess('Supplier updated successfully'));
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }

  // Delete a supplier
  Future<void> deleteSupplier(String supplierId) async {
    emit(SuppliersDeleting());
    try {
      await deleteSupplierUseCase(supplierId);
      emit(SuppliersSuccess('Supplier deleted successfully'));
      await loadSuppliers();
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }
}
