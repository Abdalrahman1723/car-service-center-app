import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_available_reports.dart';
import '../../data/repositories/reports_repository_impl.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final GetAvailableReports _getAvailableReports;

  ReportsCubit()
    : _getAvailableReports = GetAvailableReports(
        ReportsRepositoryImpl.withFirebase(),
      ),
      super(ReportsInitial());

  Future<void> loadReports() async {
    emit(ReportsLoading());
    try {
      final reports = await _getAvailableReports(null);
      emit(ReportsLoaded(reports));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }
}
