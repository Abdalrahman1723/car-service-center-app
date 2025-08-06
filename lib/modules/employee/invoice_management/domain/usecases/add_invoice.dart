import '../../../../../shared/models/invoice.dart';
import '../repositories/invoice_repository.dart';

class AddInvoice {
  final InvoiceRepository repository;

  AddInvoice(this.repository);

  Future<void> call(Invoice invoice) async {
    await repository.addInvoice(invoice);
  }
}
