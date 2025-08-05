import 'package:equatable/equatable.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final InventoryEntity inventory;

  const InventoryLoaded({required this.inventory});

  @override
  List<Object?> get props => [inventory];

  InventoryLoaded copyWith({InventoryEntity? inventory}) {
    return InventoryLoaded(inventory: inventory ?? this.inventory);
  }
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddingItem extends InventoryState {}

class ItemAdded extends InventoryState {
  final InventoryEntity updatedInventory;

  const ItemAdded(this.updatedInventory);

  @override
  List<Object?> get props => [updatedInventory];
}

class UpdatingItem extends InventoryState {}

class ItemUpdated extends InventoryState {
  final InventoryEntity updatedInventory;

  const ItemUpdated(this.updatedInventory);

  @override
  List<Object?> get props => [updatedInventory];
}

class RemovingItem extends InventoryState {}

class ItemRemoved extends InventoryState {
  final InventoryEntity updatedInventory;

  const ItemRemoved(this.updatedInventory);

  @override
  List<Object?> get props => [updatedInventory];
}
