class Item {
  final String id;
  final String name;
  int quantity;
  late final String? code;
  final double price;
  final DateTime? timeAdded;
  final String? description;

  Item({
    required this.id,
    required this.name,
    required this.timeAdded,
    required this.quantity,
    this.code,
    required this.price,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'price': price,
    'code': code,
    'timeAdded': timeAdded?.toIso8601String(),
    'description': description,
  };

  factory Item.fromMap(String id, Map<String, dynamic> map) => Item(
    id: id,
    name: map['name'] ?? '',
    code: map['code'] ?? '',
    quantity: map['quantity'] ?? 0,
    price: (map['price'] is int)
        ? (map['price'] as int).toDouble()
        : (map['price'] ?? 0.0),
    description: map['description'],
    timeAdded: map['timeAdded'] != null
        ? (map['timeAdded'] is DateTime
              ? map['timeAdded']
              : DateTime.tryParse(map['timeAdded'].toString()))
        : null,
  );

  Item copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    DateTime? timeAdded,
    String? code,
  }) => Item(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        timeAdded: timeAdded ?? this.timeAdded,
        code: code ?? this.code,
      );
}

