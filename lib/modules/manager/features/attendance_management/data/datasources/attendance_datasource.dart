import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/entities/attendance.dart';

class AttendanceDataSource {
  final FirebaseFirestore _firestore ;
  static const String _attendanceCollection = 'attendance';

  AttendanceDataSource({required FirebaseFirestore firestore}) : _firestore = firestore;

  Stream<List<Attendance>> streamAttendance({
    required String employeeId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      var query = _firestore
          .collection(_attendanceCollection)
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('date', descending: true);
      if (status != null) query = query.where('compensationStatus', isEqualTo: status);
      if (startDate != null && endDate != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
            .where('date', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      return query.snapshots().map((snapshot) {
        final attendance = snapshot.docs.map((doc) => Attendance.fromMap(doc.id, doc.data())).toList();
        log('Streamed ${attendance.length} attendance records for employee: $employeeId');
        return attendance;
      });
    } catch (e) {
      log('Stream attendance error: $e');
      throw Exception('Failed to stream attendance: $e');
    }
  }

  Stream<List<Attendance>> streamAllAttendance({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      var query = _firestore.collection(_attendanceCollection).orderBy('date', descending: true);
      if (startDate != null && endDate != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
            .where('date', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      return query.snapshots().map((snapshot) {
        final attendance = snapshot.docs.map((doc) => Attendance.fromMap(doc.id, doc.data())).toList();
        log('Streamed ${attendance.length} attendance records for all employees');
        return attendance;
      });
    } catch (e) {
      log('Stream all attendance error: $e');
      throw Exception('Failed to stream all attendance: $e');
    }
  }

  Future<void> checkIn(String employeeId, DateTime checkInTime) async {
    try {
      final standardStart = DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 8, 0); // 8:00 AM
      final isLate = checkInTime.isAfter(standardStart);
      final lateMinutes = isLate ? checkInTime.difference(standardStart).inMinutes : 0;
      final compensationStatus = isLate ? 'Late – Not Compensated' : 'On Time';

      final attendance = Attendance(
        id: '',
        employeeId: employeeId,
        date: DateTime(checkInTime.year, checkInTime.month, checkInTime.day),
        checkInTime: checkInTime,
        isLate: isLate,
        lateMinutes: lateMinutes,
        compensationStatus: compensationStatus,
      );

      final docRef = _firestore.collection(_attendanceCollection).doc();
      await docRef.set(attendance.copyWith(id: docRef.id).toMap());
      log('Checked in employee: $employeeId at $checkInTime');
    } catch (e) {
      log('Check-in error: $e');
      throw Exception('Failed to check in: $e');
    }
  }

  Future<void> checkOut(String attendanceId, DateTime checkOutTime) async {
    try {
      final docRef = _firestore.collection(_attendanceCollection).doc(attendanceId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) throw Exception('Attendance record not found');

      final attendance = Attendance.fromMap(attendanceId, snapshot.data()!);
      final standardEnd = DateTime(checkOutTime.year, checkOutTime.month, checkOutTime.day, 16, 0); // 4:00 PM
      final isEarly = checkOutTime.isBefore(standardEnd);
      final earlyMinutes = isEarly ? standardEnd.difference(checkOutTime).inMinutes : 0;
      final hoursWorked = attendance.checkInTime != null
          ? checkOutTime.difference(attendance.checkInTime!).inHours.toDouble()
          : 0.0;
      final extraHours = hoursWorked > 8.0 ? hoursWorked - 8.0 : 0.0;

      await docRef.update({
        'checkOutTime': checkOutTime.toIso8601String(),
        'leftEarly': isEarly,
        'earlyMinutes': earlyMinutes,
        'extraHours': extraHours,
      });
      log('Checked out employee at $checkOutTime');
    } catch (e) {
      log('Check-out error: $e');
      throw Exception('Failed to check out: $e');
    }
  }

  Future<void> markAbsence(String employeeId, DateTime date, String reason) async {
    try {
      final attendance = Attendance(
        id: '',
        employeeId: employeeId,
        date: date,
        absenceReason: reason,
        compensationStatus: 'On Time',
      );
      final docRef = _firestore.collection(_attendanceCollection).doc();
      await docRef.set(attendance.copyWith(id: docRef.id).toMap());
      log('Marked absence for employee: $employeeId on $date');
    } catch (e) {
      log('Mark absence error: $e');
      throw Exception('Failed to mark absence: $e');
    }
  }

  Future<void> updateCompensationStatus(String attendanceId, String status) async {
    try {
      await _firestore.collection(_attendanceCollection).doc(attendanceId).update({
        'compensationStatus': status,
      });
      log('Updated compensation status for attendance: $attendanceId to $status');
    } catch (e) {
      log('Update compensation status error: $e');
      throw Exception('Failed to update compensation status: $e');
    }
  }
}
