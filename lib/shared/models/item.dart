class Item {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String? description;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'price': price,
    'description': description,
  };

  factory Item.fromMap(String id, Map<String, dynamic> map) => Item(
    id: id,
    name: map['name'] ?? '',
    quantity: map['quantity'] ?? 0,
    price: (map['price'] is int)
        ? (map['price'] as int).toDouble()
        : (map['price'] ?? 0.0),
    description: map['description'],
  );
}
