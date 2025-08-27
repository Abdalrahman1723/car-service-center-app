class SalesReportItem {
  final String itemName;
  final double price;
  final double cost;
  final int quantity;
  final double profit;
  final DateTime date;

  const SalesReportItem({
    required this.itemName,
    required this.price,
    required this.cost,
    required this.quantity,
    required this.profit,
    required this.date,
  });

  double get totalRevenue => price * quantity;
  double get totalCost => cost * quantity;
  double get totalProfit => profit * quantity;
}
