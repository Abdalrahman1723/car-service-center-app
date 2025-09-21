import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/constants/app_strings.dart';
import '../cubit/net_profit_cubit.dart';
import '../cubit/net_profit_state.dart';
import '../widgets/report_filter_widget.dart';

class NetProfitScreen extends StatefulWidget {
  const NetProfitScreen({super.key});

  @override
  State<NetProfitScreen> createState() => _NetProfitScreenState();
}

class _NetProfitScreenState extends State<NetProfitScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetProfitCubit>().loadNetProfit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'صافي الربح',
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
            availableCategories: const [],
            onApplyFilter: (from, to, category) {
              setState(() {
                fromDate = from;
                toDate = to;
                selectedCategory = category;
              });
              context.read<NetProfitCubit>().loadNetProfit(
                fromDate: from,
                toDate: to,
                category: category,
              );
            },
            onClearFilter: () {
              setState(() {
                fromDate = null;
                toDate = null;
                selectedCategory = null;
              });
              context.read<NetProfitCubit>().loadNetProfit();
            },
            title: 'تصفية صافي الربح',
          ),
        ],
      ),
      body: BlocConsumer<NetProfitCubit, NetProfitState>(
        listener: (context, state) {
          if (state is NetProfitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NetProfitLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            );
          }

          if (state is NetProfitLoaded) {
            return _buildContent(context, state);
          }

          if (state is NetProfitError) {
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
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<NetProfitCubit>().loadNetProfit(
                          fromDate: fromDate,
                          toDate: toDate,
                          category: selectedCategory,
                        ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, NetProfitLoaded state) {
    final net = state.netProfit;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryCard(
            title: 'ملخص الفترة',
            children: [
              _row('من', _formatDate(net.periodStart)),
              _row('إلى', _formatDate(net.periodEnd)),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'القيم الرئيسية',
            children: [
              _row(
                'إجمالي المبيعات',
                '${net.totalSales.toStringAsFixed(2)} ${AppStrings.currency}',
              ),
              _row(
                'إجمالي المدفوعات',
                '${net.totalPayments.toStringAsFixed(2)} ${AppStrings.currency}',
              ),
              _row(
                'إجمالي تكلفة البضائع',
                '${net.totalGoodsCost.toStringAsFixed(2)} ${AppStrings.currency}',
              ),
              _row(
                'ديون الموردين',
                '${net.suppliersDebt.toStringAsFixed(2)} ${AppStrings.currency}',
              ),
              _row(
                'ديون العملاء',
                '${net.clientsDebt.toStringAsFixed(2)} ${AppStrings.currency}',
              ),
            ],
          ),
          const SizedBox(height: 12),

          _SummaryCard(
            title: 'قيمة المخزون',
            children: [
              _row(
                'إجمالي قيمة المخزون',
                '${net.endingInventoryCost.toStringAsFixed(2)} ${AppStrings.currency}',
                highlight: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'صافي الربح',
            highlight: true,
            children: [
              _row(
                'الصافي',
                '${net.netProfit.toStringAsFixed(2)} ${AppStrings.currency}',
                large: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  Widget _row(
    String label,
    String value, {
    bool large = false,
    bool highlight = false,
  }) {
    final bool isNetProfitRow = large && label == 'الصافي';
    final bool isNegative = isNetProfitRow && value.startsWith('-');
    final Color valueColor = isNetProfitRow
        ? (isNegative ? const Color(0xFFC62828) : const Color(0xFF2E7D32))
        : highlight
        ? const Color(0xFF1976D2)
        : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: large ? 20 : 16,
              fontWeight: large || highlight
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool highlight;

  const _SummaryCard({
    required this.title,
    required this.children,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight ? const Color(0xFFE8F5E9) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: highlight ? const Color(0xFF2E7D32) : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
