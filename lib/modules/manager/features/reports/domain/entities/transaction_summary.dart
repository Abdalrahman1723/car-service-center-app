class TransactionSummary {
  final String category;
  final double totalAmount;
  final int transactionCount;
  final String type; // 'income' or 'expense'
  final DateTime date;

  const TransactionSummary({
    required this.category,
    required this.totalAmount,
    required this.transactionCount,
    required this.type,
    required this.date,
  });
}
