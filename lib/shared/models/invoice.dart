class Invoice {
  final String id;
  final String clientId;
  final double amount;
  final DateTime date;

  Invoice({required this.id, required this.clientId, required this.amount, required this.date});

  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory Invoice.fromMap(String id, Map<String, dynamic> map) => Invoice(
        id: id,
        clientId: map['clientId'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
      );
}