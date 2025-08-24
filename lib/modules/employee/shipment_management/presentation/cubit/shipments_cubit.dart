import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../manager/features/vault/domain/entities/vault_transaction.dart';
import '../../../../manager/features/vault/domain/usecases/add_vault_transaction.dart';
import '../../../supplier_management/domain/entities/supplier.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/usecases/add_shipment.dart';
import '../../domain/usecases/delete_shipment.dart';
import '../../domain/usecases/get_shipment.dart';
import '../../domain/usecases/update_shipment.dart';

part 'shipments_state.dart';

// Cubit لإدارة عمليات الشحن
class ShipmentsCubit extends Cubit<ShipmentsState> {
  final GetShipments getShipmentsUseCase;
  final AddShipment addShipmentUseCase;
  final UpdateShipment updateShipmentUseCase;
  final DeleteShipment deleteShipmentUseCase;
  final AddVaultTransaction addTransaction;

  ShipmentsCubit({
    required this.getShipmentsUseCase,
    required this.addShipmentUseCase,
    required this.updateShipmentUseCase,
    required this.deleteShipmentUseCase,
    required this.addTransaction,
  }) : super(ShipmentsInitial());

  // Cache suppliers for search
  final Map<String, SupplierEntity> _supplierCache = {};

  // Load all shipments
  Future<void> loadShipments() async {
    emit(ShipmentsLoading());
    try {
      final shipments = await getShipmentsUseCase();
      emit(ShipmentsLoaded(shipments, _supplierCache));
    } catch (e) {
      emit(ShipmentsError(e.toString()));
    }
  }

  // Add a new shipment
  Future<void> addShipment(ShipmentEntity shipment) async {
    emit(AddingShipment());
    try {
      await addShipmentUseCase(shipment);
      await loadShipments();
      await addTransaction.execute(
        VaultTransaction(
          type: "expense",
          category: "مشتريات",
          amount: shipment.paidAmount,
          date: shipment.date,
          runningBalance: 0,
        ),
      );
      emit(ShipmentsSuccess('تم إضافة الشحنة بنجاح'));
    } catch (e) {
      emit(ShipmentsError(e.toString()));
    }
  }

  // Update an existing shipment
  Future<void> updateShipment(
    ShipmentEntity oldShipment,
    ShipmentEntity newShipment,
  ) async {
    emit(UpdatingShipment());
    try {
      await updateShipmentUseCase(oldShipment, newShipment);
      await loadShipments();
      emit(ShipmentsSuccess('تم تحديث الشحنة بنجاح'));
    } catch (e) {
      emit(ShipmentsError(e.toString()));
    }
  }

  // Delete a shipment
  Future<void> deleteShipment(ShipmentEntity shipment) async {
    emit(DeletingShipment());
    try {
      await deleteShipmentUseCase(shipment);
      await loadShipments();
      emit(ShipmentsSuccess('تم حذف الشحنة بنجاح'));
    } catch (e) {
      emit(ShipmentsError(e.toString()));
    }
  }

  // Search shipments
  void searchShipments(String query, Map<String, SupplierEntity> suppliers) {
    emit(SearchingShipments());
    try {
      emit(ShipmentsLoaded([], suppliers, searchQuery: query));
    } catch (e) {
      emit(ShipmentsError(e.toString()));
    }
  }

  // Cache supplier for search
  void cacheSupplier(SupplierEntity supplier) {
    _supplierCache[supplier.id] = supplier;
  }
}
