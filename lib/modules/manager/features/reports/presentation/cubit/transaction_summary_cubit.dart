import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_transaction_summary.dart';
import '../../data/repositories/reports_repository_impl.dart';
import 'transaction_summary_state.dart';

class TransactionSummaryCubit extends Cubit<TransactionSummaryState> {
  final GetTransactionSummary _getTransactionSummary;

    TransactionSummaryCubit() 
      : _getTransactionSummary = GetTransactionSummary(
          ReportsRepositoryImpl.withFirebase(),
        ),
        super(TransactionSummaryInitial());

  Future<void> loadTransactionSummary({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    emit(TransactionSummaryLoading());
    try {
      final transactions = await _getTransactionSummary(
        fromDate: fromDate,
        toDate: toDate,
        category: category,
      );

      final totalIncome = transactions
          .where((t) => t.type == 'income')
          .fold(0.0, (sum, t) => sum + t.totalAmount);

      final totalExpenses = transactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.totalAmount);

      emit(
        TransactionSummaryLoaded(
          transactions: transactions,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
        ),
      );
    } catch (e) {
      emit(TransactionSummaryError(e.toString()));
    }
  }
}
