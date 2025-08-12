import '../repositories/attendance_repository.dart';

class MarkAbsence {
  final AttendanceRepository repository;

  MarkAbsence(this.repository);

  Future<void> call(String employeeId, DateTime date, String reason) async {
    await repository.markAbsence(employeeId, date, reason);
  }
}