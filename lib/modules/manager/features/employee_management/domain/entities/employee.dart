import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id; // Firebase Auth UID
  final String fullName;
  final String role; // Manager, Supervisor, Inventory Worker, Other
  final String phoneNumber;
  final String? address;
  final double? salary; // Hourly rate or monthly salary
  final bool isActive;

  const Employee({
    required this.id,
    required this.fullName,
    required this.role,
    this.address,
    this.salary,
    required this.phoneNumber,
    this.isActive = true,
  });

  factory Employee.fromMap(String id, Map<String, dynamic> map) {
    return Employee(
      id: id,
      fullName: map['fullName'] as String,
      role: map['role'] as String,
      phoneNumber: map['phoneNumber'] as String,
      address: map['address'] as String?,
      salary: (map['salary'] as num?)?.toDouble(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'role': role,
      'phoneNumber': phoneNumber,
      'address': address,
      'salary': salary,
      'isActive': isActive,
    };
  }

  Employee copyWith({
    String? id,
    String? fullName,
    String? role,
    String? phoneNumber,
    String? address,
    double? salary,
    bool? isActive,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      salary: salary ?? this.salary,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    role,
    phoneNumber,
    address,
    salary,
    isActive,
  ];
}
