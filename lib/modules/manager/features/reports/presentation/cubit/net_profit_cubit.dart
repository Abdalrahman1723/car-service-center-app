import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_net_profit_report.dart';
import '../../data/repositories/reports_repository_impl.dart';
import 'net_profit_state.dart';

class NetProfitCubit extends Cubit<NetProfitState> {
  final GetNetProfitReport _getNetProfitReport;

  NetProfitCubit()
    : _getNetProfitReport = GetNetProfitReport(
        ReportsRepositoryImpl.withFirebase(),
      ),
      super(NetProfitInitial());

  Future<void> loadNetProfit({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    emit(NetProfitLoading());
    try {
      final result = await _getNetProfitReport(
        fromDate: fromDate,
        toDate: toDate,
        category: category,
      );
      emit(NetProfitLoaded(result));
    } catch (e) {
      emit(NetProfitError(e.toString()));
    }
  }
}
