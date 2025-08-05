import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/manager/features/dashboard/data/repositories/dashboard_repository_impl.dart';

import '../../../../../../shared/models/client.dart';
import '../../domain/usecases/add_client.dart';
import '../../domain/usecases/delete_client.dart';
import '../../domain/usecases/update_client.dart';

part 'client_management_state.dart';

// Cubit for managing client operations (add, update, delete)
class ClientManagementCubit extends Cubit<ClientManagementState> {
  final AddClient addClientUseCase;
  final UpdateClient updateClientUseCase;
  final DeleteClient deleteClientUseCase;

  ClientManagementCubit(FirebaseDashboardRepository firebaseDashboardRepository, {
    required this.addClientUseCase,
    required this.updateClientUseCase,
    required this.deleteClientUseCase,
  }) : super(ClientManagementInitial());

  // Add a new client
  Future<void> addClient({
    required String name,
    String? phoneNumber,
    required String carType,
    String? model,
    required double balance,
    String? email,
    String? licensePlate,
    String? notes,
  }) async {
    emit(ClientManagementLoading());
    try {
      final client = Client(
        id: DateTime.now().toString(),
        name: name,
        phoneNumber: phoneNumber,
        carType: carType,
        model: model,
        balance: balance,
        email: email,
        licensePlate: licensePlate,
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
}
