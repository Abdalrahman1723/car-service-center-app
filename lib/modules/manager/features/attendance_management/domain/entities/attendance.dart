import 'package:equatable/equatable.dart';

class Attendance extends Equatable {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool isLate;
  final int lateMinutes;
  final bool leftEarly;
  final int earlyMinutes;
  final double extraHours;
  final String? absenceReason;
  final String
  compensationStatus; // On Time, Late – Compensated, Late – Not Compensated

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.isLate = false,
    this.lateMinutes = 0,
    this.leftEarly = false,
    this.earlyMinutes = 0,
    this.extraHours = 0.0,
    this.absenceReason,
    this.compensationStatus = 'On Time',
  });

  factory Attendance.fromMap(String id, Map<String, dynamic> map) {
    return Attendance(
      id: id,
      employeeId: map['employeeId'] as String,
      date: DateTime.parse(map['date'] as String),
      checkInTime: map['checkInTime'] != null
          ? DateTime.parse(map['checkInTime'] as String)
          : null,
      checkOutTime: map['checkOutTime'] != null
          ? DateTime.parse(map['checkOutTime'] as String)
          : null,
      isLate: map['isLate'] as bool? ?? false,
      lateMinutes: map['lateMinutes'] as int? ?? 0,
      leftEarly: map['leftEarly'] as bool? ?? false,
      earlyMinutes: map['earlyMinutes'] as int? ?? 0,
      extraHours: (map['extraHours'] as num?)?.toDouble() ?? 0.0,
      absenceReason: map['absenceReason'] as String?,
      compensationStatus: map['compensationStatus'] as String? ?? 'On Time',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'isLate': isLate,
      'lateMinutes': lateMinutes,
      'leftEarly': leftEarly,
      'earlyMinutes': earlyMinutes,
      'extraHours': extraHours,
      'absenceReason': absenceReason,
      'compensationStatus': compensationStatus,
    };
  }

  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? isLate,
    int? lateMinutes,
    bool? leftEarly,
    int? earlyMinutes,
    double? extraHours,
    String? absenceReason,
    String? compensationStatus,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isLate: isLate ?? this.isLate,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      leftEarly: leftEarly ?? this.leftEarly,
      earlyMinutes: earlyMinutes ?? this.earlyMinutes,
      extraHours: extraHours ?? this.extraHours,
      absenceReason: absenceReason ?? this.absenceReason,
      compensationStatus: compensationStatus ?? this.compensationStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    date,
    checkInTime,
    checkOutTime,
    isLate,
    lateMinutes,
    leftEarly,
    earlyMinutes,
    extraHours,
    absenceReason,
    compensationStatus,
  ];
}
