import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:m_world/shared/models/client.dart';
import 'package:m_world/shared/models/invoice.dart';
import 'package:m_world/modules/manager/features/vault/domain/entities/vault_transaction.dart';
import '../../domain/repositories/dashboard_repository.dart';

class FirebaseDashboardRepository implements DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<List<Client>> searchClients(String query) async {
    final snapshot = await _firestore
        .collection('clients')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs
        .map((doc) => Client.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<Invoice>> searchInvoices(String query) async {
    final snapshot = await _firestore
        .collection('invoices')
        .where('clientId', isGreaterThanOrEqualTo: query)
        .where('clientId', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs
        .map((doc) => Invoice.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> addClient(Client client) async {
    await _firestore.collection('clients').add(client.toMap());
  }

  @override
  Future<void> addInvoice(Invoice invoice) async {
    await _firestore.collection('invoices').add(invoice.toMap());
  }

  @override
  Future<List<Client>> getAllClients() async {
    final snapshot = await _firestore.collection('clients').get();
    return snapshot.docs
        .map((doc) => Client.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<Invoice>> getAllInvoices() async {
    final snapshot = await _firestore.collection('invoices').get();
    return snapshot.docs
        .map((doc) => Invoice.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<List<VaultTransaction>> getVaultTransactions() async {
    try {
      final snapshot = await _firestore
          .collection('vault')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          return VaultTransaction(
            id: doc.id,
            type: data['type'] as String? ?? 'expense',
            category: data['category'] as String? ?? 'Unknown',
            amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
            date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            notes: data['notes'] as String?,
            sourceId: data['sourceId'] as String?,
            runningBalance: (data['runningBalance'] as num?)?.toDouble() ?? 0.0,
          );
        } catch (e) {
          print('Error parsing vault transaction ${doc.id}: $e');
          // Return a default transaction if parsing fails
          return VaultTransaction(
            id: doc.id,
            type: 'expense',
            category: 'Error',
            amount: 0.0,
            date: DateTime.now(),
            notes: 'Error parsing transaction',
            sourceId: null,
            runningBalance: 0.0,
          );
        }
      }).toList();
    } catch (e) {
      print('Error fetching vault transactions: $e');
      return [];
    }
  }
}
