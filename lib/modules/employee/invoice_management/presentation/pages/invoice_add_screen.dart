import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/shared/models/item.dart';

import '../../../../../shared/models/client.dart';
import '../../../../manager/features/inventory/domain/entities/inventory_entity.dart';
import '../cubit/invoice_management_cubit.dart';

// Screen to add a new invoice for a client
class InvoiceAddScreen extends StatefulWidget {
  const InvoiceAddScreen({super.key});

  @override
  InvoiceAddScreenState createState() => InvoiceAddScreenState();
}

class InvoiceAddScreenState extends State<InvoiceAddScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClientId;
  final _amountController = TextEditingController();
  final _maintenanceByController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isPaid = false;
  String? _paymentMethod;
  final _discountController = TextEditingController();
  final List<Item> _items = [];
  InventoryEntity? _inventory;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    context.read<InvoiceManagementCubit>().loadClients();
    context.read<InvoiceManagementCubit>().loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Invoice')),
      body: BlocConsumer<InvoiceManagementCubit, InvoiceManagementState>(
        listener: (context, state) {
          if (state is InvoiceManagementSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is InvoiceManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is InvoiceManagementInventoryLoaded) {
            _inventory = state.inventory;
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Client dropdown
                  _buildClientDropdown(state),
                  const SizedBox(height: 16),
                  // Amount field
                  TextFormField(
                    controller: _amountController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    validator: (value) =>
                        value!.isEmpty ? 'Amount is required' : null,
                  ),
                  const SizedBox(height: 16),
                  // Maintenance by field
                  TextFormField(
                    controller: _maintenanceByController,
                    decoration: const InputDecoration(
                      labelText: 'Maintenance By *',
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Maintenance By is required' : null,
                  ),
                  const SizedBox(height: 16),
                  // Items selection
                  _buildItemsSelection(),
                  const SizedBox(height: 16),
                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Is Paid checkbox
                  CheckboxListTile(
                    title: const Text('Is Paid'),
                    value: _isPaid,
                    onChanged: (value) => setState(() => _isPaid = value!),
                  ),
                  // Payment method dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                    ),
                    items: ['Cash', 'Credit Card', 'Bank Transfer']
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _paymentMethod = value),
                  ),
                  const SizedBox(height: 16),
                  // Discount field
                  TextFormField(
                    controller: _discountController,
                    // deduct disscount from the total amount
                    onChanged: (value) {
                      setState(() {
                        totalAmount -= double.tryParse(value) ?? 0.0;
                        _amountController.text = totalAmount.toString();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Discount (amount)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  // Submit button
                  ElevatedButton(
                    onPressed: state is InvoiceManagementLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              if (_selectedClientId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a client'),
                                  ),
                                );
                                return;
                              }
                              final amount =
                                  double.tryParse(_amountController.text) ??
                                  0.0;
                              final discount = double.tryParse(
                                _discountController.text,
                              );
                              context.read<InvoiceManagementCubit>().addInvoice(
                                clientId: _selectedClientId!,
                                amount: amount,
                                maintenanceBy: _maintenanceByController.text,
                                items: _items,
                                notes: _notesController.text.isEmpty
                                    ? null
                                    : _notesController.text,
                                isPaid: _isPaid,
                                paymentMethod: _paymentMethod,
                                discount: discount,
                              );
                            }
                          },
                    child: state is InvoiceManagementLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Invoice'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Client dropdown with name and phone number
  Widget _buildClientDropdown(InvoiceManagementState state) {
    List<Client> clients = [];
    if (state is InvoiceManagementClientsLoaded) {
      clients = state.clients;
    }
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Select Client *'),
      items: clients
          .map(
            (client) => DropdownMenuItem(
              value: client.phoneNumber,
              child: Text(
                '${client.name} (${client.phoneNumber ?? 'No Phone'})',
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedClientId = value),
      validator: (value) => value == null ? 'Client is required' : null,
    );
  }

  // Items selection (from inventory and external items)
  Widget _buildItemsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: const Text(
            'Items',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return ListTile(
            title: Text(item.name),
            subtitle: Text('Price: \$${item.price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() {
                _items.removeAt(index);
                //deduct the item price from the total amount
                totalAmount -= item.price;
                _amountController.text = totalAmount.toString();
              }),
            ),
          );
        }),
        TextButton(
          onPressed: () => _showItemDialog(context),
          child: const Text('Add Item'),
        ),
      ],
    );
  }

  // Dialog to add inventory or external item
  void _showItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    bool isInventoryItem = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<bool>(
                value: isInventoryItem,
                items: [
                  const DropdownMenuItem(
                    value: true,
                    child: Text('From Inventory'),
                  ),
                  const DropdownMenuItem(
                    value: false,
                    child: Text('External Item'),
                  ),
                ],
                onChanged: (value) => setDialogState(() {
                  isInventoryItem = value!;
                }),
              ),
              SizedBox(height: 10),
              //-------from inventory
              if (isInventoryItem)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Item'),
                  items:
                      _inventory?.items
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text('${item.name} (\$${item.price})'),
                            ),
                          )
                          .toList() ??
                      [],
                  onChanged: (value) {
                    if (value != null && _inventory != null) {
                      final item = _inventory!.items.firstWhere(
                        (i) => i.id == value,
                      );
                      nameController.text = item.name;
                      priceController.text = item.price.toString();
                    }
                  },
                )
              else ...[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                SizedBox(height: 8),

                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
          actions: [
            //cancel button
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            //add button
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  setState(() {
                    _items.add(
                      Item(
                        id: DateTime.now().toString(),
                        name: nameController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        timeAdded: DateTime.now(),
                        quantity: 1,
                      ),
                    );

                    totalAmount += double.tryParse(priceController.text) ?? 0.0;
                    _amountController.text = totalAmount.toString();
                  });
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
