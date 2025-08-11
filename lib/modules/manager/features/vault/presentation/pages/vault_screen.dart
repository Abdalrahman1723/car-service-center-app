import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VaultCubit()..getTransactions(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vault Transactions'),
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
              _showSnackbar(context, 'Updating transaction...', isError: false);
            } else if (state is DeletingTransaction) {
              _showSnackbar(context, 'Deleting transaction...', isError: false);
            } else if (state is VaultLoaded) {
              // Only show a success message after an action, not on initial load
              // You can check a flag or state variable if needed.
            } else if (state is VaultError) {
              _showSnackbar(context, 'Error: ${state.message}', isError: true);
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
                            'Total Balance:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${totalBalance.toStringAsFixed(2)}',
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
                    SearchFilterBar(
                      onSearch: (query) =>
                          context.read<VaultCubit>().searchTransactions(query),
                      onFilter: (from, to) => context
                          .read<VaultCubit>()
                          .getTransactions(fromDate: from, toDate: to),
                    ),
                    ExportButton(transactions: state.transactions),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.groupedTransactions.length,
                        itemBuilder: (context, index) {
                          final groupKey = state.groupedTransactions.keys
                              .elementAt(index);
                          final groupTxs = state.groupedTransactions[groupKey]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DateDivider(label: groupKey),
                              ...groupTxs.map(
                                (tx) => TransactionCard(
                                  transaction: tx,
                                  onEdit: () => _showEditDialog(context, tx),
                                  onDelete: () =>
                                      _showDeleteConfirmation(context, tx.id!),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else if (state is VaultError) {
                return Center(child: Text('Error: ${state.message}'));
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
          title: const Text('Edit Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(
                      value: 'Shipment',
                      child: Text('Shipment'),
                    ),
                    DropdownMenuItem(value: 'Invoice', child: Text('Invoice')),
                    DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                    DropdownMenuItem(
                      value: 'Office Expense',
                      child: Text('Office Expense'),
                    ),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
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
              child: const Text('Cancel'),
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
              child: const Text('Save'),
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
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<VaultCubit>().deleteTransaction(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
