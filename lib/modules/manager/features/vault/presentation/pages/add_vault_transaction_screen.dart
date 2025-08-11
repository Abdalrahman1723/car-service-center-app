import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/vault_transaction.dart';
import '../cubit/vault_cubit.dart';
import '../cubit/vault_state.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'income';
  String? _category;
  double _amount = 0;
  String? _notes;
  String? _sourceId;

  // List of valid categories for the dropdown
  final List<String> categories = [
    'Shipment',
    'Invoice',
    'Salary',
    'Office Expense',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: BlocListener<VaultCubit, VaultState>(
        listener: (context, state) {
          if (state is VaultLoaded) {
            // Transaction was successfully added, navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction added successfully!')),
            );
            Navigator.pop(context);
          } else if (state is VaultError) {
            // Show an error message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  ],
                  onChanged: (val) => setState(() => _type = val!),
                  decoration: const InputDecoration(
                    labelText: 'Transaction Type',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _category = val),
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (val) =>
                      val == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (val) => _amount = double.tryParse(val) ?? 0,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (val) {
                    if (double.tryParse(val ?? '0') == null ||
                        double.parse(val!) <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  onChanged: (val) => _notes = val,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  onChanged: (val) => _sourceId = val,
                  decoration: const InputDecoration(
                    labelText: 'Source ID (optional)',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Validate the form before submitting
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final tx = VaultTransaction(
                        id: null, // Let the repository handle the ID
                        type: _type,
                        category: _category!,
                        amount: _amount,
                        date: DateTime.now(),
                        notes: _notes,
                        sourceId: _sourceId,
                        runningBalance: 0, // Will be computed in the repository
                      );
                      context.read<VaultCubit>().addTransaction(tx);
                    }
                  },
                  child: BlocBuilder<VaultCubit, VaultState>(
                    builder: (context, state) {
                      if (state is AddingTransaction) {
                        return const CircularProgressIndicator(
                          color: Colors.white,
                        );
                      }
                      return const Text('Submit');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
