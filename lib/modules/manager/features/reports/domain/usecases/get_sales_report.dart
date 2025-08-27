import '../entities/sales_report_item.dart';
import '../repositories/reports_repository.dart';

class GetSalesReport {
  final ReportsRepository repository;

  GetSalesReport(this.repository);

  Future<List<SalesReportItem>> call({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    return await repository.getSalesReport(
      fromDate: fromDate,
      toDate: toDate,
      category: category,
    );
  }
}
