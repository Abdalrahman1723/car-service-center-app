import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/supplier_model.dart';

// Data source for supplier management
class SupplierDataSource {
  final FirebaseFirestore _firestore;

  SupplierDataSource(this._firestore);

  // Add supplier to Firestore
  Future<void> addSupplier(SupplierModel supplier) async {
    try {
      final docRef = _firestore.collection('suppliers').doc();
      final supplierWithId = SupplierModel(
        id: docRef.id,
        name: supplier.name,
        phoneNumber: supplier.phoneNumber,
        balance: supplier.balance,
        notes: supplier.notes,
        createdAt: supplier.createdAt,
      );
      await docRef.set(supplierWithId.toMap());
    } catch (e) {
      throw Exception('Failed to add supplier: $e');
    }
  }

  // Update supplier in Firestore
  Future<void> updateSupplier(SupplierModel supplier) async {
    try {
      await _firestore
          .collection('suppliers')
          .doc(supplier.id)
          .update(supplier.toMap());
    } catch (e) {
      throw Exception('Failed to update supplier: $e');
    }
  }

  // Delete supplier from Firestore
  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _firestore.collection('suppliers').doc(supplierId).delete();
    } catch (e) {
      throw Exception('Failed to delete supplier: $e');
    }
  }

  // Get all suppliers from Firestore
  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final snapshot = await _firestore.collection('suppliers').get();
      return snapshot.docs
          .map((doc) => SupplierModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get suppliers: $e');
    }
  }

  // Check if phone number is unique
  Future<bool> isPhoneNumberUnique(String phoneNumber) async {
    try {
      final snapshot = await _firestore
          .collection('suppliers')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      return snapshot.docs.isEmpty;
    } catch (e) {
      throw Exception('Failed to check phone number uniqueness: $e');
    }
  }
}