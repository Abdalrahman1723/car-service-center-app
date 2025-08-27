import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_item_profitability_report.dart';
import '../../data/repositories/reports_repository_impl.dart';
import 'item_profitability_state.dart';

class ItemProfitabilityCubit extends Cubit<ItemProfitabilityState> {
  final GetItemProfitabilityReport _getItemProfitabilityReport;

  ItemProfitabilityCubit()
    : _getItemProfitabilityReport = GetItemProfitabilityReport(
        ReportsRepositoryImpl.withFirebase(),
      ),
      super(ItemProfitabilityInitial());

  Future<void> loadItemProfitabilityReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    emit(ItemProfitabilityLoading());
    try {
      final items = await _getItemProfitabilityReport(
        fromDate: fromDate,
        toDate: toDate,
        category: category,
      );
      emit(ItemProfitabilityLoaded(items));
    } catch (e) {
      emit(ItemProfitabilityError(e.toString()));
    }
  }
}
