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

// New states for charts and timeline
class DashboardDataLoaded extends DashboardState {
  final List<Client> clients;
  final List<Invoice> invoices;
  final List<VaultTransaction> vaultTransactions;
  final List<TimelineEvent> timelineEvents;
  final Map<String, double> salesData;
  final Map<String, double> costData;

  DashboardDataLoaded({
    required this.clients,
    required this.invoices,
    required this.vaultTransactions,
    required this.timelineEvents,
    required this.salesData,
    required this.costData,
  });
}

class DashboardChartsLoaded extends DashboardState {
  final Map<String, double> salesData;
  final Map<String, double> costData;
  final List<TimelineEvent> timelineEvents;

  DashboardChartsLoaded({
    required this.salesData,
    required this.costData,
    required this.timelineEvents,
  });
}
