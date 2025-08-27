import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/sales_report_item.dart';
import '../../domain/entities/transaction_summary.dart';
import '../../domain/entities/revenue_expense.dart';
import '../../domain/entities/item_profitability.dart';
import '../datasources/reports_datasource.dart';
import '../../../../../../shared/models/invoice.dart';

class FirebaseReportsDataSource implements ReportsDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get available reports (static data)
  @override
  Future<List<Report>> getAvailableReports() async {
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

  // Get sales report from invoices
  @override
  Future<List<SalesReportItem>> getSalesReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('invoices')
          .orderBy('issueDate', descending: true);

      if (fromDate != null) {
        query = query.where(
          'issueDate',
          isGreaterThanOrEqualTo: fromDate.toIso8601String(),
        );
      }
      if (toDate != null) {
        query = query.where(
          'issueDate',
          isLessThanOrEqualTo: toDate.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      final List<SalesReportItem> salesItems = [];

      for (var doc in snapshot.docs) {
        final invoice = Invoice.fromMap(doc.id, doc.data());

        // Process each item in the invoice
        for (var item in invoice.items) {
          // Apply category filter if specified
          if (category != null &&
              !item.name.toLowerCase().contains(category.toLowerCase())) {
            continue;
          }

          // Calculate profit (assuming cost is available in item data)
          final cost = item.cost;
          final price = item.price ?? 0.0;
          final profit = price - cost;

          salesItems.add(
            SalesReportItem(
              itemName: item.name,
              price: price,
              cost: cost,
              quantity: item.quantity,
              profit: profit,
              date: invoice.issueDate,
            ),
          );
        }

        // Add service fees as a separate item if it exists
        if (invoice.serviceFees > 0) {
          salesItems.add(
            SalesReportItem(
              itemName: 'رسوم الخدمة',
              price: invoice.serviceFees,
              cost: 0.0, // Service fees are pure revenue
              quantity: 1,
              profit: invoice.serviceFees,
              date: invoice.issueDate,
            ),
          );
        }
      }

      return salesItems;
    } catch (e) {
      throw Exception('Failed to fetch sales report: $e');
    }
  }

  // Get transaction summary from vault transactions
  @override
  Future<List<TransactionSummary>> getTransactionSummary({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('vault')
          .orderBy('date', descending: true);

      if (fromDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
        );
      }
      if (toDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(toDate),
        );
      }

      final snapshot = await query.get();
      final Map<String, TransactionSummary> summaryMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final transactionCategory = data['category'] as String? ?? 'أخرى';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final type = data['type'] as String? ?? 'expense';
        final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();

        // Apply category filter if specified
        if (category != null && transactionCategory != category) {
          continue;
        }

        if (summaryMap.containsKey(transactionCategory)) {
          // Update existing summary
          final existing = summaryMap[transactionCategory]!;
          summaryMap[transactionCategory] = TransactionSummary(
            category: transactionCategory,
            totalAmount: existing.totalAmount + amount,
            transactionCount: existing.transactionCount + 1,
            type: type,
            date: date,
          );
        } else {
          // Create new summary
          summaryMap[transactionCategory] = TransactionSummary(
            category: transactionCategory,
            totalAmount: amount,
            transactionCount: 1,
            type: type,
            date: date,
          );
        }
      }

      return summaryMap.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch transaction summary: $e');
    }
  }

  // Get revenue vs expense report
  @override
  Future<RevenueExpense> getRevenueExpenseReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    try {
      // Get vault transactions
      final transactions = await getTransactionSummary(
        fromDate: fromDate,
        toDate: toDate,
        category: category,
      );

      final List<RevenueExpenseItem> items = [];
      double totalRevenue = 0.0;
      double totalExpenses = 0.0;

      for (var transaction in transactions) {
        items.add(
          RevenueExpenseItem(
            category: transaction.category,
            amount: transaction.totalAmount,
            type: transaction.type,
          ),
        );

        if (transaction.type == 'income') {
          totalRevenue += transaction.totalAmount;
        } else {
          totalExpenses += transaction.totalAmount;
        }
      }

      return RevenueExpense(
        totalRevenue: totalRevenue,
        totalExpenses: totalExpenses,
        netProfit: totalRevenue - totalExpenses,
        period: DateTime.now(),
        items: items,
      );
    } catch (e) {
      throw Exception('Failed to fetch revenue expense report: $e');
    }
  }

  // Get item profitability report
  @override
  Future<List<ItemProfitability>> getItemProfitabilityReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
  }) async {
    try {
      // Get sales data from invoices
      final salesItems = await getSalesReport(
        fromDate: fromDate,
        toDate: toDate,
        category: category,
      );

      // Group by item name
      final Map<String, List<SalesReportItem>> groupedItems = {};

      for (var item in salesItems) {
        if (groupedItems.containsKey(item.itemName)) {
          groupedItems[item.itemName]!.add(item);
        } else {
          groupedItems[item.itemName] = [item];
        }
      }

      final List<ItemProfitability> profitabilityItems = [];

      for (var entry in groupedItems.entries) {
        final itemName = entry.key;
        final items = entry.value;

        double totalRevenue = 0.0;
        double totalCost = 0.0;
        double totalProfit = 0.0;
        int totalQuantity = 0;
        double avgSellingPrice = 0.0;
        double avgCost = 0.0;

        for (var item in items) {
          totalRevenue += item.totalRevenue;
          totalCost += item.totalCost;
          totalProfit += item.totalProfit;
          totalQuantity += item.quantity;
        }

        if (totalQuantity > 0) {
          avgSellingPrice = totalRevenue / totalQuantity;
          avgCost = totalCost / totalQuantity;
        }

        final profitMargin = totalRevenue > 0
            ? (totalProfit / totalRevenue) * 100
            : 0.0;

        profitabilityItems.add(
          ItemProfitability(
            itemName: itemName,
            itemCode: itemName
                .substring(0, min(6, itemName.length))
                .toUpperCase(),
            cost: avgCost,
            sellingPrice: avgSellingPrice,
            quantitySold: totalQuantity,
            totalRevenue: totalRevenue,
            totalCost: totalCost,
            totalProfit: totalProfit,
            profitMargin: profitMargin,
          ),
        );
      }

      // Sort by total profit (descending)
      profitabilityItems.sort((a, b) => b.totalProfit.compareTo(a.totalProfit));

      return profitabilityItems;
    } catch (e) {
      throw Exception('Failed to fetch item profitability report: $e');
    }
  }
}

int min(int a, int b) => a < b ? a : b;
