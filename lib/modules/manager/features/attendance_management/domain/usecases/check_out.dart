import '../repositories/attendance_repository.dart';

class CheckOut {
  final AttendanceRepository repository;

  CheckOut(this.repository);

  Future<void> call(String attendanceId, DateTime checkOutTime) async {
    await repository.checkOut(attendanceId, checkOutTime);
  }
}