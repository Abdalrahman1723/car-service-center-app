class Client {
  final String id;
  final String name;
  final String email;

  Client({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() => {'name': name, 'email': email};

  factory Client.fromMap(String id, Map<String, dynamic> map) =>
      Client(id: id, name: map['name'], email: map['email']);
}