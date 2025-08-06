import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/models/client.dart';
import '../../../../../shared/models/invoice.dart';
import '../../../../../shared/models/item.dart';
import '../../../../manager/features/manage_clients/domain/usecases/get_all_clients.dart';
import '../../../../manager/features/inventory/domain/entities/inventory_entity.dart';
import '../../../../manager/features/inventory/domain/repositories/inventory_repository.dart';
import '../../domain/usecases/add_invoice.dart';
import '../../domain/usecases/get_all_invoices.dart';
part 'invoice_management_state.dart';

// Cubit for managing invoice operations
class InvoiceManagementCubit extends Cubit<InvoiceManagementState> {
  final AddInvoice addInvoiceUseCase;
  final GetAllInvoices getAllInvoicesUseCase;
  final GetAllClients getAllClientsUseCase;
  final InventoryRepository inventoryRepository;

  InvoiceManagementCubit({
    required this.addInvoiceUseCase,
    required this.getAllInvoicesUseCase,
    required this.getAllClientsUseCase,
    required this.inventoryRepository,
  }) : super(InvoiceManagementInitial());

  // Add a new invoice and update client history
  Future<void> addInvoice({
    required String clientId,
    required double amount,
    required String maintenanceBy,
    required List<Item> items,
    String? notes,
    bool isPaid = false,
    String? paymentMethod,
    double? discount,
  }) async {
    emit(InvoiceManagementLoading());
    try {
      final invoice = Invoice(
        id: DateTime.now().toString(),
        clientId: clientId,
        amount: amount,
        maintenanceBy: maintenanceBy,
        items: items,
        notes: notes,
        isPaid: isPaid,
        paymentMethod: paymentMethod,
        discount: discount,
      );
      await addInvoiceUseCase(invoice);
      emit(InvoiceManagementSuccess('Invoice added successfully'));
    } catch (e) {
      emit(InvoiceManagementError(e.toString()));
    }
  }

  // Load all invoices
  Future<void> loadInvoices() async {
    emit(InvoiceManagementLoading());
    try {
      final invoices = await getAllInvoicesUseCase();
      emit(InvoiceManagementInvoicesLoaded(invoices));
    } catch (e) {
      emit(InvoiceManagementError(e.toString()));
    }
  }

  // Load all clients for dropdown
  Future<void> loadClients() async {
    emit(InvoiceManagementLoading());
    try {
      final clients = await getAllClientsUseCase();
      emit(InvoiceManagementClientsLoaded(clients));
    } catch (e) {
      emit(InvoiceManagementError(e.toString()));
    }
  }

  // Load inventory data
  Future<void> loadInventory() async {
    emit(InvoiceManagementLoading());
    try {
      final inventory = await inventoryRepository.getInventory();
      emit(InvoiceManagementInventoryLoaded(inventory));
    } catch (e) {
      emit(InvoiceManagementError(e.toString()));
    }
  }
}
