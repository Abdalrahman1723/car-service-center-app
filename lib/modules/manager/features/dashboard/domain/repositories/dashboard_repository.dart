import 'package:m_world/shared/models/client.dart';
import 'package:m_world/shared/models/invoice.dart';

abstract class DashboardRepository {
  Future<List<Client>> searchClients(String query);
  Future<List<Invoice>> searchInvoices(String query);
  Future<void> addClient(Client client);
  Future<void> addInvoice(Invoice invoice);
  Future<List<Client>> getAllClients();
  Future<List<Invoice>> getAllInvoices();
  Future<void> logout();
}
