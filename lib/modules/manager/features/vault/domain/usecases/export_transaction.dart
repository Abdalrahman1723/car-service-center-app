// This use case is more presentation-oriented, but as per requirements.
// Actual export logic will be in presentation layer, this can prepare data.
import '../entities/vault_transaction.dart';

class ExportVaultTransactions {
  Future<Map<String, dynamic>> execute(
    List<VaultTransaction> transactions,
  ) async {
    // Prepare data: totals, etc.
    double totalIncome = 0;
    double totalExpenses = 0;
    for (var tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else {
        totalExpenses += tx.amount;
      }
    }
    double netBalance = totalIncome - totalExpenses;
    return {
      'transactions': transactions,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netBalance': netBalance,
    };
  }
}
