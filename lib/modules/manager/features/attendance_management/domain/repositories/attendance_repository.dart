import 'package:m_world/modules/manager/features/attendance_management/domain/entities/attendance.dart';

abstract class AttendanceRepository {
  Stream<List<Attendance>> getAttendance({
    required String employeeId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  Stream<List<Attendance>> getAllAttendance({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> checkIn(String employeeId, DateTime checkInTime);
  Future<void> checkOut(String attendanceId, DateTime checkOutTime);
  Future<void> markAbsence(String employeeId, DateTime date, String reason);
  Future<void> updateCompensationStatus(String attendanceId, String status);
}
