import '../../../../../../shared/models/debt_transaction.dart';
import '../../../../../../shared/models/client.dart';
import '../../../../features/vault/domain/entities/vault_transaction.dart';
import '../../../../features/vault/domain/usecases/add_vault_transaction.dart';
import '../../data/datasources/debt_transaction_datasource.dart';
import '../../../manage_clients/data/datasources/client_datasource.dart';

class SettleClientDebt {
  final DebtTransactionDataSource debtDataSource;
  final ClientDataSource clientDataSource;
  final AddVaultTransaction addVaultTransaction;

  SettleClientDebt({
    required this.debtDataSource,
    required this.clientDataSource,
    required this.addVaultTransaction,
  });

  Future<void> execute({
    required Client client,
    required double amount,
    required DebtTransactionType transactionType,
    String? notes,
  }) async {
    // Validate amount
    if (amount <= 0) {
      throw Exception('Amount must be greater than zero');
    }

    // Validate transaction type for client
    if (transactionType != DebtTransactionType.clientPayment &&
        transactionType != DebtTransactionType.clientReceipt) {
      throw Exception('Invalid transaction type for client debt settlement');
    }

    // Calculate new balance
    double newBalance = client.balance - amount; // Reduce debt
    if (newBalance < 0) {
      throw Exception('Payment amount exceeds client debt');
    }

    // Create debt transaction
    final debtTransaction = DebtTransaction(
      entityId: client.id,
      entityName: client.name,
      entityType: 'client',
      type: transactionType,
      amount: amount,
      previousBalance: client.balance,
      newBalance: newBalance,
      date: DateTime.now(),
      notes: notes,
    );

    // Create vault transaction
    final vaultTransaction = VaultTransaction(
      type: debtTransaction.vaultTransactionType,
      category: debtTransaction.vaultTransactionCategory,
      amount: amount,
      date: DateTime.now(),
      notes: debtTransaction.vaultTransactionNotes,
      sourceId: debtTransaction.id,
      runningBalance: 0.0, // Will be calculated by vault datasource
    );

    // Execute transactions in a batch
    try {
      // Add debt transaction
      await debtDataSource.addDebtTransaction(debtTransaction);

      // Add vault transaction
      await addVaultTransaction.execute(vaultTransaction);

      // Update client balance
      final updatedClient = Client(
        id: client.id,
        name: client.name,
        phoneNumber: client.phoneNumber,
        cars: client.cars,
        balance: newBalance,
        email: client.email,
        notes: client.notes,
        history: client.history,
        invoices: client.invoices,
      );

      await clientDataSource.updateClient(updatedClient);
    } catch (e) {
      throw Exception('Failed to settle client debt: $e');
    }
  }
}
