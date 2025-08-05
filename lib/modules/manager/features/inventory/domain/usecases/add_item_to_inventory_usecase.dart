import 'package:m_world/core/usecases/usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import 'package:m_world/modules/manager/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:m_world/shared/models/item.dart';

class AddItemToInventoryParams {
  final Item item;

  AddItemToInventoryParams({required this.item});
}

class AddItemToInventoryUseCase
    implements UseCase<InventoryEntity, AddItemToInventoryParams> {
  final InventoryRepository repository;

  AddItemToInventoryUseCase(this.repository);

  @override
  Future<InventoryEntity> call(AddItemToInventoryParams params) async {
    return await repository.addItemToInventory(params.item);
  }
}
