import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routes.dart';
import '../cubit/suppliers_cubit.dart';
import '../widgets/supplier_card.dart';

// Screen to display all suppliers
class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _filteredSuppliers = [];
  bool _showOnlyDebtors = false;

  @override
  void initState() {
    context.read<SuppliersCubit>().loadSuppliers();
    super.initState();
    // Automatically load suppliers when the screen initializes
    _searchController.addListener(_filterSuppliers);
  }

  void _filterSuppliers() {
    final query = _searchController.text.toLowerCase();
    final state = context.read<SuppliersCubit>().state;
    if (state is SuppliersLoaded) {
      setState(() {
        List<dynamic> suppliers = state.suppliers;

        // Apply debt filter first
        if (_showOnlyDebtors) {
          suppliers = suppliers
              .where((supplier) => supplier.balance != 0)
              .toList();
        }

        // Then apply search filter
        if (query.isNotEmpty) {
          suppliers = suppliers.where((supplier) {
            final name = supplier.name.toLowerCase();
            final phone = supplier.phoneNumber.toLowerCase();
            return name.contains(query) || phone.contains(query);
          }).toList();
        }

        _filteredSuppliers = suppliers;
      });
    }
  }

  double _calculateTotalDebt(List<dynamic> suppliers) {
    return suppliers
        .where((supplier) => supplier.balance != 0)
        .fold(0.0, (sum, supplier) => sum + supplier.balance);
  }

  int _getDebtorsCount(List<dynamic> suppliers) {
    return suppliers.where((supplier) => supplier.balance != 0).length;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Suppliers',
            onPressed: () {
              context.read<SuppliersCubit>().loadSuppliers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name or Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
          ),
          // Debt Filter and Summary
          BlocBuilder<SuppliersCubit, SuppliersState>(
            builder: (context, state) {
              if (state is SuppliersLoaded) {
                final totalDebt = _calculateTotalDebt(state.suppliers);
                final debtorsCount = _getDebtorsCount(state.suppliers);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildDebtFilterAndSummary(
                    context,
                    totalDebt,
                    debtorsCount,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: BlocConsumer<SuppliersCubit, SuppliersState>(
              listener: (context, state) {
                if (state is SuppliersError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is SuppliersSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                if (state is SuppliersLoaded) {
                  setState(() {
                    List<dynamic> suppliers = state.suppliers;

                    // Apply debt filter first
                    if (_showOnlyDebtors) {
                      suppliers = suppliers
                          .where((supplier) => supplier.balance != 0)
                          .toList();
                    }

                    // Then apply search filter
                    if (_searchController.text.isNotEmpty) {
                      suppliers = suppliers.where((supplier) {
                        final name = supplier.name.toLowerCase();
                        final phone = supplier.phoneNumber.toLowerCase();
                        final query = _searchController.text.toLowerCase();
                        return name.contains(query) || phone.contains(query);
                      }).toList();
                    }

                    _filteredSuppliers = suppliers;
                  });
                }
              },
              builder: (context, state) {
                if (state is SuppliersLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SuppliersLoaded) {
                  if (_filteredSuppliers.isEmpty &&
                      _searchController.text.isEmpty &&
                      !_showOnlyDebtors) {
                    _filteredSuppliers = state.suppliers;
                  }
                  if (_filteredSuppliers.isEmpty) {
                    return const Center(child: Text('No suppliers found'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredSuppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = _filteredSuppliers[index];
                      return SupplierCard(
                        supplier: supplier,
                        onEdit: () {
                          Navigator.pushNamed(
                            context,
                            Routes.addSupplier,
                            arguments: {'supplier': supplier, 'isEdit': true},
                          );
                        },
                        onDelete: () => showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Delete Supplier'),
                            content: Text(
                              'Are you sure you want to delete ${supplier.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              //delete button
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<SuppliersCubit>().deleteSupplier(
                                    supplier.id,
                                  );
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Tap to load suppliers'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.addSupplier),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDebtFilterAndSummary(
    BuildContext context,
    double totalDebt,
    int debtorsCount,
  ) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Debt Filter Toggle
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _showOnlyDebtors,
                        onChanged: (value) {
                          setState(() {
                            _showOnlyDebtors = value ?? false;
                          });
                          _filterSuppliers();
                        },
                      ),
                      const Text('Show suppliers we owe money to'),
                    ],
                  ),
                ),
                if (_showOnlyDebtors || _searchController.text.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showOnlyDebtors = false;
                        _searchController.clear();
                      });
                      _filterSuppliers();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Filters'),
                  ),
              ],
            ),
            // Debt Summary
            if (debtorsCount > 0) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount Owed:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${totalDebt.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Number of suppliers:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$debtorsCount suppliers',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
