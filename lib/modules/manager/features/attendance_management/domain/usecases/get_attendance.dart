import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class GetAttendance {
  final AttendanceRepository repository;

  GetAttendance(this.repository);

  Stream<List<Attendance>> call({
    required String employeeId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.getAttendance(
      employeeId: employeeId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
