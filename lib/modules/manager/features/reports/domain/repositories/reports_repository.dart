import '../entities/report.dart';
import '../entities/sales_report_item.dart';
import '../entities/transaction_summary.dart';
import '../entities/revenue_expense.dart';
import '../entities/item_profitability.dart';

abstract class ReportsRepository {
  Future<List<Report>> getAvailableReports();
  Future<List<SalesReportItem>> getSalesReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  });
  Future<List<TransactionSummary>> getTransactionSummary({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  });
  Future<RevenueExpense> getRevenueExpenseReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  });
  Future<List<ItemProfitability>> getItemProfitabilityReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  });
}
