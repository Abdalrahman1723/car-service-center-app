import '../../domain/entities/report.dart';
import '../../domain/entities/sales_report_item.dart';
import '../../domain/entities/transaction_summary.dart';
import '../../domain/entities/revenue_expense.dart';
import '../../domain/entities/item_profitability.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_datasource.dart';
import '../datasources/firebase_reports_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsDataSource dataSource;

  ReportsRepositoryImpl(this.dataSource);

  // Factory constructor to create with Firebase data source
  factory ReportsRepositoryImpl.withFirebase() {
    return ReportsRepositoryImpl(FirebaseReportsDataSource());
  }

  @override
  Future<List<Report>> getAvailableReports() async {
    return await dataSource.getAvailableReports();
  }

  @override
  Future<List<SalesReportItem>> getSalesReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    return await dataSource.getSalesReport(
      fromDate: fromDate,
      toDate: toDate,
      category: category,
    );
  }

  @override
  Future<List<TransactionSummary>> getTransactionSummary({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    return await dataSource.getTransactionSummary(
      fromDate: fromDate,
      toDate: toDate,
      category: category,
    );
  }

  @override
  Future<RevenueExpense> getRevenueExpenseReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    return await dataSource.getRevenueExpenseReport(
      fromDate: fromDate,
      toDate: toDate,
      category: category,
    );
  }

  @override
  Future<List<ItemProfitability>> getItemProfitabilityReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    return await dataSource.getItemProfitabilityReport(
      fromDate: fromDate,
      toDate: toDate,
      category: category,
    );
  }
}
