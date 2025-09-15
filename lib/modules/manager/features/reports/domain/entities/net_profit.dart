class NetProfit {
  final double totalSales;
  final double totalPayments;
  final double totalGoodsCost;
  final double endingInventoryCost;
  final double suppliersDebt;
  final double clientsDebt;
  final double netProfit;
  final DateTime periodStart;
  final DateTime periodEnd;

  const NetProfit({
    required this.totalSales,
    required this.totalPayments,
    required this.totalGoodsCost,
    required this.endingInventoryCost,
    required this.suppliersDebt,
    required this.clientsDebt,
    required this.netProfit,
    required this.periodStart,
    required this.periodEnd,
  });
}
