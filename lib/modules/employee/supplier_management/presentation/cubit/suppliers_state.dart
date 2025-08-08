part of 'suppliers_cubit.dart';

abstract class SuppliersState {}

class SuppliersInitial extends SuppliersState {}

class SuppliersLoading extends SuppliersState {}

class SuppliersLoaded extends SuppliersState {
  final List<SupplierEntity> suppliers;
  SuppliersLoaded(this.suppliers);
}

class SuppliersError extends SuppliersState {
  final String message;
  SuppliersError(this.message);
}

class SuppliersAdding extends SuppliersState {}

class SuppliersUpdating extends SuppliersState {}

class SuppliersDeleting extends SuppliersState {}

class SuppliersSuccess extends SuppliersState {
  final String message;
  SuppliersSuccess(this.message);
}
