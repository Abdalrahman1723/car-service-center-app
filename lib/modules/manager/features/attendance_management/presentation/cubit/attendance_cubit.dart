import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/manager/features/attendance_management/data/repositories/attendance_repository_impl.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/entities/attendance.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/usecases/check_in.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/usecases/check_out.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/usecases/get_all_attendance.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/usecases/get_attendance.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/usecases/mark_absence.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/usecases/update_compensation_status.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  late final AttendanceRepositoryImpl _repository;

  late final GetAttendance _getAttendance;
  late final GetAllAttendance _getAllAttendance;
  late final CheckIn _checkIn;
  late final CheckOut _checkOut;
  late final MarkAbsence _markAbsence;
  late final UpdateCompensationStatus _updateCompensationStatus;
  StreamSubscription<List<Attendance>>? _attendanceSubscription;

  AttendanceCubit() : super(AttendanceLoading()) {
    _repository = AttendanceRepositoryImpl();
    _getAttendance = GetAttendance(_repository);
    _getAllAttendance = GetAllAttendance(_repository);
    _checkIn = CheckIn(_repository);
    _checkOut = CheckOut(_repository);
    _markAbsence = MarkAbsence(_repository);
    _updateCompensationStatus = UpdateCompensationStatus(_repository);
  }

  void startListening({
    String? employeeId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    bool allEmployees = false,
  }) {
    emit(AttendanceLoading());
    try {
      _attendanceSubscription?.cancel();
      final stream = allEmployees
          ? _getAllAttendance(startDate: startDate, endDate: endDate)
          : _getAttendance(
              employeeId: employeeId ?? '',
              status: status,
              startDate: startDate,
              endDate: endDate,
            );
      _attendanceSubscription = stream.listen(
        (attendance) {
          final weeklySummary = allEmployees
              ? calculateAllEmployeesSummary(attendance)
              : calculateWeeklySummary(attendance);
          final groupedAttendance = groupAttendanceByDate(attendance);
          emit(
            AttendanceLoaded(
              attendance: attendance,
              groupedAttendance: groupedAttendance,
              totalHours: weeklySummary['totalHours']!,
              totalOvertime: weeklySummary['totalOvertime']!,
              totalLateMinutes: weeklySummary['totalLateMinutes']!,
              attendancePercentage: weeklySummary['attendancePercentage']!,
            ),
          );
        },
        onError: (e) {
          log('Stream attendance error: $e');
          emit(AttendanceError('Failed to load attendance: $e'));
        },
      );
    } catch (e) {
      log('Start listening attendance error: $e');
      emit(AttendanceError('Failed to start listening: $e'));
    }
  }

  Future<void> checkIn(String employeeId, DateTime checkInTime) async {
    emit(AttendanceLoading());
    try {
      await _checkIn(employeeId, checkInTime);
      emit(AttendanceSuccess('Checked in successfully'));
    } catch (e) {
      log('Check-in error: $e');
      emit(AttendanceError('Failed to check in: $e'));
    }
  }

  Future<void> checkOut(String attendanceId, DateTime checkOutTime) async {
    emit(AttendanceLoading());
    try {
      await _checkOut(attendanceId, checkOutTime);
      emit(AttendanceSuccess('Checked out successfully'));
    } catch (e) {
      log('Check-out error: $e');
      emit(AttendanceError('Failed to check out: $e'));
    }
  }

  Future<void> markAbsence(
    String employeeId,
    DateTime date,
    String reason,
  ) async {
    emit(AttendanceLoading());
    try {
      await _markAbsence(employeeId, date, reason);
      emit(AttendanceSuccess('Absence marked successfully'));
    } catch (e) {
      log('Mark absence error: $e');
      emit(AttendanceError('Failed to mark absence: $e'));
    }
  }

  Future<void> updateCompensationStatus(
    String attendanceId,
    String status,
  ) async {
    emit(AttendanceLoading());
    try {
      await _updateCompensationStatus(attendanceId, status);
      emit(AttendanceSuccess('Compensation status updated successfully'));
    } catch (e) {
      log('Update compensation status error: $e');
      emit(AttendanceError('Failed to update compensation status: $e'));
    }
  }

  Map<String, dynamic> calculateWeeklySummary(List<Attendance> attendance) {
    double totalHours = 0.0;
    double totalOvertime = 0.0;
    int totalLateMinutes = 0;
    int totalDays = 0;
    int attendedDays = 0;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    for (var record in attendance) {
      if (record.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          record.date.isBefore(weekEnd.add(const Duration(days: 1)))) {
        totalDays++;
        if (record.absenceReason == null) {
          attendedDays++;
          totalHours +=
              record.extraHours +
              (record.checkOutTime != null && record.checkInTime != null
                  ? record.checkOutTime!
                        .difference(record.checkInTime!)
                        .inHours
                        .toDouble()
                  : 0.0);
          totalOvertime += record.extraHours;
          totalLateMinutes += record.lateMinutes;
        }
      }
    }

    final attendancePercentage = totalDays > 0
        ? (attendedDays / totalDays) * 100
        : 0.0;

    return {
      'totalHours': totalHours,
      'totalOvertime': totalOvertime,
      'totalLateMinutes': totalLateMinutes,
      'attendancePercentage': attendancePercentage,
    };
  }

  Map<String, dynamic> calculateAllEmployeesSummary(
    List<Attendance> attendance,
  ) {
    double totalHours = 0.0;
    double totalOvertime = 0.0;
    int totalLateMinutes = 0;
    int totalDays = 0;
    int attendedDays = 0;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    for (var record in attendance) {
      if (record.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          record.date.isBefore(weekEnd.add(const Duration(days: 1)))) {
        totalDays++;
        if (record.absenceReason == null) {
          attendedDays++;
          totalHours +=
              record.extraHours +
              (record.checkOutTime != null && record.checkInTime != null
                  ? record.checkOutTime!
                        .difference(record.checkInTime!)
                        .inHours
                        .toDouble()
                  : 0.0);
          totalOvertime += record.extraHours;
          totalLateMinutes += record.lateMinutes;
        }
      }
    }

    final attendancePercentage = totalDays > 0
        ? (attendedDays / totalDays) * 100
        : 0.0;

    return {
      'totalHours': totalHours,
      'totalOvertime': totalOvertime,
      'totalLateMinutes': totalLateMinutes,
      'attendancePercentage': attendancePercentage,
    };
  }

  Map<String, List<Attendance>> groupAttendanceByDate(
    List<Attendance> attendance,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    final grouped = <String, List<Attendance>>{
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Last Week': [],
      'Older': [],
    };

    for (var record in attendance) {
      final date = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      if (date == today) {
        grouped['Today']!.add(record);
      } else if (date == yesterday) {
        grouped['Yesterday']!.add(record);
      } else if (date.isAfter(thisWeekStart) && date.isBefore(today)) {
        grouped['This Week']!.add(record);
      } else if (date.isAfter(lastWeekStart) && date.isBefore(thisWeekStart)) {
        grouped['Last Week']!.add(record);
      } else {
        grouped['Older']!.add(record);
      }
    }

    return grouped;
  }

  @override
  Future<void> close() {
    _attendanceSubscription?.cancel();
    return super.close();
  }
}
