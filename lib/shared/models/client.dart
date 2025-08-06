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
  final List<String> history; // Existing service history
  final List<String> invoices; // Added invoice IDs

  Client({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.carType,
    this.model,
    required this.balance,
    this.email,
    this.licensePlate,
    this.notes,
    this.history = const [],
    this.invoices = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'carType': carType,
        'model': model,
        'balance': balance,
        'email': email,
        'licensePlate': licensePlate,
        'notes': notes,
        'history': history,
        'invoices': invoices,
      };

  factory Client.fromMap(String id, Map<String, dynamic> map) => Client(
        id: id,
        name: map['name'] ?? '',
        phoneNumber: map['phoneNumber'],
        carType: map['carType'] ?? '',
        model: map['model'],
        balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
        email: map['email'],
        licensePlate: map['licensePlate'],
        notes: map['notes'],
        history: List<String>.from(map['history'] ?? []),
        invoices: List<String>.from(map['invoices'] ?? []),
      );
}
