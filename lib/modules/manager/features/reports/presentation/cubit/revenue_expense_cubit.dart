import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_revenue_expense_report.dart';
import '../../data/repositories/reports_repository_impl.dart';
import 'revenue_expense_state.dart';

class RevenueExpenseCubit extends Cubit<RevenueExpenseState> {
  final GetRevenueExpenseReport _getRevenueExpenseReport;

  RevenueExpenseCubit()
    : _getRevenueExpenseReport = GetRevenueExpenseReport(
        ReportsRepositoryImpl.withFirebase(),
      ),
      super(RevenueExpenseInitial());

  Future<void> loadRevenueExpenseReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    emit(RevenueExpenseLoading());
    try {
      final revenueExpense = await _getRevenueExpenseReport(
        fromDate: fromDate,
        toDate: toDate,
        category: category,
      );
      emit(RevenueExpenseLoaded(revenueExpense));
    } catch (e) {
      emit(RevenueExpenseError(e.toString()));
    }
  }
}
