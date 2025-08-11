import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/vault_transaction.dart';


class VaultFirestoreDatasource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'vault';

  VaultFirestoreDatasource(this.firestore);

  // GET TRANSACTIONS
  Future<List<VaultTransaction>> getTransactions({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    Query<Map<String, dynamic>> query = firestore
        .collection(collectionPath)
        .orderBy('date', descending: true);

    if (fromDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
      );
    }
    if (toDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(toDate),
      );
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => _fromDocument(doc)).toList();
  }

  // ADD TRANSACTION
  Future<void> addTransaction(VaultTransaction transaction) async {
    await firestore.runTransaction((tx) async {
      final latestSnapshot = await firestore
          .collection(collectionPath)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      double prevBalance = 0;
      if (latestSnapshot.docs.isNotEmpty) {
        prevBalance = _fromDocument(latestSnapshot.docs.first).runningBalance;
      }

      double newBalance = prevBalance +
          (transaction.type == 'income'
              ? transaction.amount
              : -transaction.amount);

      final docRef = firestore.collection(collectionPath).doc();
      tx.set(
        docRef,
        _toMap(transaction.copyWith(
          id: docRef.id,
          runningBalance: newBalance,
        )),
      );
    });
  }

  // UPDATE TRANSACTION
  Future<void> updateTransaction(VaultTransaction transaction) async {
    await firestore.runTransaction((tx) async {
      final docRef = firestore.collection(collectionPath).doc(transaction.id);
      final originalSnapshot = await tx.get(docRef);
      if (!originalSnapshot.exists) {
        throw Exception('Transaction not found');
      }
      final original = _fromDocument(originalSnapshot);

      double originalBalanceChange = (original.type == 'income' ? original.amount : -original.amount);
      double updatedBalanceChange = (transaction.type == 'income' ? transaction.amount : -transaction.amount);
      double delta = updatedBalanceChange - originalBalanceChange;

      tx.update(
        docRef,
        _toMap(transaction.copyWith(
          runningBalance: original.runningBalance + delta,
        )),
      );

      final subsequentQuery = firestore
          .collection(collectionPath)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(transaction.date))
          .orderBy('date');
      final subsequentSnapshot = await subsequentQuery.get();
      for (var doc in subsequentSnapshot.docs) {
        if (doc.id == transaction.id) continue;

        final txData = _fromDocument(doc);
        tx.update(doc.reference, {
          'runningBalance': txData.runningBalance + delta,
        });
      }
    });
  }

  // DELETE TRANSACTION
  Future<void> deleteTransaction(String id) async {
    await firestore.runTransaction((tx) async {
      final docRef = firestore.collection(collectionPath).doc(id);
      final originalSnapshot = await tx.get(docRef);
      if (!originalSnapshot.exists) {
        throw Exception('Transaction not found');
      }
      final original = _fromDocument(originalSnapshot);
      
      double delta = original.type == 'income' ? -original.amount : original.amount;

      final subsequentQuery = firestore
          .collection(collectionPath)
          .where('date', isGreaterThan: Timestamp.fromDate(original.date))
          .orderBy('date');
      final subsequentSnapshot = await subsequentQuery.get();
      for (var doc in subsequentSnapshot.docs) {
        final txData = _fromDocument(doc);
        tx.update(doc.reference, {
          'runningBalance': txData.runningBalance + delta,
        });
      }

      tx.delete(docRef);
    });
  }

  // SEARCH TRANSACTIONS
  Future<List<VaultTransaction>> searchTransactions(String query) async {
    final all = await getTransactions();
    final lowerCaseQuery = query.toLowerCase();

    return all.where((tx) =>
      tx.category.toLowerCase().contains(lowerCaseQuery) ||
      tx.type.toLowerCase().contains(lowerCaseQuery) ||
      (tx.sourceId?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
      (tx.notes?.toLowerCase().contains(lowerCaseQuery) ?? false),
    ).toList();
  }

  // DATA MAPPING
  VaultTransaction _fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VaultTransaction(
      id: doc.id,
      type: data['type'] as String,
      category: data['category'] as String,
      amount: (data['amount'] as num).toDouble(),
      // FIX HERE: This is the correct way to handle a Firestore Timestamp
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      sourceId: data['sourceId'] as String?,
      runningBalance: (data['runningBalance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> _toMap(VaultTransaction tx) => {
    'type': tx.type,
    'category': tx.category,
    'amount': tx.amount,
    'date': Timestamp.fromDate(tx.date),
    'notes': tx.notes,
    'sourceId': tx.sourceId,
    'runningBalance': tx.runningBalance,
  };
}

// EXTENSION FOR COPYWITH
extension on VaultTransaction {
  VaultTransaction copyWith({
    String? id,
    String? type,
    String? category,
    double? amount,
    DateTime? date,
    String? notes,
    String? sourceId,
    double? runningBalance,
  }) {
    return VaultTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      sourceId: sourceId ?? this.sourceId,
      runningBalance: runningBalance ?? this.runningBalance,
    );
  }
}