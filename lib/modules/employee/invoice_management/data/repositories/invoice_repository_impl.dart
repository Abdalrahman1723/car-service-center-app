import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/modules/manager/features/manage_clients/data/datasources/client_datasource.dart';

import '../../../../../shared/models/client.dart' as client_model;
import '../../../../../shared/models/invoice.dart' as entity;
import '../../../../../shared/models/invoice.dart' as model;
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_datasource.dart';

// Repository implementation for invoice management
class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceDataSource invoiceDataSource;
  final ClientDataSource clientDataSource;

  InvoiceRepositoryImpl(this.invoiceDataSource, this.clientDataSource);

  @override
  Future<void> addInvoice(entity.Invoice invoice) async {
    // Map domain entity to data model and add to Firestore
    await invoiceDataSource.addInvoice(
      model.Invoice(
        id: invoice.id,
        clientId: invoice.clientId,
        amount: invoice.amount,
        maintenanceBy: invoice.maintenanceBy,
        createdAt: invoice.createdAt,
        issueDate: invoice.issueDate,
        items: invoice.items,
        notes: invoice.notes,
        isPaid: invoice.isPaid,
        paymentMethod: invoice.paymentMethod,
        discount: invoice.discount,
      ),
    );

    // Update client's invoices list
    final clientSnapshot = await FirebaseFirestore.instance
        .collection('clients')
        .where('phoneNumber', isEqualTo: invoice.clientId)
        .get();
    if (clientSnapshot.docs.isNotEmpty) {
      final clientDoc = clientSnapshot.docs.first;
      final client = client_model.Client.fromMap(
        clientDoc.id,
        clientDoc.data(),
      );
      final updatedInvoices = [...client.invoices, invoice.id];
      await clientDataSource.updateClient(
        client_model.Client(
          id: client.id,
          name: client.name,
          phoneNumber: client.phoneNumber,
          cars: client.cars,
          balance: client.balance,
          email: client.email,
          notes: client.notes,
          history: client.history,
          invoices: updatedInvoices,
        ),
      );
    }
  }

  @override
  Future<List<entity.Invoice>> getAllInvoices() async {
    final invoiceModels = await invoiceDataSource.getAllInvoices();
    return invoiceModels
        .map(
          (model) => entity.Invoice(
            id: model.id,
            clientId: model.clientId,
            amount: model.amount,
            maintenanceBy: model.maintenanceBy,
            createdAt: model.createdAt,
            issueDate: model.issueDate,
            items: model.items,
            notes: model.notes,
            isPaid: model.isPaid,
            paymentMethod: model.paymentMethod,
            discount: model.discount,
          ),
        )
        .toList();
  }
}
