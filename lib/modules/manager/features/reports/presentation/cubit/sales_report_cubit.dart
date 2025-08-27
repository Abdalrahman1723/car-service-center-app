import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_sales_report.dart';
import '../../data/repositories/reports_repository_impl.dart';
import 'sales_report_state.dart';

class SalesReportCubit extends Cubit<SalesReportState> {
  final GetSalesReport _getSalesReport;

  SalesReportCubit()
    : _getSalesReport = GetSalesReport(ReportsRepositoryImpl.withFirebase()),
      super(SalesReportInitial());

  Future<void> loadSalesReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    emit(SalesReportLoading());
    try {
      final items = await _getSalesReport(
        fromDate: fromDate,
        toDate: toDate,
        category: category,
      );

      final totalRevenue = items.fold(
        0.0,
        (sum, item) => sum + item.totalRevenue,
      );
      final totalCost = items.fold(0.0, (sum, item) => sum + item.totalCost);
      final totalProfit = items.fold(
        0.0,
        (sum, item) => sum + item.totalProfit,
      );

      emit(
        SalesReportLoaded(
          items: items,
          totalRevenue: totalRevenue,
          totalCost: totalCost,
          totalProfit: totalProfit,
        ),
      );
    } catch (e) {
      emit(SalesReportError(e.toString()));
    }
  }
}
