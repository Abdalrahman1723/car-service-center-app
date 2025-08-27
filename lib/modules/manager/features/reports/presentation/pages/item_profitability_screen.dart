import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/constants/app_strings.dart';
import '../cubit/item_profitability_cubit.dart';
import '../cubit/item_profitability_state.dart';
import '../widgets/report_filter_widget.dart';

class ItemProfitabilityScreen extends StatefulWidget {
  const ItemProfitabilityScreen({super.key});

  @override
  State<ItemProfitabilityScreen> createState() =>
      _ItemProfitabilityScreenState();
}

class _ItemProfitabilityScreenState extends State<ItemProfitabilityScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedCategory;
  List<String> availableCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProfitabilityCubit>().loadItemProfitabilityReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تقرير ربحية المنتجات',
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
              context
                  .read<ItemProfitabilityCubit>()
                  .loadItemProfitabilityReport(
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
              context
                  .read<ItemProfitabilityCubit>()
                  .loadItemProfitabilityReport();
            },
            title: 'تصفية ربحية المنتجات',
          ),
        ],
      ),
      body: BlocConsumer<ItemProfitabilityCubit, ItemProfitabilityState>(
        listener: (context, state) {
          if (state is ItemProfitabilityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ItemProfitabilityLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            );
          }

          if (state is ItemProfitabilityLoaded) {
            // Update available categories from loaded data
            if (availableCategories.isEmpty) {
              availableCategories = state.items
                  .map((item) => item.itemName)
                  .toSet()
                  .toList();
            }
            return _buildItemProfitabilityContent(context, state);
          }

          if (state is ItemProfitabilityError) {
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
                          .read<ItemProfitabilityCubit>()
                          .loadItemProfitabilityReport(
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

  Widget _buildItemProfitabilityContent(
    BuildContext context,
    ItemProfitabilityLoaded state,
  ) {
    final totalProfit = state.items.fold(
      0.0,
      (sum, item) => sum + item.totalProfit,
    );
    final totalRevenue = state.items.fold(
      0.0,
      (sum, item) => sum + item.totalRevenue,
    );

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
                    'ربحية المنتجات',
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
                          'إجمالي الربح',
                          '${totalProfit.toStringAsFixed(2)} ${AppStrings.currency}',
                          Icons.trending_up,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'إجمالي الإيرادات',
                          '${totalRevenue.toStringAsFixed(2)} ${AppStrings.currency}',
                          Icons.attach_money,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    'عدد المنتجات',
                    '${state.items.length} منتج',
                    Icons.inventory,
                    Colors.orange,
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
                            Icons.inventory,
                            color: Color(0xFF1976D2),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'تفاصيل ربحية المنتجات',
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
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return _buildItemProfitabilityCard(item);
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

  Widget _buildItemProfitabilityCard(item) {
    final isProfitable = item.totalProfit > 0;
    final color = isProfitable ? Colors.green : Colors.red;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'كود: ${item.itemCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.quantitySold} قطعة',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'سعر البيع',
                    '${item.sellingPrice.toStringAsFixed(2)} ${AppStrings.currency}',
                    Icons.attach_money,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'التكلفة',
                    '${item.cost.toStringAsFixed(2)} ${AppStrings.currency}',
                    Icons.account_balance_wallet,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'الربح',
                    '${item.totalProfit.toStringAsFixed(2)} ${AppStrings.currency}',
                    Icons.trending_up,
                    color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'إجمالي الإيرادات',
                    '${item.totalRevenue.toStringAsFixed(2)} ${AppStrings.currency}',
                    Icons.receipt_long,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'هامش الربح',
                    '${item.profitMargin.toStringAsFixed(1)}%',
                    Icons.percent,
                    color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
