import '../repositories/attendance_repository.dart';

class CheckIn {
  final AttendanceRepository repository;

  CheckIn(this.repository);

  Future<void> call(String employeeId, DateTime checkInTime) async {
    await repository.checkIn(employeeId, checkInTime);
  }
}
