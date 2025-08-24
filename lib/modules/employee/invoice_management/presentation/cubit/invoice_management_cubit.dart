import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    required DateTime issueDate,
    required String selectedCar, // selected car
    String? notes,
    bool isPayLater = false,
    String? paymentMethod,
    double? discount,
    double? downPayment,
  }) async {
    emit(InvoiceManagementLoading());
    try {
      final invoice = Invoice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: clientId,
        amount: amount,
        maintenanceBy: maintenanceBy,
        items: items,
        createdAt: DateTime.now(),
        issueDate: issueDate,
        notes: notes,
        isPayLater: isPayLater,
        paymentMethod: paymentMethod,
        discount: discount,
        selectedCar: selectedCar,
        downPayment: downPayment,
      );
      await addInvoiceUseCase(invoice);
      log("from cubit the invoice is : \n ${invoice.selectedCar}");

      // Update client debt if payment is deferred
      if (isPayLater) {
        final remainingAmount = amount - (downPayment ?? 0.0);
        if (remainingAmount > 0) {
          // Update client balance in Firestore
          await FirebaseFirestore.instance
              .collection('clients')
              .doc(clientId)
              .update({'balance': FieldValue.increment(remainingAmount)});
        }
      }

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
            cost: 0,
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
          cost: inventoryItem.cost,
          description: inventoryItem.description,
        );
        await inventoryRepository.updateItemInInventory(updatedItem);
        //add the amount to the vault
      }

      // Add to vault only the amount that was actually paid
      final paidAmount = isPayLater ? (downPayment ?? 0.0) : amount;
      if (paidAmount > 0) {
        await addTransaction.execute(
          VaultTransaction(
            type: "income",
            category: "job order",
            amount: paidAmount,
            date: issueDate,
            runningBalance: 0,
          ),
        );
      }

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

  //--------------------------------

  Future<void> addClient({
    required String name,
    required List<Map<String, dynamic>> cars,
    required double balance,
    String? phoneNumber,
    String? email,
    String? notes,
  }) async {
    emit(InvoiceManagementLoading());
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('clients')
          .add({
            'name': name,
            'cars': cars,
            'balance': balance,
            'phoneNumber': phoneNumber,
            'email': email,
            'notes': notes,
            'createdBy': FirebaseAuth.instance.currentUser?.uid,
          });
      final List<Client> clients = (state is InvoiceManagementClientsLoaded)
          ? List<Client>.from((state as InvoiceManagementClientsLoaded).clients)
          : [];
      clients.add(
        Client.fromFirestore(
          (await docRef.get()).data() as Map<String, dynamic>,
          docRef.id,
        ),
      );
      emit(InvoiceManagementClientsLoaded(clients));
    } catch (e) {
      emit(InvoiceManagementError('فشل في إضافة العميل: $e'));
    }
  }

  Future<void> addCarToClient(String clientId, Map<String, dynamic> car) async {
    emit(InvoiceManagementLoading());
    try {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(clientId)
          .update({
            'cars': FieldValue.arrayUnion([car]),
          });
      final List<Client> clients = (state is InvoiceManagementClientsLoaded)
          ? List<Client>.from((state as InvoiceManagementClientsLoaded).clients)
          : [];
      final clientIndex = clients.indexWhere((c) => c.id == clientId);
      if (clientIndex != -1) {
        final clientDoc = await FirebaseFirestore.instance
            .collection('clients')
            .doc(clientId)
            .get();
        clients[clientIndex] = Client.fromFirestore(
          clientDoc.data() as Map<String, dynamic>,
          clientId,
        );
        emit(InvoiceManagementClientsLoaded(clients));
      }
    } catch (e) {
      emit(InvoiceManagementError('فشل في إضافة السيارة: $e'));
    }
  }

  void loadDrafts() async {
    try {
      emit(InvoiceManagementLoading());
      final snapshot = await FirebaseFirestore.instance
          .collection('invoice_drafts')
          .orderBy('createdAt', descending: true)
          .get();
      final drafts = snapshot.docs.map((doc) => doc.data()).toList();
      emit(InvoiceManagementDraftsLoaded(drafts));
    } catch (e) {
      emit(InvoiceManagementError('Failed to load drafts: $e'));
    }
  }
}
