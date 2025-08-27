import '../../domain/entities/report.dart';
import '../../domain/entities/sales_report_item.dart';
import '../../domain/entities/transaction_summary.dart';
import '../../domain/entities/revenue_expense.dart';
import '../../domain/entities/item_profitability.dart';

abstract class ReportsDataSource {
  Future<List<Report>> getAvailableReports();
  Future<List<SalesReportItem>> getSalesReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  });
  Future<List<TransactionSummary>> getTransactionSummary({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  });
  Future<RevenueExpense> getRevenueExpenseReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  });
  Future<List<ItemProfitability>> getItemProfitabilityReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  });
}

class MockReportsDataSource implements ReportsDataSource {
  @override
  Future<List<Report>> getAvailableReports() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const Report(
        id: 'sales',
        title: 'تقرير المبيعات',
        description: 'تفاصيل المبيعات مع الأرباح والتكاليف',
        icon: 'receipt_long',
        route: '/reports/sales',
      ),
      const Report(
        id: 'transactions',
        title: 'ملخص المعاملات',
        description: 'ملخص جميع المعاملات المالية',
        icon: 'account_balance_wallet',
        route: '/reports/transactions',
      ),
      const Report(
        id: 'revenue_expense',
        title: 'الإيرادات مقابل المصروفات',
        description: 'مقارنة الإيرادات والمصروفات',
        icon: 'trending_up',
        route: '/reports/revenue-expense',
      ),
      const Report(
        id: 'profitability',
        title: 'تقرير ربحية المنتجات',
        description: 'ربحية كل منتج في المخزون',
        icon: 'inventory',
        route: '/reports/profitability',
      ),
    ];
  }

  @override
  Future<List<SalesReportItem>> getSalesReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      SalesReportItem(
        itemName: 'زيت محرك',
        price: 150.0,
        cost: 100.0,
        quantity: 10,
        profit: 50.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SalesReportItem(
        itemName: 'فلتر هواء',
        price: 80.0,
        cost: 50.0,
        quantity: 15,
        profit: 30.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SalesReportItem(
        itemName: 'شمعات إشعال',
        price: 120.0,
        cost: 80.0,
        quantity: 8,
        profit: 40.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      SalesReportItem(
        itemName: 'فرامل',
        price: 300.0,
        cost: 200.0,
        quantity: 5,
        profit: 100.0,
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  @override
  Future<List<TransactionSummary>> getTransactionSummary({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      TransactionSummary(
        category: 'job order',
        totalAmount: 5000.0,
        transactionCount: 25,
        type: 'income',
        date: DateTime.now(),
      ),
      TransactionSummary(
        category: 'مشتريات',
        totalAmount: 2000.0,
        transactionCount: 15,
        type: 'expense',
        date: DateTime.now(),
      ),
      TransactionSummary(
        category: 'المرتبات',
        totalAmount: 3000.0,
        transactionCount: 8,
        type: 'expense',
        date: DateTime.now(),
      ),
      TransactionSummary(
        category: 'م.الصنايعية',
        totalAmount: 1500.0,
        transactionCount: 12,
        type: 'expense',
        date: DateTime.now(),
      ),
    ];
  }

  @override
  Future<RevenueExpense> getRevenueExpenseReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final items = [
      RevenueExpenseItem(
        category: 'job order',
        amount: 5000.0,
        type: 'revenue',
      ),
      RevenueExpenseItem(category: 'مشتريات', amount: 2000.0, type: 'expense'),
      RevenueExpenseItem(category: 'المرتبات', amount: 3000.0, type: 'expense'),
      RevenueExpenseItem(
        category: 'م.الصنايعية',
        amount: 1500.0,
        type: 'expense',
      ),
    ];

    final totalRevenue = items
        .where((item) => item.type == 'revenue')
        .fold(0.0, (sum, item) => sum + item.amount);
    final totalExpenses = items
        .where((item) => item.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);

    return RevenueExpense(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netProfit: totalRevenue - totalExpenses,
      period: DateTime.now(),
      items: items,
    );
  }

  @override
  Future<List<ItemProfitability>> getItemProfitabilityReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    return [
      ItemProfitability(
        itemName: 'زيت محرك',
        itemCode: 'OIL001',
        cost: 100.0,
        sellingPrice: 150.0,
        quantitySold: 50,
        totalRevenue: 7500.0,
        totalCost: 5000.0,
        totalProfit: 2500.0,
        profitMargin: 33.33,
      ),
      ItemProfitability(
        itemName: 'فلتر هواء',
        itemCode: 'FIL001',
        cost: 50.0,
        sellingPrice: 80.0,
        quantitySold: 30,
        totalRevenue: 2400.0,
        totalCost: 1500.0,
        totalProfit: 900.0,
        profitMargin: 37.5,
      ),
      ItemProfitability(
        itemName: 'شمعات إشعال',
        itemCode: 'SPK001',
        cost: 80.0,
        sellingPrice: 120.0,
        quantitySold: 20,
        totalRevenue: 2400.0,
        totalCost: 1600.0,
        totalProfit: 800.0,
        profitMargin: 33.33,
      ),
      ItemProfitability(
        itemName: 'فرامل',
        itemCode: 'BRK001',
        cost: 200.0,
        sellingPrice: 300.0,
        quantitySold: 10,
        totalRevenue: 3000.0,
        totalCost: 2000.0,
        totalProfit: 1000.0,
        profitMargin: 33.33,
      ),
    ];
  }
}
