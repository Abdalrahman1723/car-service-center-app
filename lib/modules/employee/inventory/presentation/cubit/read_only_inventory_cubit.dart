import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/usecases/usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/cubit/inventory_state.dart';

class ReadOnlyInventoryCubit extends Cubit<InventoryState> {
  final GetInventoryUseCase getInventoryUseCase;

  ReadOnlyInventoryCubit({required this.getInventoryUseCase})
    : super(InventoryInitial());

  Future<void> loadInventory() async {
    emit(InventoryLoading());
    try {
      final inventory = await getInventoryUseCase(NoParams());
      emit(InventoryLoaded(inventory: inventory));
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
