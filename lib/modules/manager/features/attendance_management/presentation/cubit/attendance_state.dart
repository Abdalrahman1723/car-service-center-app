part of 'attendance_cubit.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<Attendance> attendance;
  final Map<String, List<Attendance>> groupedAttendance;
  final double totalHours;
  final double totalOvertime;
  final int totalLateMinutes;
  final double attendancePercentage;

  AttendanceLoaded({
    required this.attendance,
    required this.groupedAttendance,
    required this.totalHours,
    required this.totalOvertime,
    required this.totalLateMinutes,
    required this.attendancePercentage,
  });
}

class AttendanceSuccess extends AttendanceState {
  final String message;

  AttendanceSuccess(this.message);
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);
}
