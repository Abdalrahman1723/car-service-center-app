import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/constants/app_strings.dart';

import 'package:m_world/shared/models/client.dart';
import 'package:m_world/shared/models/invoice.dart';
import 'package:m_world/modules/manager/features/vault/domain/entities/vault_transaction.dart';
import 'package:m_world/modules/manager/features/dashboard/domain/entities/timeline_event.dart';

import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;

  DashboardCubit(this.repository) : super(DashboardInitial());

  Future<void> searchClients(String query) async {
    emit(DashboardLoading());
    try {
      final clients = await repository.searchClients(query);
      emit(DashboardClientsLoaded(clients));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> searchInvoices(String query) async {
    emit(DashboardLoading());
    try {
      final invoices = await repository.searchInvoices(query);
      emit(DashboardInvoicesLoaded(invoices));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> addClient(Client client) async {
    emit(DashboardLoading());
    try {
      await repository.addClient(client);
      emit(DashboardSuccess('Client added successfully'));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    emit(DashboardLoading());
    try {
      await repository.addInvoice(invoice);
      emit(DashboardSuccess('Invoice added successfully'));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> loadAllClients() async {
    emit(DashboardLoading());
    try {
      final clients = await repository.getAllClients();
      emit(DashboardClientsLoaded(clients));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> loadAllInvoices() async {
    emit(DashboardLoading());
    try {
      final invoices = await repository.getAllInvoices();
      emit(DashboardInvoicesLoaded(invoices));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(DashboardLoading());
    try {
      await repository.logout();
      emit(DashboardLoggedOut());
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  // Load dashboard data including charts and timeline
  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final clients = await repository.getAllClients();
      final invoices = await repository.getAllInvoices();
      final vaultTransactions = await repository.getVaultTransactions();

      final salesData = _processSalesData(invoices);
      final costData = _processCostData(vaultTransactions);
      final timelineEvents = await _generateTimelineEvents(
        invoices: invoices,
        vaultTransactions: vaultTransactions,
        clients: clients,
      );

      emit(
        DashboardDataLoaded(
          clients: clients,
          invoices: invoices,
          vaultTransactions: vaultTransactions,
          timelineEvents: timelineEvents,
          salesData: salesData,
          costData: costData,
        ),
      );
    } catch (e) {
      print('Dashboard data loading error: $e');
      emit(DashboardError(e.toString()));
    }
  }

  // Load only charts and timeline data
  Future<void> loadChartsData() async {
    emit(DashboardLoading());
    try {
      final invoices = await repository.getAllInvoices();
      final vaultTransactions = await repository.getVaultTransactions();

      final salesData = _processSalesData(invoices);
      final costData = _processCostData(vaultTransactions);
      final timelineEvents = await _generateTimelineEvents(
        invoices: invoices,
        vaultTransactions: vaultTransactions,
        clients: await repository.getAllClients(),
      );

      emit(
        DashboardChartsLoaded(
          salesData: salesData,
          costData: costData,
          timelineEvents: timelineEvents,
        ),
      );
    } catch (e) {
      print('Charts data loading error: $e');
      emit(DashboardError(e.toString()));
    }
  }

  // Process sales data for charts
  Map<String, double> _processSalesData(List<Invoice> invoices) {
    try {
      final now = DateTime.now();
      final Map<String, double> salesData = {};

      // Last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.day}/${date.month}';
        double dailyTotal = 0;

        for (final invoice in invoices) {
          if (invoice.issueDate.year == date.year &&
              invoice.issueDate.month == date.month &&
              invoice.issueDate.day == date.day) {
            dailyTotal += invoice.amount;
          }
        }
        salesData[dateKey] = dailyTotal;
      }

      return salesData;
    } catch (e) {
      print('Error processing sales data: $e');
      return {};
    }
  }

  // Process cost data for charts
  Map<String, double> _processCostData(List<VaultTransaction> transactions) {
    try {
      final now = DateTime.now();
      final Map<String, double> costData = {};

      // Last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.day}/${date.month}';
        double dailyExpenses = 0;
        double dailyIncome = 0;

        for (final transaction in transactions) {
          if (transaction.date.year == date.year &&
              transaction.date.month == date.month &&
              transaction.date.day == date.day) {
            if (transaction.type == 'expense') {
              dailyExpenses += transaction.amount;
            } else if (transaction.type == 'income') {
              dailyIncome += transaction.amount;
            }
          }
        }
        costData['${dateKey}_expenses'] = dailyExpenses;
        costData['${dateKey}_income'] = dailyIncome;
      }

      return costData;
    } catch (e) {
      print('Error processing cost data: $e');
      return {};
    }
  }

  // Generate timeline events from various modules
  Future<List<TimelineEvent>> _generateTimelineEvents({
    required List<Invoice> invoices,
    required List<VaultTransaction> vaultTransactions,
    required List<Client> clients,
  }) async {
    try {
      final List<TimelineEvent> events = [];

      // Add invoice events
      for (final invoice in invoices.take(10)) {
        // Last 10 invoices
        events.add(
          TimelineEvent(
            id: 'invoice_${invoice.id}',
            title: 'فاتورة جديدة',
            description:
                'تم إنشاء فاتورة بقيمة ${invoice.amount.toStringAsFixed(2)} ${AppStrings.currency}',
            timestamp: invoice.issueDate,
            type: EventType.invoice,
            relatedId: invoice.id,
            metadata: {'amount': invoice.amount, 'clientId': invoice.clientId},
          ),
        );
      }

      // Add vault transaction events
      for (final transaction in vaultTransactions.take(10)) {
        // Last 10 transactions
        final typeText = transaction.type == 'income' ? 'إيراد' : 'مصروف';
        events.add(
          TimelineEvent(
            id: 'vault_${transaction.id}',
            title: 'معاملة مالية',
            description:
                '$typeText: ${transaction.amount.toStringAsFixed(2)} ${AppStrings.currency} - ${transaction.category}',
            timestamp: transaction.date,
            type: EventType.vault,
            relatedId: transaction.id,
            metadata: {
              'amount': transaction.amount,
              'type': transaction.type,
              'category': transaction.category,
            },
          ),
        );
      }

      // Add client events (new clients)
      for (final client in clients.take(5)) {
        // Last 5 clients
        events.add(
          TimelineEvent(
            id: 'client_${client.id}',
            title: 'عميل جديد',
            description: 'تم إضافة عميل جديد: ${client.name}',
            timestamp: DateTime.now(), // Client model doesn't have createdAt
            type: EventType.client,
            relatedId: client.id,
            metadata: {
              'clientName': client.name,
              'phoneNumber': client.phoneNumber,
            },
          ),
        );
      }

      // Sort by timestamp (newest first)
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return events.take(15).toList(); // Return last 15 events
    } catch (e) {
      print('Error generating timeline events: $e');
      return [];
    }
  }
}
