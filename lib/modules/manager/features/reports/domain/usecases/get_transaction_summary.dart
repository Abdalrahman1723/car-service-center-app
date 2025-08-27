import '../entities/transaction_summary.dart';
import '../repositories/reports_repository.dart';

class GetTransactionSummary {
  final ReportsRepository repository;

  GetTransactionSummary(this.repository);

  Future<List<TransactionSummary>> call({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    return await repository.getTransactionSummary(
      fromDate: fromDate,
      toDate: toDate,
      category: category,
    );
  }
}
