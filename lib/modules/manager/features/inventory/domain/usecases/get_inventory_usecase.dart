import 'package:m_world/core/usecases/usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import 'package:m_world/modules/manager/features/inventory/domain/repositories/inventory_repository.dart';

class GetInventoryUseCase implements UseCase<InventoryEntity, NoParams> {
  final InventoryRepository repository;

  GetInventoryUseCase(this.repository);

  @override
  Future<InventoryEntity> call(NoParams params) async {
    return await repository.getInventory();
  }
}
