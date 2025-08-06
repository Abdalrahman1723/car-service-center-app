
part of 'client_management_cubit.dart';

// Abstract state for client management
abstract class ClientManagementState {}

class ClientManagementInitial extends ClientManagementState {}

class ClientManagementLoading extends ClientManagementState {}

class ClientManagementSuccess extends ClientManagementState {
  final String message;
  ClientManagementSuccess(this.message);
}

class ClientManagementError extends ClientManagementState {
  final String message;
  ClientManagementError(this.message);
}

class ClientManagementClientsLoaded extends ClientManagementState {
  final List<Client> clients;
  ClientManagementClientsLoaded(this.clients);
}