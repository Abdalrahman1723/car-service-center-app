class RevenueExpense {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final DateTime period;
  final List<RevenueExpenseItem> items;

  const RevenueExpense({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.period,
    required this.items,
  });
}

class RevenueExpenseItem {
  final String category;
  final double amount;
  final String type; // 'revenue' or 'expense'

  const RevenueExpenseItem({
    required this.category,
    required this.amount,
    required this.type,
  });
}
