import 'package:m_world/core/usecases/usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import 'package:m_world/modules/manager/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:m_world/shared/models/item.dart';

class UpdateItemInInventoryParams {
  final Item item;

  UpdateItemInInventoryParams({required this.item});
}

class UpdateItemInInventoryUseCase
    implements UseCase<InventoryEntity, UpdateItemInInventoryParams> {
  final InventoryRepository repository;

  UpdateItemInInventoryUseCase(this.repository);

  @override
  Future<InventoryEntity> call(UpdateItemInInventoryParams params) async {
    return await repository.updateItemInInventory(params.item);
  }
}
