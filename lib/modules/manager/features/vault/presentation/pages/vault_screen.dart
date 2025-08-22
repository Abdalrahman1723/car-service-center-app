import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/core/utils/app_transactions.dart';
import '../../../../../../config/routes.dart';
import '../../domain/entities/vault_transaction.dart';
import '../cubit/vault_cubit.dart';
import '../cubit/vault_state.dart';
import '../widgets/date_divider.dart';
import '../widgets/export_button.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/transaction_card.dart';

class VaultTransactionsScreen extends StatefulWidget {
  const VaultTransactionsScreen({super.key});

  @override
  State<VaultTransactionsScreen> createState() =>
      _VaultTransactionsScreenState();
}

class _VaultTransactionsScreenState extends State<VaultTransactionsScreen> {
  String? _selectedType;
  String? _selectedCategory;
  List<VaultTransaction> allTransactions = [];

  // Available filter options
  final List<String> _transactionTypes = ['income', 'expense'];
  // This list contains all transaction categories for use in dropdowns or forms.

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VaultCubit()..getTransactions(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حركات الخزينة'),
          actions: [
            // Reload Button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<VaultCubit>().getTransactions();
              },
            ),
          ],
        ),
        body: BlocListener<VaultCubit, VaultState>(
          listener: (context, state) {
            if (state is UpdatingTransaction) {
              _showSnackbar(context, 'جاري تحديث الحركة...', isError: false);
            } else if (state is DeletingTransaction) {
              _showSnackbar(context, 'جاري حذف الحركة...', isError: false);
            } else if (state is VaultLoaded) {
              // Store all transactions for filtering
              allTransactions = state.transactions;
            } else if (state is VaultError) {
              _showSnackbar(context, 'خطأ: ${state.message}', isError: true);
              log("Error in VaultTransactionsScreen: ${state.message}");
            }
          },
          child: BlocBuilder<VaultCubit, VaultState>(
            builder: (context, state) {
              if (state is VaultLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is VaultLoaded) {
                final totalBalance = state.transactions.isNotEmpty
                    ? state.transactions.first.runningBalance
                    : 0.0;

                // Apply filters to transactions
                final filteredTransactions = _applyFilters(state.transactions);
                final groupedFilteredTransactions = _groupTransactionsByDate(
                  filteredTransactions,
                );

                return Column(
                  children: [
                    // Display Total Vault Balance
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Theme.of(context).cardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إجمالي الرصيد:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${totalBalance.toStringAsFixed(2)} ${AppStrings.currency}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: totalBalance >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Enhanced Search and Filter Bar
                    _buildEnhancedFilterBar(context),
                    ExportButton(transactions: filteredTransactions),
                    Expanded(
                      child: groupedFilteredTransactions.isEmpty
                          ? _buildEmptyFilterState(context)
                          : ListView.builder(
                              itemCount: groupedFilteredTransactions.length,
                              itemBuilder: (context, index) {
                                final groupKey = groupedFilteredTransactions
                                    .keys
                                    .elementAt(index);
                                final groupTxs =
                                    groupedFilteredTransactions[groupKey]!;
                                return SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DateDivider(label: groupKey),
                                      ...groupTxs.map(
                                        (tx) => TransactionCard(
                                          transaction: tx,
                                          onEdit: () =>
                                              _showEditDialog(context, tx),
                                          onDelete: () =>
                                              _showDeleteConfirmation(
                                                context,
                                                tx.id!,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              } else if (state is VaultError) {
                return Center(child: Text('خطأ: ${state.message}'));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(Routes.addVaultTransaction),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  List<VaultTransaction> _applyFilters(List<VaultTransaction> transactions) {
    return transactions.where((transaction) {
      // Apply type filter
      if (_selectedType != null && transaction.type != _selectedType) {
        return false;
      }

      // Apply category filter
      if (_selectedCategory != null &&
          transaction.category != _selectedCategory) {
        return false;
      }

      return true;
    }).toList();
  }

  Map<String, List<VaultTransaction>> _groupTransactionsByDate(
    List<VaultTransaction> transactions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final Map<String, List<VaultTransaction>> grouped = {};

    for (var tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String groupKey;

      if (txDate == today) {
        groupKey = 'اليوم';
      } else if (txDate == yesterday) {
        groupKey = 'أمس';
      } else if (txDate.isAfter(
        thisWeekStart.subtract(const Duration(days: 1)),
      )) {
        groupKey = 'هذا الأسبوع';
      } else if (txDate.isAfter(
        lastWeekStart.subtract(const Duration(days: 1)),
      )) {
        groupKey = 'الأسبوع الماضي';
      } else {
        groupKey = '${tx.date.day}/${tx.date.month}/${tx.date.year}';
      }

      grouped.putIfAbsent(groupKey, () => []).add(tx);
    }

    return grouped;
  }

  Widget _buildEnhancedFilterBar(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        color: Theme.of(context).colorScheme.surfaceVariant,
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              SearchFilterBar(
                onSearch: (query) =>
                    context.read<VaultCubit>().searchTransactions(query),
                onFilter: (from, to) => context
                    .read<VaultCubit>()
                    .getTransactions(fromDate: from, toDate: to),
              ),
              const SizedBox(height: 16),
              // Type and Category Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع الحركة',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          alignment: Alignment.center,
                          child: Text('جميع الأنواع'),
                        ),
                        ..._transactionTypes.map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type == 'income' ? 'دخل' : 'مصروف'),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'الفئة',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('جميع الفئات'),
                        ),
                        ...AppTransactions.transactionCategories.map(
                          (category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Clear Filters Button
              if (_selectedType != null || _selectedCategory != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedType = null;
                        _selectedCategory = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('مسح الفلاتر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حركات تطابق الفلاتر المحددة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تعديل الفلاتر أو مسحها',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Dialog to edit a transaction
  void _showEditDialog(BuildContext context, VaultTransaction tx) {
    final TextEditingController amountController = TextEditingController(
      text: tx.amount.toString(),
    );
    final TextEditingController notesController = TextEditingController(
      text: tx.notes ?? '',
    );
    String selectedCategory = tx.category;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('تعديل الحركة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                ),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'Shipment', child: Text('شحنة')),
                    DropdownMenuItem(
                      value: 'Invoice',
                      child: Text('Job order'),
                    ),
                    DropdownMenuItem(value: 'Salary', child: Text('راتب')),
                    DropdownMenuItem(
                      value: 'Office Expense',
                      child: Text('مصروفات مكتبية'),
                    ),
                    DropdownMenuItem(value: 'Other', child: Text('أخرى')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      selectedCategory = val;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                final updatedTx = tx.copyWith(
                  amount: double.tryParse(amountController.text) ?? tx.amount,
                  notes: notesController.text,
                  category: selectedCategory,
                );
                context.read<VaultCubit>().updateTransaction(updatedTx);
                Navigator.pop(ctx);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );
  }

  // Dialog to confirm deletion
  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحركة'),
        content: const Text('هل أنت متأكد من حذف هذه الحركة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<VaultCubit>().deleteTransaction(id);
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
