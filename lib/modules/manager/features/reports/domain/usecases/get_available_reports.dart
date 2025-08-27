import 'package:m_world/core/usecases/usecase.dart';
import '../entities/report.dart';
import '../repositories/reports_repository.dart';

class GetAvailableReports implements UseCase<List<Report>, void> {
  final ReportsRepository repository;

  GetAvailableReports(this.repository);

  @override
  Future<List<Report>> call(void params) async {
    return await repository.getAvailableReports();
  }
}
