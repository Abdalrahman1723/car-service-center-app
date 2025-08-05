import 'package:m_world/core/usecases/usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import 'package:m_world/modules/manager/features/inventory/domain/repositories/inventory_repository.dart';

class RemoveItemFromInventoryParams {
  final String itemId;

  RemoveItemFromInventoryParams({required this.itemId});
}

class RemoveItemFromInventoryUseCase
    implements UseCase<InventoryEntity, RemoveItemFromInventoryParams> {
  final InventoryRepository repository;

  RemoveItemFromInventoryUseCase(this.repository);

  @override
  Future<InventoryEntity> call(RemoveItemFromInventoryParams params) async {
    return await repository.removeItemFromInventory(params.itemId);
  }
}
