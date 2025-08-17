import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../shared/models/invoice.dart';

// Abstract data source for invoice operations
abstract class InvoiceDataSource {
  Future<void> addInvoice(Invoice invoice);
  Future<List<Invoice>> getAllInvoices();
}

// Firebase implementation of the invoice data source
class FirebaseInvoiceDataSource implements InvoiceDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addInvoice(Invoice invoice) async {
    // Store invoice data in Firestore 'invoices' collection
    await _firestore
        .collection('invoices')
        .doc(invoice.clientId)
        .set(invoice.toMap());
  }

  @override
  Future<List<Invoice>> getAllInvoices() async {
    // Retrieve all invoices from Firestore
    final snapshot = await _firestore
        .collection('invoices')
        .orderBy("issueDate", descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Invoice.fromMap(doc.id, doc.data()))
        .toList();
  }
}
