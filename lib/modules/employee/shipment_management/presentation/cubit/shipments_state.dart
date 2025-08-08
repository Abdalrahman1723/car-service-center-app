part of 'shipments_cubit.dart';

abstract class ShipmentsState {}

class ShipmentsInitial extends ShipmentsState {}

class ShipmentsLoading extends ShipmentsState {}

class ShipmentsLoaded extends ShipmentsState {
  final List<ShipmentEntity> shipments;
  final Map<String, SupplierEntity> suppliers;
  final String? searchQuery;

  ShipmentsLoaded(this.shipments, this.suppliers, {this.searchQuery});
}

class ShipmentsError extends ShipmentsState {
  final String message;

  ShipmentsError(this.message);
}

class AddingShipment extends ShipmentsState {}

class UpdatingShipment extends ShipmentsState {}

class DeletingShipment extends ShipmentsState {}

class SearchingShipments extends ShipmentsState {}

class ShipmentsSuccess extends ShipmentsState {
  final String message;

  ShipmentsSuccess(this.message);
}
