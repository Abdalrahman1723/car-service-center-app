part of 'dashboard_cubit.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardClientsLoaded extends DashboardState {
  final List<Client> clients;
  DashboardClientsLoaded(this.clients);
}

class DashboardInvoicesLoaded extends DashboardState {
  final List<Invoice> invoices;
  DashboardInvoicesLoaded(this.invoices);
}

class DashboardSuccess extends DashboardState {
  final String message;
  DashboardSuccess(this.message);
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

class DashboardLoggedOut extends DashboardState {}