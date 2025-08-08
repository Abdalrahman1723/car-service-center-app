// Supplier entity for domain layer
class SupplierEntity {
  final String id;
  final String name;
  final String phoneNumber;
  final List<String> items;
  final double balance;
  final String? notes;
  final DateTime createdAt;

  SupplierEntity({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.items,
    this.balance = 0.0,
    this.notes,
    required this.createdAt,
  });
}