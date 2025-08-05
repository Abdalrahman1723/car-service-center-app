import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/modules/manager/features/inventory/data/models/inventory_model.dart';
import 'package:m_world/shared/models/item.dart';

abstract class InventoryRemoteDataSource {
  Future<InventoryModel> getInventory();
  Future<InventoryModel> updateInventory(InventoryModel inventory);
  Future<InventoryModel> addItemToInventory(Item item);
  Future<InventoryModel> updateItemInInventory(Item item);
  Future<InventoryModel> removeItemFromInventory(String itemId);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _inventoryId = 'main';

  InventoryRemoteDataSourceImpl(this.firestore);

  @override
  Future<InventoryModel> getInventory() async {
    try {
      final doc = await firestore
          .collection('inventories')
          .doc(_inventoryId)
          .get();
      if (!doc.exists) {
        // Create a default inventory if it doesn't exist
        final defaultInventory = InventoryModel(
          id: _inventoryId,
          name: 'Main Inventory',
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return await createInventory(defaultInventory);
      }
      return InventoryModel.fromMap({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get inventory: $e');
    }
  }

  Future<InventoryModel> createInventory(InventoryModel inventory) async {
    try {
      await firestore
          .collection('inventories')
          .doc(inventory.id)
          .set(inventory.toMap());
      return inventory;
    } catch (e) {
      throw Exception('Failed to create inventory: $e');
    }
  }

  @override
  Future<InventoryModel> updateInventory(InventoryModel inventory) async {
    try {
      await firestore
          .collection('inventories')
          .doc(inventory.id)
          .update(inventory.toMap());
      return inventory;
    } catch (e) {
      throw Exception('Failed to update inventory: $e');
    }
  }

  @override
  Future<InventoryModel> addItemToInventory(Item item) async {
    try {
      // Get the current inventory
      final inventory = await getInventory();

      // Add the item to the inventory
      final updatedItems = [...inventory.items, item];
      final updatedInventory = inventory.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      return await updateInventory(updatedInventory);
    } catch (e) {
      throw Exception('Failed to add item to inventory: $e');
    }
  }

  @override
  Future<InventoryModel> updateItemInInventory(Item item) async {
    try {
      final inventory = await getInventory();
      final updatedItems = inventory.items.map((existingItem) {
        if (existingItem.id == item.id) {
          return item;
        }
        return existingItem;
      }).toList();

      final updatedInventory = inventory.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      return await updateInventory(updatedInventory);
    } catch (e) {
      throw Exception('Failed to update item in inventory: $e');
    }
  }

  @override
  Future<InventoryModel> removeItemFromInventory(String itemId) async {
    try {
      final inventory = await getInventory();
      final updatedItems = inventory.items
          .where((item) => item.id != itemId)
          .toList();

      final updatedInventory = inventory.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      return await updateInventory(updatedInventory);
    } catch (e) {
      throw Exception('Failed to remove item from inventory: $e');
    }
  }
}
