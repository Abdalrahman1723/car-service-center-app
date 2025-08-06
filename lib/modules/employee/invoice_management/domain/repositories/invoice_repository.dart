import '../../../../../shared/models/invoice.dart';

abstract class InvoiceRepository {
  Future<void> addInvoice(Invoice invoice);
  Future<List<Invoice>> getAllInvoices();
}
