import 'package:equatable/equatable.dart';

class Reservation extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String carType;
  final String problem;
  final DateTime visitDate;
  final String? inquiries;
  final DateTime createdAt;

  const Reservation({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.carType,
    required this.problem,
    required this.visitDate,
    this.inquiries,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'carType': carType,
      'problem': problem,
      'visitDate': visitDate.toIso8601String(),
      'inquiries': inquiries,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'] as String,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      carType: map['carType'] as String,
      problem: map['problem'] as String,
      visitDate: DateTime.parse(map['visitDate'] as String),
      inquiries: map['inquiries'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    carType,
    problem,
    visitDate,
    inquiries,
    createdAt,
  ];
}
