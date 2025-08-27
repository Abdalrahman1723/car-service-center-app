class ItemProfitability {
  final String itemName;
  final String itemCode;
  final double cost;
  final double sellingPrice;
  final int quantitySold;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double profitMargin;

  const ItemProfitability({
    required this.itemName,
    required this.itemCode,
    required this.cost,
    required this.sellingPrice,
    required this.quantitySold,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitMargin,
  });
}
