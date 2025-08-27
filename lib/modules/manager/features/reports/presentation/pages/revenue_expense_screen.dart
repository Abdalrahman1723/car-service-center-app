import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/constants/app_strings.dart';
import '../cubit/revenue_expense_cubit.dart';
import '../cubit/revenue_expense_state.dart';
import '../widgets/report_filter_widget.dart';

class RevenueExpenseScreen extends StatefulWidget {
  const RevenueExpenseScreen({super.key});

  @override
  State<RevenueExpenseScreen> createState() => _RevenueExpenseScreenState();
}

class _RevenueExpenseScreenState extends State<RevenueExpenseScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedCategory;
  List<String> availableCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RevenueExpenseCubit>().loadRevenueExpenseReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإيرادات مقابل المصروفات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          ReportFilterWidget(
            fromDate: fromDate,
            toDate: toDate,
            selectedCategory: selectedCategory,
            availableCategories: availableCategories,
            onApplyFilter: (fromDate, toDate, category) {
              setState(() {
                this.fromDate = fromDate;
                this.toDate = toDate;
                this.selectedCategory = category;
              });
              context.read<RevenueExpenseCubit>().loadRevenueExpenseReport(
                fromDate: fromDate,
                toDate: toDate,
                category: category,
              );
            },
            onClearFilter: () {
              setState(() {
                fromDate = null;
                toDate = null;
                selectedCategory = null;
              });
              context.read<RevenueExpenseCubit>().loadRevenueExpenseReport();
            },
            title: 'تصفية الإيرادات والمصروفات',
          ),
        ],
      ),
      body: BlocConsumer<RevenueExpenseCubit, RevenueExpenseState>(
        listener: (context, state) {
          if (state is RevenueExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RevenueExpenseLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            );
          }

          if (state is RevenueExpenseLoaded) {
            // Update available categories from loaded data
            if (availableCategories.isEmpty) {
              availableCategories = state.revenueExpense.items
                  .map((item) => item.category)
                  .toSet()
                  .toList();
            }
            return _buildRevenueExpenseContent(context, state);
          }

          if (state is RevenueExpenseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<RevenueExpenseCubit>()
                          .loadRevenueExpenseReport(
                            fromDate: fromDate,
                            toDate: toDate,
                          );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('لا توجد بيانات'));
        },
      ),
    );
  }

  Widget _buildRevenueExpenseContent(
    BuildContext context,
    RevenueExpenseLoaded state,
  ) {
    final revenueExpense = state.revenueExpense;
    final netProfit = revenueExpense.netProfit;
    final isProfit = netProfit >= 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Summary Cards
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'ملخص الإيرادات والمصروفات',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'إجمالي الإيرادات',
                          '${revenueExpense.totalRevenue.toStringAsFixed(2)} ${AppStrings.currency}',
                          Icons.trending_up,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'إجمالي المصروفات',
                          '${revenueExpense.totalExpenses.toStringAsFixed(2)} ${AppStrings.currency}',
                          Icons.trending_down,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    'صافي الربح',
                    '${netProfit.toStringAsFixed(2)} ${AppStrings.currency}',
                    isProfit ? Icons.attach_money : Icons.money_off,
                    isProfit ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
            // Items List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Color(0xFF1976D2),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'تفاصيل الإيرادات والمصروفات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          if (fromDate != null || toDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'مفلتر',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF1976D2),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: revenueExpense.items.length,
                        itemBuilder: (context, index) {
                          final item = revenueExpense.items[index];
                          return _buildRevenueExpenseCard(item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueExpenseCard(item) {
    final isRevenue = item.type == 'revenue';
    final color = isRevenue ? Colors.green : Colors.red;
    final icon = isRevenue ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRevenue ? 'إيراد' : 'مصروف',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${item.amount.toStringAsFixed(2)} ${AppStrings.currency}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
