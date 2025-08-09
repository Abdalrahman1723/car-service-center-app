import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/modules/manager/features/inventory/data/models/inventory_model.dart';
import 'package:m_world/shared/models/item.dart';

import '../../../supplier_management/data/models/supplier_model.dart';
import '../models/shipment_model.dart';

// Data source for shipment management
class ShipmentDataSource {
  final FirebaseFirestore _firestore;
  static const String _inventoryId = 'main';

  ShipmentDataSource(this._firestore);

  // Add shipment with inventory and supplier updates
  Future<void> addShipment(ShipmentModel shipment) async {
    await _firestore.runTransaction((transaction) async {
      final shipmentRef = _firestore.collection('shipments').doc();
      final inventoryRef = _firestore
          .collection('inventories')
          .doc(_inventoryId);
      final supplierRef = _firestore
          .collection('suppliers')
          .doc(shipment.supplierId);

      // Perform all reads first
      final inventorySnapshot = await transaction.get(inventoryRef);
      final supplierSnapshot = await transaction.get(supplierRef);

      // Validate inventory
      if (!inventorySnapshot.exists) {
        throw Exception('Inventory not found');
      }
      final inventory = InventoryModel.fromMap({
        'id': _inventoryId,
        ...inventorySnapshot.data()!,
      });

      // Validate supplier
      if (!supplierSnapshot.exists) {
        throw Exception('Supplier not found');
      }
      final supplier = SupplierModel.fromMap(
        shipment.supplierId,
        supplierSnapshot.data()!,
      );

      // Prepare data for writes
      // Update inventory items
      final updatedItems = List<Item>.from(inventory.items);
      for (final shipmentItem in shipment.items) {
        final index = updatedItems.indexWhere(
          (item) => item.id == shipmentItem.id,
        );
        if (index != -1) {
          updatedItems[index] = Item(
            id: shipmentItem.id,
            name: shipmentItem.name,
            price: shipmentItem.price,
            quantity: updatedItems[index].quantity + shipmentItem.quantity,
            timeAdded: updatedItems[index].timeAdded,
            code: updatedItems[index].code ?? shipmentItem.code,
          );
        } else {
          updatedItems.add(shipmentItem);
        }
      }
      final updatedInventory = inventory.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      // Update supplier balance
      final unpaidAmount = shipment.totalAmount - shipment.paidAmount;
      final updatedSupplier = SupplierModel(
        id: supplier.id,
        name: supplier.name,
        phoneNumber: supplier.phoneNumber,
        balance: supplier.balance + unpaidAmount,
        notes: supplier.notes,
        createdAt: supplier.createdAt,
      );

      // Prepare shipment with ID
      final shipmentWithId = ShipmentModel(
        id: shipmentRef.id,
        supplierId: shipment.supplierId,
        items: shipment.items,
        paymentMethod: shipment.paymentMethod,
        totalAmount: shipment.totalAmount,
        paidAmount: shipment.paidAmount,
        date: shipment.date,
        notes: shipment.notes,
      );

      // Perform all writes
      transaction.set(inventoryRef, updatedInventory.toMap());
      transaction.set(supplierRef, updatedSupplier.toMap());
      transaction.set(shipmentRef, shipmentWithId.toMap());
    });
  }

  // Update shipment with inventory and supplier adjustments
  Future<void> updateShipment(
    ShipmentModel oldShipment,
    ShipmentModel newShipment,
  ) async {
    await _firestore.runTransaction((transaction) async {
      final shipmentRef = _firestore
          .collection('shipments')
          .doc(oldShipment.id);
      final inventoryRef = _firestore.collection('inventories').doc(_inventoryId);
      final supplierRef = _firestore
          .collection('suppliers')
          .doc(newShipment.supplierId);

      // Perform all reads first
      final inventorySnapshot = await transaction.get(inventoryRef);
      final supplierSnapshot = await transaction.get(supplierRef);

      // Validate inventory
      if (!inventorySnapshot.exists) {
        throw Exception('Inventory not found');
      }
      final inventory = InventoryModel.fromMap({
        'id': _inventoryId,
        ...inventorySnapshot.data()!,
      });

      // Validate supplier
      if (!supplierSnapshot.exists) {
        throw Exception('Supplier not found');
      }
      final supplier = SupplierModel.fromMap(
        newShipment.supplierId,
        supplierSnapshot.data()!,
      );

      // Prepare data for writes
      // Adjust inventory quantities
      final updatedItems = List<Item>.from(inventory.items);
      // Reverse old shipment quantities
      for (final oldItem in oldShipment.items) {
        final index = updatedItems.indexWhere((item) => item.id == oldItem.id);
        if (index != -1) {
          final newQuantity = updatedItems[index].quantity - oldItem.quantity;
          if (newQuantity < 0) {
            throw Exception('Insufficient inventory for item ${oldItem.id}');
          }
          updatedItems[index] = Item(
            id: oldItem.id,
            name: updatedItems[index].name,
            price: updatedItems[index].price,
            quantity: newQuantity,
            timeAdded: updatedItems[index].timeAdded,
            code: updatedItems[index].code,
          );
        }
      }
      // Apply new shipment quantities
      for (final newItem in newShipment.items) {
        final index = updatedItems.indexWhere((item) => item.id == newItem.id);
        if (index != -1) {
          updatedItems[index] = Item(
            id: newItem.id,
            name: updatedItems[index].name,
            price: updatedItems[index].price,
            quantity: updatedItems[index].quantity + newItem.quantity,
            timeAdded: updatedItems[index].timeAdded,
            code: updatedItems[index].code ?? newItem.code,
          );
        } else {
          updatedItems.add(newItem);
        }
      }
      final updatedInventory = inventory.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      // Adjust supplier balance
      final oldUnpaid = oldShipment.totalAmount - oldShipment.paidAmount;
      final newUnpaid = newShipment.totalAmount - newShipment.paidAmount;
      final balanceAdjustment = newUnpaid - oldUnpaid;
      final updatedSupplier = SupplierModel(
        id: supplier.id,
        name: supplier.name,
        phoneNumber: supplier.phoneNumber,
        balance: supplier.balance + balanceAdjustment,
        notes: supplier.notes,
        createdAt: supplier.createdAt,
      );

      // Perform all writes
      transaction.set(inventoryRef, updatedInventory.toMap());
      transaction.set(supplierRef, updatedSupplier.toMap());
      transaction.set(shipmentRef, newShipment.toMap());
    });
  }

  // Delete shipment with inventory and supplier reversals
  Future<void> deleteShipment(ShipmentModel shipment) async {
    await _firestore.runTransaction((transaction) async {
      final shipmentRef = _firestore.collection('shipments').doc(shipment.id);
      final inventoryRef = _firestore
          .collection('inventories')
          .doc(_inventoryId);
      final supplierRef = _firestore
          .collection('suppliers')
          .doc(shipment.supplierId);

      // Perform all reads first
      final inventorySnapshot = await transaction.get(inventoryRef);
      final supplierSnapshot = await transaction.get(supplierRef);

      // Validate inventory
      if (!inventorySnapshot.exists) {
        throw Exception('Inventory not found');
      }
      final inventory = InventoryModel.fromMap({
        'id': _inventoryId,
        ...inventorySnapshot.data()!,
      });

      // Validate supplier
      if (!supplierSnapshot.exists) {
        throw Exception('Supplier not found');
      }
      final supplier = SupplierModel.fromMap(
        shipment.supplierId,
        supplierSnapshot.data()!,
      );

      // Prepare data for writes
      // Reverse inventory quantities
      final updatedItems = List<Item>.from(inventory.items);
      for (final item in shipment.items) {
        final index = updatedItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          final newQuantity = updatedItems[index].quantity - item.quantity;
          if (newQuantity < 0) {
            throw Exception('Insufficient inventory for item ${item.id}');
          }
          updatedItems[index] = Item(
            id: item.id,
            name: updatedItems[index].name,
            price: updatedItems[index].price,
            quantity: newQuantity,
            timeAdded: updatedItems[index].timeAdded,
            code: updatedItems[index].code,
          );
        }
      }
      final updatedInventory = inventory.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      // Reverse supplier balance
      final unpaidAmount = shipment.totalAmount - shipment.paidAmount;
      final updatedSupplier = SupplierModel(
        id: supplier.id,
        name: supplier.name,
        phoneNumber: supplier.phoneNumber,
        balance: supplier.balance - unpaidAmount,
        notes: supplier.notes,
        createdAt: supplier.createdAt,
      );

      // Perform all writes
      transaction.set(inventoryRef, updatedInventory.toMap());
      transaction.set(supplierRef, updatedSupplier.toMap());
      transaction.delete(shipmentRef);
    });
  }

  // Get all shipments
  Future<List<ShipmentModel>> getShipments() async {
    try {
      final snapshot = await _firestore.collection('shipments').get();
      return snapshot.docs
          .map((doc) => ShipmentModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get shipments: $e');
    }
  }

  // Get supplier for search
  Future<SupplierModel> getSupplier(String supplierId) async {
    try {
      final snapshot = await _firestore
          .collection('suppliers')
          .doc(supplierId)
          .get();
      if (!snapshot.exists) {
        throw Exception('Supplier not found');
      }
      return SupplierModel.fromMap(supplierId, snapshot.data()!);
    } catch (e) {
      throw Exception('Failed to get supplier: $e');
    }
  }
}
