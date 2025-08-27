import '../entities/item_profitability.dart';
import '../repositories/reports_repository.dart';

class GetItemProfitabilityReport {
  final ReportsRepository repository;

  GetItemProfitabilityReport(this.repository);

  Future<List<ItemProfitability>> call({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    return await repository.getItemProfitabilityReport(
      fromDate: fromDate,
      toDate: toDate,
      category: category,
    );
  }
}
