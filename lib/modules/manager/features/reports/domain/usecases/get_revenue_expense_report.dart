import '../entities/revenue_expense.dart';
import '../repositories/reports_repository.dart';

class GetRevenueExpenseReport {
  final ReportsRepository repository;

  GetRevenueExpenseReport(this.repository);

  Future<RevenueExpense> call({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    return await repository.getRevenueExpenseReport(
      fromDate: fromDate,
      toDate: toDate,
      category: category,
    );
  }
}
