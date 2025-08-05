import 'package:m_world/modules/manager/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:m_world/modules/manager/features/inventory/data/models/inventory_model.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import 'package:m_world/modules/manager/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:m_world/shared/models/item.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<InventoryEntity> getInventory() async {
    try {
      final inventory = await remoteDataSource.getInventory();
      return inventory;
    } catch (e) {
      throw Exception('Failed to get inventory: $e');
    }
  }

  @override
  Future<InventoryEntity> updateInventory(InventoryEntity inventory) async {
    try {
      final inventoryModel = InventoryModel.fromEntity(inventory);
      final updatedInventory = await remoteDataSource.updateInventory(
        inventoryModel,
      );
      return updatedInventory;
    } catch (e) {
      throw Exception('Failed to update inventory: $e');
    }
  }

  @override
  Future<InventoryEntity> addItemToInventory(Item item) async {
    try {
      final updatedInventory = await remoteDataSource.addItemToInventory(item);
      return updatedInventory;
    } catch (e) {
      throw Exception('Failed to add item to inventory: $e');
    }
  }

  @override
  Future<InventoryEntity> updateItemInInventory(Item item) async {
    try {
      final updatedInventory = await remoteDataSource.updateItemInInventory(
        item,
      );
      return updatedInventory;
    } catch (e) {
      throw Exception('Failed to update item in inventory: $e');
    }
  }

  @override
  Future<InventoryEntity> removeItemFromInventory(String itemId) async {
    try {
      final updatedInventory = await remoteDataSource.removeItemFromInventory(
        itemId,
      );
      return updatedInventory;
    } catch (e) {
      throw Exception('Failed to remove item from inventory: $e');
    }
  }
}
