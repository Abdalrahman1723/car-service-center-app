import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_world/shared/models/item.dart';
import 'package:m_world/shared/models/client.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../config/routes.dart';
import '../cubit/invoice_management_cubit.dart';

// Screen to add a new invoice for a client
class InvoiceAddScreen extends StatefulWidget {
  final Map<String, dynamic>? draftData; // Optional draft data to populate form

  const InvoiceAddScreen({super.key, this.draftData});

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
  DateTime? _issueDate;
  late String selectedClientName;
  @override
  void initState() {
    super.initState();
    context.read<InvoiceManagementCubit>().loadClients();
    context.read<InvoiceManagementCubit>().loadInventory();
    // Populate form with draft data if provided

    if (widget.draftData != null) {
      _loadDraftData();
      log("draft loaded");
    } else {}
  }

  void _loadDraftData() {
    final draft = widget.draftData!;
    setState(() {
      _selectedClientId = draft['clientId'];
      _amountController.text = draft['amount']?.toString() ?? '0.0';
      _maintenanceByController.text = draft['maintenanceBy'] ?? '';
      _notesController.text = draft['notes'] ?? '';
      _isPaid = draft['isPaid'] ?? false;
      _paymentMethod = draft['paymentMethod'];
      _discountController.text = draft['discount']?.toString() ?? '';
      _issueDate = draft['issueDate'] != null
          ? DateTime.parse(draft['issueDate'])
          : null;
      totalAmount = draft['amount']?.toDouble() ?? 0.0;
      _items.clear();
      if (draft['items'] != null) {
        _items.addAll(
          (draft['items'] as List)
              .map(
                (item) => Item(
                  id: item['id'],
                  name: item['name'],
                  price: item['price'].toDouble(),
                  timeAdded: DateTime.parse(item['timeAdded']),
                  quantity: item['quantity'],
                ),
              )
              .toList(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isFormValid =
        _items.isNotEmpty && (_isPaid ? _paymentMethod != null : true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.drafts),
            onPressed: () =>
                Navigator.pushNamed(context, Routes.invoiceDraftList),
          ),
        ],
      ),
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
                  // Issue Date field
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Issue Date *',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _issueDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() => _issueDate = date);
                          }
                        },
                      ),
                    ),
                    controller: TextEditingController(
                      text: _issueDate != null
                          ? DateFormat.yMMMd().format(_issueDate!)
                          : '',
                    ),
                    validator: (value) =>
                        _issueDate == null ? 'Issue Date is required' : null,
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
                    validator: (value) => _isPaid && value == null
                        ? 'Payment Method is required when paid'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Discount field
                  TextFormField(
                    controller: _discountController,
                    onChanged: (discount) {
                      setState(() {
                        final discountValue = double.tryParse(discount) ?? 0.0;
                        final discountedAmount = totalAmount - discountValue;
                        if (_amountController.text !=
                            discountedAmount.toString()) {
                          _amountController.text = discountedAmount.toString();
                          _amountController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: _amountController.text.length),
                          );
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Discount (amount)',
                      fillColor: _discountController.text.isEmpty
                          ? Colors.blueGrey.withOpacity(0.23)
                          : Colors.green.withOpacity(0.25),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Amount field
                  TextFormField(
                    enabled: false,
                    controller: _amountController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Amount is required' : null,
                  ),
                  const SizedBox(height: 24),
                  // Submit and Draft buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed:
                            (state is InvoiceManagementLoading || !isFormValid)
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
                                  context
                                      .read<InvoiceManagementCubit>()
                                      .addInvoice(
                                        clientId: _selectedClientId!,
                                        amount: amount,
                                        maintenanceBy:
                                            _maintenanceByController.text,
                                        items: _items,
                                        notes: _notesController.text.isEmpty
                                            ? null
                                            : _notesController.text,
                                        isPaid: _isPaid,
                                        paymentMethod: _paymentMethod,
                                        discount: discount,
                                        issueDate: _issueDate ?? DateTime.now(),
                                      );
                                }
                              },
                        child: state is InvoiceManagementLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Add Invoice'),
                      ),
                      //----------draft button
                      ElevatedButton(
                        onPressed: state is InvoiceManagementLoading
                            ? null
                            : () async {
                                final draft = {
                                  'id': DateTime.now().toString(),
                                  'clientId': _selectedClientId,
                                  'amount': double.tryParse(
                                    _amountController.text,
                                  ),
                                  'maintenanceBy':
                                      _maintenanceByController.text,
                                  'items': _items
                                      .map((item) => item.toMap())
                                      .toList(),
                                  'notes': _notesController.text.isEmpty
                                      ? null
                                      : _notesController.text,
                                  'isPaid': _isPaid,
                                  'clientName':
                                      (state is InvoiceManagementClientsLoaded &&
                                          _selectedClientId != null)
                                      ? state.clients
                                            .firstWhere(
                                              (element) =>
                                                  element.phoneNumber ==
                                                  _selectedClientId,
                                            )
                                            .name
                                      : null,
                                  'paymentMethod': _paymentMethod,
                                  'discount': double.tryParse(
                                    _discountController.text,
                                  ),
                                  'issueDate': _issueDate?.toIso8601String(),
                                  'createdAt': DateTime.now().toIso8601String(),
                                };
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final drafts =
                                    prefs.getStringList('invoice_drafts') ?? [];
                                drafts.add(jsonEncode(draft));
                                await prefs.setStringList(
                                  'invoice_drafts',
                                  drafts,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invoice saved as draft'),
                                  ),
                                );
                              },
                        child: const Text('Save Draft'),
                      ),
                    ],
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
      items: clients.map((client) {
        return DropdownMenuItem(
          value: client.phoneNumber,
          child: Text('${client.name} (${client.phoneNumber ?? 'No Phone'})'),
        );
      }).toList(),
      onChanged: (value) => setState(() {
        _selectedClientId = value;
      }),
      validator: (value) => value == null ? 'Client is required' : null,
    );
  }

  // Items selection (from inventory and external items)
  Widget _buildItemsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Center(
          child: Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Row(
            children: [
              // Item name and price
              Expanded(
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text('Price: \$${item.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() {
                      _items.removeAt(index);
                      totalAmount -= item.price * item.quantity;
                      _amountController.text = totalAmount.toString();
                      _discountController.clear();
                    }),
                  ),
                ),
              ),
              // Show quantity in a styled box
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 20.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blueAccent, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.confirmation_number,
                        size: 18,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Qty: ${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Decrease and increase quantity buttons
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                if (item.quantity > 1) {
                                  item.quantity--;
                                  totalAmount -= item.price;
                                  _amountController.text = totalAmount
                                      .toString();
                                  _discountController.clear();
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              setState(() {
                                item.quantity++;
                                totalAmount += item.price;
                                _amountController.text = totalAmount.toString();
                                _discountController.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                items: const [
                  DropdownMenuItem(value: true, child: Text('From Inventory')),
                  DropdownMenuItem(value: false, child: Text('External Item')),
                ],
                onChanged: (value) =>
                    setDialogState(() => isInventoryItem = value!),
              ),
              const SizedBox(height: 10),
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
                      _discountController.clear();
                    }
                  },
                )
              else ...[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  setState(() {
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    _items.add(
                      Item(
                        id: DateTime.now().toString(),
                        name: nameController.text,
                        price: price,
                        timeAdded: DateTime.now(),
                        quantity: 1,
                      ),
                    );
                    totalAmount += price;
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
