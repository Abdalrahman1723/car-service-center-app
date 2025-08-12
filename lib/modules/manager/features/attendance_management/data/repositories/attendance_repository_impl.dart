import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceDataSource dataSource;

  AttendanceRepositoryImpl():dataSource = AttendanceDataSource(firestore:FirebaseFirestore.instance );

  @override
  Stream<List<Attendance>> getAttendance({
    required String employeeId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return dataSource.streamAttendance(
      employeeId: employeeId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Stream<List<Attendance>> getAllAttendance({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return dataSource.streamAllAttendance(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<void> checkIn(String employeeId, DateTime checkInTime) {
    return dataSource.checkIn(employeeId, checkInTime);
  }

  @override
  Future<void> checkOut(String attendanceId, DateTime checkOutTime) {
    return dataSource.checkOut(attendanceId, checkOutTime);
  }

  @override
  Future<void> markAbsence(String employeeId, DateTime date, String reason) {
    return dataSource.markAbsence(employeeId, date, reason);
  }

  @override
  Future<void> updateCompensationStatus(String attendanceId, String status) {
    return dataSource.updateCompensationStatus(attendanceId, status);
  }
}
