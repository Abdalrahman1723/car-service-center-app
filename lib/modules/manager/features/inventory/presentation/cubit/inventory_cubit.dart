import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/usecases/usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/add_item_to_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/update_item_in_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/cubit/inventory_state.dart';
import 'package:m_world/shared/models/item.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final GetInventoryUseCase getInventoryUseCase;
  final AddItemToInventoryUseCase addItemToInventoryUseCase;
  final UpdateItemInInventoryUseCase updateItemInInventoryUseCase;

  InventoryCubit({
    required this.getInventoryUseCase,
    required this.addItemToInventoryUseCase,
    required this.updateItemInInventoryUseCase,
  }) : super(InventoryInitial());

  Future<void> loadInventory() async {
    emit(InventoryLoading());
    try {
      final inventory = await getInventoryUseCase(NoParams());
      emit(InventoryLoaded(inventory: inventory));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> addItemToInventory(Item item) async {
    emit(AddingItem());
    try {
      final updatedInventory = await addItemToInventoryUseCase(
        AddItemToInventoryParams(item: item),
      );
      emit(ItemAdded(updatedInventory));

      // Reload inventory to update the list
      await loadInventory();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> updateItemInInventory(Item item) async {
    emit(UpdatingItem());
    try {
      final updatedInventory = await updateItemInInventoryUseCase(
        UpdateItemInInventoryParams(item: item),
      );
      emit(ItemUpdated(updatedInventory));

      // Reload inventory to update the list
      await loadInventory();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  void clearError() {
    if (state is InventoryLoaded) {
      // Keep the current state but clear any error
      return;
    }
    emit(InventoryInitial());
  }
}
