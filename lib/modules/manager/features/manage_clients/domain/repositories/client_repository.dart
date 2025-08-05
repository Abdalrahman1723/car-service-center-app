// Abstract repository defining client management operations
import '../../../../../../shared/models/client.dart';

abstract class ClientRepository {
  Future<void> addClient(Client client);
  Future<void> updateClient(Client client);
  Future<void> deleteClient(String clientId);
}
