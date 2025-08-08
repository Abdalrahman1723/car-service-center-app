import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes.dart';
import '../cubit/suppliers_cubit.dart';
import '../widgets/supplier_card.dart';
import 'add_supplier_screen.dart';

// Screen to display all suppliers
class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      body: BlocConsumer<SuppliersCubit, SuppliersState>(
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
        },
        builder: (context, state) {
          if (state is SuppliersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SuppliersLoaded) {
            if (state.suppliers.isEmpty) {
              return const Center(child: Text('No suppliers found'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.suppliers.length,
              itemBuilder: (context, index) {
                final supplier = state.suppliers[index];
                return SupplierCard(
                  supplier: supplier,
                  onEdit: () => showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: AddSupplierScreen(
                        supplier: supplier,
                        isEdit: true,
                      ),
                    ),
                  ),
                  onDelete: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Supplier'),
                      content: Text(
                        'Are you sure you want to delete ${supplier.name}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<SuppliersCubit>().deleteSupplier(
                              supplier.id,
                            );
                            Navigator.pop(context);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.addSupplier),
        child: const Icon(Icons.add),
      ),
    );
  }
}
