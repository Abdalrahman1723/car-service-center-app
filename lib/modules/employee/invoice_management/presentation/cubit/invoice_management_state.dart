part of 'invoice_management_cubit.dart';

abstract class InvoiceManagementState {}

class InvoiceManagementInitial extends InvoiceManagementState {}

class InvoiceManagementLoading extends InvoiceManagementState {}

class InvoiceManagementSuccess extends InvoiceManagementState {
  final String message;
  InvoiceManagementSuccess(this.message);
}

class InvoiceManagementError extends InvoiceManagementState {
  final String message;
  InvoiceManagementError(this.message);
}

class InvoiceManagementInvoicesLoaded extends InvoiceManagementState {
  final List<Invoice> invoices;
  InvoiceManagementInvoicesLoaded(this.invoices);
}

class InvoiceManagementClientsLoaded extends InvoiceManagementState {
  final List<Client> clients;
  InvoiceManagementClientsLoaded(this.clients);
}

class InvoiceManagementInventoryLoaded extends InvoiceManagementState {
  final InventoryEntity inventory;
  InvoiceManagementInventoryLoaded(this.inventory);
}
