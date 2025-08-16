import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_world/modules/employee/invoice_management/presentation/widgets/invoice_export_button.dart';
import 'package:m_world/shared/models/invoice.dart';
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
  Color quantityContainerColor = Colors.blueAccent;

  // Add a new variable to track the draft ID
  String? _draftId;
  @override
  void initState() {
    super.initState();
    context.read<InvoiceManagementCubit>().loadClients();
    context.read<InvoiceManagementCubit>().loadInventory();
    if (widget.draftData != null) {
      _loadDraftData();
      log("draft loaded");
    }
  }

  void _loadDraftData() {
    final draft = widget.draftData!;
    log("the draft $draft");
    setState(() {
      _draftId = draft['id'];
      _selectedClientId = draft['clientId'] ?? ""; // Add as String?
      _amountController.text = draft['amount']?.toString() ?? '0.0';
      _maintenanceByController.text =
          draft['maintenanceBy'] as String? ?? ''; // Fix here
      _notesController.text = draft['notes'] as String? ?? ''; // Fix here
      _isPaid = draft['isPaid'] ?? false;
      _paymentMethod = draft['paymentMethod'] as String?; // Add as String?
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
        title: const Text('إضافة فاتورة جديدة'),
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
                      labelText: 'الصيانة بواسطة *',
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'حقل الصيانة مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  // Issue Date field
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'تاريخ الإصدار *',
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
                        _issueDate == null ? 'تاريخ الإصدار مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  // Items selection
                  _buildItemsSelection(),
                  const SizedBox(height: 16),
                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'ملاحظات'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Is Paid checkbox
                  CheckboxListTile(
                    title: const Text('تم الدفع'),
                    value: _isPaid,
                    onChanged: (value) => setState(() => _isPaid = value!),
                  ),
                  // Payment method dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'طريقة الدفع',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Cash',
                        child: Text('نقداً'),
                      ),
                      DropdownMenuItem(
                        value: 'Credit Card',
                        child: Text('بطاقة ائتمان'),
                      ),
                      DropdownMenuItem(
                        value: 'Bank Transfer',
                        child: Text('تحويل بنكي'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _paymentMethod = value),
                    validator: (value) => _isPaid && value == null
                        ? 'طريقة الدفع مطلوبة عند الدفع'
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
                      labelText: 'الخصم (المبلغ)',
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
                      labelText: 'المبلغ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'المبلغ مطلوب' : null,
                  ),
                  const SizedBox(height: 24),
                  // Submit and Draft buttons
                  Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    ElevatedButton(
      onPressed: (state is InvoiceManagementLoading || !isFormValid)
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                if (_selectedClientId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى اختيار العميل'),
                    ),
                  );
                  return;
                }
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                final discount = double.tryParse(_discountController.text);
                context.read<InvoiceManagementCubit>().addInvoice(
                      clientId: _selectedClientId!,
                      amount: amount,
                      maintenanceBy: _maintenanceByController.text,
                      items: _items,
                      notes: _notesController.text.isEmpty ? null : _notesController.text,
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
          : const Text('إضافة الفاتورة'),
    ),
ElevatedButton(
      onPressed: state is InvoiceManagementLoading
          ? null
          : () async {
              final String currentDraftId = _draftId ?? DateTime.now().toIso8601String();
              final draft = {
                'id': currentDraftId,
                'clientId': _selectedClientId,
                'amount': double.tryParse(_amountController.text),
                'maintenanceBy': _maintenanceByController.text,
                'items': _items.map((item) => item.toMap()).toList(),
                'notes': _notesController.text.isEmpty ? null : _notesController.text,
                'isPaid': _isPaid,
                'clientName': (state is InvoiceManagementClientsLoaded && _selectedClientId != null)
                    ? state.clients
                        .firstWhere((element) => element.phoneNumber == _selectedClientId)
                        .name
                    : null,
                'paymentMethod': _paymentMethod,
                'discount': double.tryParse(_discountController.text),
                'issueDate': _issueDate?.toIso8601String(),
                'createdAt': widget.draftData != null
                    ? widget.draftData!['createdAt']
                    : DateTime.now().toIso8601String(),
              };
              final prefs = await SharedPreferences.getInstance();
              final drafts = prefs.getStringList('invoice_drafts') ?? [];
              final existingDraftIndex = drafts.indexWhere((draftString) {
                final draftMap = jsonDecode(draftString);
                return draftMap['id'] == currentDraftId;
              });
              if (existingDraftIndex != -1) {
                drafts[existingDraftIndex] = jsonEncode(draft);
              } else {
                drafts.add(jsonEncode(draft));
              }
              await prefs.setStringList('invoice_drafts', drafts);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    existingDraftIndex != -1
                        ? 'تم تحديث المسودة بنجاح!'
                        : 'تم حفظ الفاتورة كمسودة!',
                  ),
                ),
              );
              if (_draftId == null) {
                setState(() {
                  _draftId = currentDraftId;
                });
              }
            },
      child: const Text('حفظ كمسودة'),
    ),
    InvoiceExportButton(
      clientName: (state is InvoiceManagementClientsLoaded && _selectedClientId != null)
          ? state.clients
              .firstWhere(
                (element) => element.phoneNumber == _selectedClientId,
              )
              .name
          : '',
      invoice: Invoice(
        id: '',
        clientId: _selectedClientId ?? 'N/A',
        amount: double.tryParse(_amountController.text) ?? 0.0,
        maintenanceBy: _maintenanceByController.text,
        items: _items,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isPaid: _isPaid,
        paymentMethod: _paymentMethod,
        discount: double.tryParse(_discountController.text),
        issueDate: _issueDate,
      ),
    ),
  ],
)
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
      decoration: const InputDecoration(labelText: 'اختر العميل *'),
      items: clients.map((client) {
        return DropdownMenuItem(
          value: client.phoneNumber,
          child: Text('${client.name} (${client.phoneNumber ?? 'بدون رقم'})'),
        );
      }).toList(),
      onChanged: (value) => setState(() {
        _selectedClientId = value;
      }),
      validator: (value) => value == null ? 'العميل مطلوب' : null,
    );
  }

  // Items selection (from inventory and external items)
  Widget _buildItemsSelection() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'العناصر',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12.0),
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            // Determine quantity status and color
            final inventoryItem = (() {
              try {
                return _inventory?.items.firstWhere((i) => i.name == item.name);
              } catch (e) {
                return null;
              }
            })();
            final totalQuantity = inventoryItem?.quantity ?? 0;
            final Color statusColor = totalQuantity == 0
                ? inventoryItem == null
                      ? Colors.blueGrey
                      : Colors.red
                : totalQuantity <= 5
                ? Colors.orange
                : Colors.green;

            return Dismissible(
              key: Key(item.id), // Unique key for each item
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('تأكيد الحذف'),
                      content: Text(
                        'هل أنت متأكد أنك تريد إزالة ${item.name}؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('حذف'),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) {
                setState(() {
                  _items.removeAt(index);
                  totalAmount -= item.price * item.quantity;
                  _amountController.text = totalAmount.toString();
                  _discountController.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تمت إزالة ${item.name}'),
                    action: SnackBarAction(
                      label: 'تراجع',
                      onPressed: () {
                        setState(() {
                          _items.insert(index, item);
                          totalAmount += item.price * item.quantity;
                          _amountController.text = totalAmount.toString();
                        });
                      },
                    ),
                  ),
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Item name and price
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'السعر: \$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quantity display
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: statusColor, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 18,
                              color: statusColor,
                            ),
                            const SizedBox(width: 8.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الكمية: ${item.quantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                    fontSize: 14.0,
                                  ),
                                ),
                                Text(
                                  inventoryItem == null
                                      ? "عنصر خارجي"
                                      : 'في المخزون: $totalQuantity',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Quantity controls
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // remove
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.redAccent,
                            size: 24.0,
                          ),
                          onPressed: () {
                            if (item.quantity > 1) {
                              setState(() {
                                item.quantity--;
                                totalAmount -= item.price;
                                _amountController.text = totalAmount.toString();
                                _discountController.clear();
                              });
                            }
                          },
                        ),
                        //add
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.green,
                            size: 24.0,
                          ),
                          onPressed: () {
                            if (inventoryItem == null ||
                                item.quantity < totalQuantity) {
                              setState(() {
                                item.quantity++;
                                totalAmount += item.price;
                                _amountController.text = totalAmount.toString();
                                _discountController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          Center(
            child: TextButton(
              onPressed: () => _showItemDialog(context),
              child: const Text(
                'إضافة عنصر',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ],
      ),
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
          title: const Text('إضافة عنصر'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<bool>(
                value: isInventoryItem,
                items: const [
                  DropdownMenuItem(value: true, child: Text('من المخزون')),
                  DropdownMenuItem(value: false, child: Text('عنصر خارجي')),
                ],
                onChanged: (value) =>
                    setDialogState(() => isInventoryItem = value!),
              ),
              const SizedBox(height: 10),
              if (isInventoryItem)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'اختر العنصر'),
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
                  decoration: const InputDecoration(labelText: 'اسم العنصر'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'السعر'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
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
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}
