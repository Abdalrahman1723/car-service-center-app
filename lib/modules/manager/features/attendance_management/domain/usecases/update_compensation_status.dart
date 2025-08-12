import '../repositories/attendance_repository.dart';

class UpdateCompensationStatus {
  final AttendanceRepository repository;

  UpdateCompensationStatus(this.repository);

  Future<void> call(String attendanceId, String status) async {
    await repository.updateCompensationStatus(attendanceId, status);
  }
}
