import 'package:m_world/modules/manager/features/manage_clients/data/datasources/client_datasource.dart';
import 'package:m_world/modules/manager/features/manage_clients/domain/repositories/client_repository.dart';

import '../../../../../../shared/models/client.dart' as entity;
import '../../../../../../shared/models/client.dart' as model;

// Repository implementation for client management
class ClientRepositoryImpl implements ClientRepository {
  final ClientDataSource dataSource;

  ClientRepositoryImpl(this.dataSource);

  @override
  Future<void> addClient(entity.Client client) async {
    // Map domain entity to data model and call data source
    await dataSource.addClient(
      model.Client(
        id: client.id,
        name: client.name,
        phoneNumber: client.phoneNumber,
        cars: client.cars,
        balance: client.balance,
        email: client.email,
        notes: client.notes,
        history: client.history,
      ),
    );
  }

  @override
  Future<void> updateClient(entity.Client client) async {
    // Map domain entity to data model and update
    await dataSource.updateClient(
      model.Client(
        id: client.id,
        name: client.name,
        phoneNumber: client.phoneNumber,
        cars: client.cars,
        balance: client.balance,
        email: client.email,
        notes: client.notes,
        history: client.history,
      ),
    );
  }

  @override
  Future<void> deleteClient(String clientId) async {
    // Call data source to delete client
    await dataSource.deleteClient(clientId);
  }

  // Fetch all clients from data source
  @override
  Future<List<entity.Client>> getAllClients() async {
    final clientModels = await dataSource.getAllClients();
    return clientModels
        .map(
          (model) => entity.Client(
            id: model.id,
            name: model.name,
            phoneNumber: model.phoneNumber,
            cars: model.cars,
            balance: model.balance,
            email: model.email,
            notes: model.notes,
            history: model.history,
          ),
        )
        .toList();
  }
}
