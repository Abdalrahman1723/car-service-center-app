import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../shared/models/debt_transaction.dart';

abstract class DebtTransactionDataSource {
  Future<void> addDebtTransaction(DebtTransaction transaction);
  Future<void> updateDebtTransaction(DebtTransaction transaction);
  Future<void> deleteDebtTransaction(String transactionId);
  Future<List<DebtTransaction>> getDebtTransactionsByEntity(
    String entityId,
    String entityType,
  );
  Future<List<DebtTransaction>> getAllDebtTransactions();
  Future<List<DebtTransaction>> getDebtTransactionsByDateRange(
    DateTime fromDate,
    DateTime toDate,
  );
}

class FirebaseDebtTransactionDataSource implements DebtTransactionDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionPath = 'debt_transactions';

  @override
  Future<void> addDebtTransaction(DebtTransaction transaction) async {
    try {
      final docRef = _firestore.collection(_collectionPath).doc();
      final transactionWithId = transaction.copyWith(id: docRef.id);
      await docRef.set(transactionWithId.toMap());
    } catch (e) {
      throw Exception('Failed to add debt transaction: $e');
    }
  }

  @override
  Future<void> updateDebtTransaction(DebtTransaction transaction) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to update debt transaction: $e');
    }
  }

  @override
  Future<void> deleteDebtTransaction(String transactionId) async {
    try {
      await _firestore.collection(_collectionPath).doc(transactionId).delete();
    } catch (e) {
      throw Exception('Failed to delete debt transaction: $e');
    }
  }

  @override
  Future<List<DebtTransaction>> getDebtTransactionsByEntity(
    String entityId,
    String entityType,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('entityId', isEqualTo: entityId)
          .where('entityType', isEqualTo: entityType)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DebtTransaction.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get debt transactions for entity: $e');
    }
  }

  @override
  Future<List<DebtTransaction>> getAllDebtTransactions() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DebtTransaction.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all debt transactions: $e');
    }
  }

  @override
  Future<List<DebtTransaction>> getDebtTransactionsByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('date', isGreaterThanOrEqualTo: fromDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: toDate.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DebtTransaction.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get debt transactions by date range: $e');
    }
  }
}
