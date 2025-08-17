class Item {
  final String id;
  final String name;
  int quantity;
  late final String? code;
  late final double? price;
  final double cost;
  final DateTime? timeAdded;
  final String? description;

  Item({
    required this.id,
    required this.name,
    required this.timeAdded,
    required this.quantity,
    this.code,
    this.price, 
    required this.cost,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'price': price,
    'cost': cost,
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
    cost: (map['cost'] is int)
        ? (map['cost'] as int).toDouble()
        : (map['cost'] ?? 0.0),
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
    double? cost,
    int? quantity,
    DateTime? timeAdded,
    String? code,
  }) => Item(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    cost: cost ?? this.cost,
    quantity: quantity ?? this.quantity,
    timeAdded: timeAdded ?? this.timeAdded,
    code: code ?? this.code,
    description: description,
  );
}
