import '../entities/net_profit.dart';
import '../repositories/reports_repository.dart';

class GetNetProfitReport {
  final ReportsRepository repository;

  GetNetProfitReport(this.repository);

  Future<NetProfit> call({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    return await repository.getNetProfitReport(
      fromDate: fromDate,
      toDate: toDate,
      category: category,
    );
  }
}
