import 'package:m_world/shared/models/invoice.dart';

class Client {
  final String id;
  final String name;
  final String? phoneNumber;
  final String carType;
  final String? model;
  final double balance;
  final String? email;
  final String? licensePlate;
  final String? notes;
  final List<Invoice> history;
  // Updated constructor to include all fields
  Client({
    this.id = '',
    required this.name,
    this.phoneNumber,
    required this.carType,
    this.model,
    required this.balance,
    required this.email,
    this.licensePlate,
    this.notes,
    this.history = const [],
  });

  // Updated toMap to include all fields
  Map<String, dynamic> toMap() => {
        'name': name,
        'phoneNumber': phoneNumber,
        'carType': carType,
        'model': model,
        'balance': balance,
        'email': email,
        'licensePlate': licensePlate,
        'notes': notes,
        'history': history,
      };

  // Updated fromMap to include all fields
  factory Client.fromMap(String id, Map<String, dynamic> map) => Client(
        id: id,
        name: map['name'] ?? '',
        phoneNumber: map['phoneNumber'],
        carType: map['carType'] ?? '',
        model: map['model'],
        balance: (map['balance'] is int)
            ? (map['balance'] as int).toDouble()
            : (map['balance'] ?? 0.0),
        email: map['email'],
        licensePlate: map['licensePlate'],
        notes: map['notes'],
        history: (map['history'] != null && map['history'] is List)
            ? List<Invoice>.from(
                (map['history'] as List).map(
                  (e) => e is Map<String, dynamic>
                      ? Invoice.fromMap(e['id'] ?? '', e)
                      : e,
                ),
              )
            : [],
      );

}
