import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import 'package:m_world/shared/models/item.dart';

abstract class InventoryRepository {
  Future<InventoryEntity> getInventory();
  Future<InventoryEntity> updateInventory(InventoryEntity inventory);
  Future<InventoryEntity> addItemToInventory(Item item);
  Future<InventoryEntity> updateItemInInventory(Item item);
  Future<InventoryEntity> removeItemFromInventory(String itemId);
}
