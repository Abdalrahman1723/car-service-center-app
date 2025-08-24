import '../../../../../../shared/models/debt_transaction.dart';
import '../../../../features/vault/domain/entities/vault_transaction.dart';
import '../../../../features/vault/domain/usecases/add_vault_transaction.dart';
import '../../data/datasources/debt_transaction_datasource.dart';
import '../../../../../employee/supplier_management/data/datasources/supplier_datasource.dart';
import '../../../../../employee/supplier_management/domain/entities/supplier.dart';
import '../../../../../employee/supplier_management/data/models/supplier_model.dart';

class SettleSupplierDebt {
  final DebtTransactionDataSource debtDataSource;
  final SupplierDataSource supplierDataSource;
  final AddVaultTransaction addVaultTransaction;

  SettleSupplierDebt({
    required this.debtDataSource,
    required this.supplierDataSource,
    required this.addVaultTransaction,
  });

  Future<void> execute({
    required SupplierEntity supplier,
    required double amount,
    required DebtTransactionType transactionType,
    String? notes,
  }) async {
    // Validate amount
    if (amount <= 0) {
      throw Exception('Amount must be greater than zero');
    }

    // Validate transaction type for supplier
    if (transactionType != DebtTransactionType.supplierPayment &&
        transactionType != DebtTransactionType.supplierReceipt) {
      throw Exception('Invalid transaction type for supplier debt settlement');
    }

    // Calculate new balance
    double newBalance = supplier.balance - amount; // Reduce debt
    if (newBalance < 0) {
      throw Exception('Payment amount exceeds supplier debt');
    }

    // Create debt transaction
    final debtTransaction = DebtTransaction(
      entityId: supplier.id,
      entityName: supplier.name,
      entityType: 'supplier',
      type: transactionType,
      amount: amount,
      previousBalance: supplier.balance,
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

      // Update supplier balance - convert to SupplierModel for datasource
      final updatedSupplier = SupplierModel(
        id: supplier.id,
        name: supplier.name,
        phoneNumber: supplier.phoneNumber,
        balance: newBalance,
        notes: supplier.notes,
        createdAt: supplier.createdAt,
      );

      await supplierDataSource.updateSupplier(updatedSupplier);
    } catch (e) {
      throw Exception('Failed to settle supplier debt: $e');
    }
  }
}
