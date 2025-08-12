import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class GetAllAttendance {
  final AttendanceRepository repository;

  GetAllAttendance(this.repository);

  Stream<List<Attendance>> call({DateTime? startDate, DateTime? endDate}) {
    return repository.getAllAttendance(startDate: startDate, endDate: endDate);
  }
}
