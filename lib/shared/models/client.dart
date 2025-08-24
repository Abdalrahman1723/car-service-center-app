import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String name;
  final String? phoneNumber;
  final List<Map<String, String?>>
  cars; // Each car: {'type': ..., 'model': ..., 'licensePlate': ...}
  final double balance;
  final String? email;
  final String? notes;
  final List<String> history; // Existing service history
  final List<String> invoices; // Added invoice IDs
  final DateTime? createdAt; // When the client was created

  Client({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.cars = const [],
    required this.balance,
    this.email,
    this.notes,
    this.history = const [],
    this.invoices = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'cars': cars,
    'balance': balance,
    'email': email,
    'notes': notes,
    'history': history,
    'invoices': invoices,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };

  factory Client.fromMap(String id, Map<String, dynamic> map) => Client(
    id: id,
    name: map['name'] ?? '',
    phoneNumber: map['phoneNumber'],
    cars: (map['cars'] as List<dynamic>? ?? [])
        .map((car) => Map<String, String?>.from(car as Map))
        .toList(),
    balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
    email: map['email'],
    notes: map['notes'],
    history: List<String>.from(map['history'] ?? []),
    invoices: List<String>.from(map['invoices'] ?? []),
    createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
  );

  factory Client.fromFirestore(Map<String, dynamic> data, String id) {
    return Client(
      id: id,
      name: data['name'] ?? '',
      cars: (data['cars'] as List<dynamic>? ?? [])
          .map((car) => Map<String, String?>.from(car as Map))
          .toList(),
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
