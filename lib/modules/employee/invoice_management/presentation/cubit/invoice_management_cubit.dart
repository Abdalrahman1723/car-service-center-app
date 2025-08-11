import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/manager/features/vault/domain/entities/vault_transaction.dart';
import 'package:m_world/modules/manager/features/vault/domain/usecases/add_vault_transaction.dart';
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
  final AddVaultTransaction addTransaction;

  InvoiceManagementCubit({
    required this.addInvoiceUseCase,
    required this.getAllInvoicesUseCase,
    required this.getAllClientsUseCase,
    required this.inventoryRepository,
    required this.addTransaction,
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
    DateTime? issueDate,
  }) async {
    emit(InvoiceManagementLoading());
    try {
      final invoice = Invoice(
        id: DateTime.now().toString(),
        clientId: clientId,
        amount: amount,
        maintenanceBy: maintenanceBy,
        items: items,
        creatDate: DateTime.now(),
        issueDate: issueDate,
        notes: notes,
        isPaid: isPaid,
        paymentMethod: paymentMethod,
        discount: discount,
      );
      await addInvoiceUseCase(invoice);
      // For each unique item name in the invoice items, count how many times it appears,
      // then update the inventory by decreasing the quantity accordingly.
      final Map<String, int> itemCounts = {};
      for (final item in items) {
        itemCounts[item.name] = (itemCounts[item.name] ?? 0) + item.quantity;
      }
      for (final entry in itemCounts.entries) {
        final inventory = await inventoryRepository.getInventory();
        final inventoryItem = inventory.items.firstWhere(
          (invItem) => invItem.name == entry.key,
          orElse: () => Item(
            id: '', // No inventory id for external item
            name: entry.key,
            timeAdded: DateTime.now(),
            quantity: entry.value, // Effectively unlimited for external items
            code: '',
            price: 0,
            description: 'External item',
          ),
        );
        //in case the quantity is not sufficient
        if (inventoryItem.quantity < entry.value) {
          throw Exception('Item ${entry.key} has insufficient quantity');
        }
        final updatedItem = Item(
          id: inventoryItem.id,
          name: inventoryItem.name,
          timeAdded: inventoryItem.timeAdded,
          quantity: inventoryItem.quantity - entry.value,
          code: inventoryItem.code,
          price: inventoryItem.price,
          description: inventoryItem.description,
        );
        await inventoryRepository.updateItemInInventory(updatedItem);
        //add the amount to the vault
      }
      await addTransaction.execute(
        VaultTransaction(
          type: "income",
          category: "Invoice",
          amount: amount,
          date: issueDate!,
          runningBalance: 0,
        ),
      );
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

  // Load both invoices and clients
  Future<void> loadInvoicesAndClients() async {
    emit(InvoiceManagementLoading());
    try {
      final invoices = await getAllInvoicesUseCase();
      final clients = await getAllClientsUseCase();
      emit(InvoiceManagementDataLoaded(invoices, clients));
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
