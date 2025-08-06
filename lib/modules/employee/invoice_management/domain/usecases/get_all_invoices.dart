import '../../../../../shared/models/invoice.dart';
import '../repositories/invoice_repository.dart';

class GetAllInvoices {
  final InvoiceRepository repository;

  GetAllInvoices(this.repository);

  Future<List<Invoice>> call() async {
    return await repository.getAllInvoices();
  }
}
