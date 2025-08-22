import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/manager/features/manage_clients/domain/usecases/add_client.dart';
import 'package:m_world/modules/manager/features/manage_clients/domain/usecases/update_client.dart';
import 'package:m_world/modules/manager/features/manage_clients/domain/usecases/delete_client.dart';

import '../../../../../../shared/models/client.dart';
import '../../data/datasources/client_datasource.dart';
import '../../data/repositories/client_repository_impl.dart';

part 'client_management_state.dart';

// Cubit for managing client operations (add, update, delete, load)
class ClientManagementCubit extends Cubit<ClientManagementState> {
  final AddClient addClientUseCase;
  final UpdateClient updateClientUseCase;
  final DeleteClient deleteClientUseCase;

  ClientManagementCubit({
    required this.addClientUseCase,
    required this.updateClientUseCase,
    required this.deleteClientUseCase,
  }) : super(ClientManagementInitial());

  // Add a new client
  Future<void> addClient({
    required String name,
    required String phoneNumber,
    required List<Map<String, String?>> cars,
    String? model,
    required double balance,
    String? email,
    String? licensePlate,
    String? notes,
  }) async {
    emit(ClientManagementLoading());
    try {
      final client = Client(
        id: phoneNumber,
        name: name,
        phoneNumber: phoneNumber,
        cars: cars,
        balance: balance,
        email: email,
        notes: notes,
      );
      await addClientUseCase(client);
      emit(ClientManagementSuccess('Client added successfully'));
    } catch (e) {
      emit(ClientManagementError(e.toString()));
    }
  }

  // Update an existing client
  Future<void> updateClient(Client client) async {
    emit(ClientManagementLoading());
    try {
      await updateClientUseCase(client);
      emit(ClientManagementSuccess('Client updated successfully'));
    } catch (e) {
      emit(ClientManagementError(e.toString()));
    }
  }

  // Delete a client
  Future<void> deleteClient(String clientId) async {
    emit(ClientManagementLoading());
    try {
      await deleteClientUseCase(clientId);
      emit(ClientManagementSuccess('Client deleted successfully'));
    } catch (e) {
      emit(ClientManagementError(e.toString()));
    }
  }

  // Load all clients
  Future<void> loadClients() async {
    emit(ClientManagementLoading());
    try {
      final clients = await ClientRepositoryImpl(
        FirebaseClientDataSource(),
      ).getAllClients();
      emit(ClientManagementClientsLoaded(clients));
    } catch (e) {
      emit(ClientManagementError(e.toString()));
    }
  }


}
