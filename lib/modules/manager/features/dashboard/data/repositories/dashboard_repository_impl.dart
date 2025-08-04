import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:m_world/shared/models/client.dart';
import 'package:m_world/shared/models/invoice.dart';
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
}
