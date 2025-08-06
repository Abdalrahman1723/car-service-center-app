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
        carType: client.carType,
        model: client.model,
        balance: client.balance,
        email: client.email,
        licensePlate: client.licensePlate,
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
        carType: client.carType,
        model: client.model,
        balance: client.balance,
        email: client.email,
        licensePlate: client.licensePlate,
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
  Future<List<entity.Client>> getAllClients() async {
    final clientModels = await dataSource.getAllClients();
    return clientModels
        .map(
          (model) => entity.Client(
            id: model.id,
            name: model.name,
            phoneNumber: model.phoneNumber,
            carType: model.carType,
            model: model.model,
            balance: model.balance,
            email: model.email,
            licensePlate: model.licensePlate,
            notes: model.notes,
            history: model.history,
          ),
        )
        .toList();
  }
}
