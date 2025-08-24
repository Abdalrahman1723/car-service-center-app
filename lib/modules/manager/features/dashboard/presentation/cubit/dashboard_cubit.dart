import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/core/utils/notification_service.dart';
import 'package:m_world/shared/models/client.dart';
import 'package:m_world/shared/models/invoice.dart';
import 'package:m_world/modules/manager/features/vault/domain/entities/vault_transaction.dart';
import 'package:m_world/modules/manager/features/dashboard/domain/entities/timeline_event.dart';

import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;
  final NotificationService _notificationService = NotificationService();

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
        ),
      );
    } catch (e) {
      log('Dashboard data loading error: $e');
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
      final timelineEvents = await _generateTimelineEvents(
        invoices: invoices,
        vaultTransactions: vaultTransactions,
        clients: await repository.getAllClients(),
      );

      emit(
        DashboardChartsLoaded(
          salesData: salesData,
          timelineEvents: timelineEvents,
        ),
      );
    } catch (e) {
      log('Charts data loading error: $e');
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
      log('Error processing sales data: $e');
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
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      // Add invoice events (only recent ones)
      for (final invoice in invoices) {
        if (invoice.issueDate.isAfter(sevenDaysAgo)) {
          events.add(
            TimelineEvent(
              id: 'invoice_${invoice.id}',
              title: 'فاتورة جديدة',
              description:
                  'تم إنشاء فاتورة بقيمة ${invoice.amount.toStringAsFixed(2)} ${AppStrings.currency}',
              timestamp: invoice.issueDate,
              type: EventType.invoice,
              relatedId: invoice.id,
              metadata: {
                'amount': invoice.amount,
                'clientId': invoice.clientId,
              },
            ),
          );
        }
      }

      // Add vault transaction events (only recent ones)
      for (final transaction in vaultTransactions) {
        if (transaction.date.isAfter(sevenDaysAgo)) {
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
      }

      // Add only truly recent client events (created in last 7 days)
      for (final client in clients) {
        if (client.createdAt != null &&
            client.createdAt!.isAfter(sevenDaysAgo)) {
          events.add(
            TimelineEvent(
              id: 'client_${client.id}',
              title: 'عميل جديد',
              description: 'تم إضافة عميل جديد: ${client.name}',
              timestamp: client.createdAt!,
              type: EventType.client,
              relatedId: client.id,
              metadata: {
                'clientName': client.name,
                'phoneNumber': client.phoneNumber,
              },
            ),
          );
        }
      }

      // Sort by timestamp (newest first)
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return events.take(15).toList(); // Return last 15 events
    } catch (e) {
      log('Error generating timeline events: $e');
      return [];
    }
  }

  // Method to notify about new invoice
  Future<void> notifyNewInvoice(Invoice invoice, String? clientName) async {
    try {
      await _notificationService.notifyNewInvoice(
        invoiceId: invoice.id,
        amount: invoice.amount,
        clientName: clientName,
      );
    } catch (e) {
      log('Error sending invoice notification: $e');
    }
  }

  // Method to notify about new vault transaction
  Future<void> notifyVaultTransaction(VaultTransaction transaction) async {
    try {
      await _notificationService.notifyVaultTransaction(
        transactionId: transaction.id!,
        type: transaction.type,
        amount: transaction.amount,
        category: transaction.category,
      );
    } catch (e) {
      log('Error sending vault transaction notification: $e');
    }
  }

  // Method to notify about new client
  Future<void> notifyNewClient(Client client) async {
    try {
      await _notificationService.notifyNewClient(
        clientId: client.id,
        clientName: client.name,
      );
    } catch (e) {
      log('Error sending client notification: $e');
    }
  }

  // Method to notify about new shipment
  Future<void> notifyNewShipment(String shipmentId, String supplierName) async {
    try {
      await _notificationService.notifyNewShipment(
        shipmentId: shipmentId,
        supplierName: supplierName,
      );
    } catch (e) {
      log('Error sending shipment notification: $e');
    }
  }

  // Method to notify about inventory update
  Future<void> notifyInventoryUpdate(
    String itemId,
    String itemName,
    int quantity,
  ) async {
    try {
      await _notificationService.notifyInventoryUpdate(
        itemId: itemId,
        itemName: itemName,
        quantity: quantity,
      );
    } catch (e) {
      log('Error sending inventory notification: $e');
    }
  }

  // Test method to verify timeline events
  Future<void> testTimelineEvents() async {
    try {
      log('Testing timeline events generation...');
      final clients = await repository.getAllClients();
      final invoices = await repository.getAllInvoices();
      final vaultTransactions = await repository.getVaultTransactions();

      final events = await _generateTimelineEvents(
        invoices: invoices,
        vaultTransactions: vaultTransactions,
        clients: clients,
      );

      log('Generated ${events.length} timeline events:');
      for (final event in events) {
        log('- ${event.title}: ${event.description} (${event.timestamp})');
      }
    } catch (e) {
      log('Error testing timeline events: $e');
    }
  }
}
