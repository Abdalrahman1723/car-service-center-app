import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_world/modules/employee/invoice_management/presentation/cubit/invoice_management_cubit.dart';
import 'package:m_world/modules/employee/invoice_management/presentation/widgets/invoice_export_button.dart';
import 'package:m_world/shared/models/invoice.dart';
import 'package:m_world/shared/models/item.dart';
import 'package:m_world/shared/models/client.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import '../../../../../config/routes.dart';
import 'package:flutter/services.dart';

// Screen to add a new invoice for a client
class InvoiceAddScreen extends StatefulWidget {
  final Map<String, dynamic>? draftData;

  const InvoiceAddScreen({super.key, this.draftData});

  @override
  InvoiceAddScreenState createState() => InvoiceAddScreenState();
}

class InvoiceAddScreenState extends State<InvoiceAddScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClientId;
  String? _selectedCar;
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
  List<Client> clients = [];

  @override
  void initState() {
    super.initState();
    context.read<InvoiceManagementCubit>().loadClients();
    context.read<InvoiceManagementCubit>().loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    bool isFormValid =
        _items.isNotEmpty &&
        _selectedClientId != null &&
        _selectedCar != null &&
        (_isPaid ? _paymentMethod != null : true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("New job order"),
        actions: [
          IconButton(
            icon: const Icon(Icons.drafts),
            onPressed: () =>
                Navigator.pushNamed(context, Routes.invoiceDraftList),
          ),
          ElevatedButton(onPressed: () {}, child: const Text('حفظ كمسودة')),
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
          } else if (state is InvoiceManagementClientsLoaded) {
            setState(() {
              clients = state.clients;
            });
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Client dropdown with search dialog
                  _buildClientDropdown(state, clients),
                  const SizedBox(height: 16),
                  // Car dropdown with search dialog
                  _buildCarDropdown(state, clients, context),
                  const SizedBox(height: 16),
                  // Maintenance by field
                  TextFormField(
                    keyboardType: TextInputType.text,
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
                    title: const Text('آجل؟'),
                    value: _isPaid,
                    onChanged: (value) => setState(() => _isPaid = value!),
                  ),
                  // Payment method dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('نقداً')),
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
                        _amountController.text = discountedAmount.toString();
                        _amountController
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: _amountController.text.length),
                        );
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
                        onPressed:
                            (state is InvoiceManagementLoading || !isFormValid)
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
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
                                        selectedCar:
                                            _getSelectedCarDisplayText(),
                                      );
                                }
                                log(
                                  "the selected car is: ${_getSelectedCarDisplayText()}",
                                );
                              },
                        child: state is InvoiceManagementLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Add job order'),
                      ),
                      InvoiceExportButton(
                        clientName: _selectedClientId != null
                            ? clients
                                  .firstWhere(
                                    (element) =>
                                        element.id == _selectedClientId,
                                    orElse: () => Client(
                                      id: '',
                                      name: 'غير معروف',
                                      cars: [],
                                      balance: 0.0,
                                    ),
                                  )
                                  .name
                            : '',
                        invoice: Invoice(
                          id: '',
                          clientId: _selectedClientId ?? 'N/A',
                          amount:
                              double.tryParse(_amountController.text) ?? 0.0,
                          maintenanceBy: _maintenanceByController.text,
                          createdAt: DateTime.now(),
                          items: _items,
                          notes: _notesController.text.isEmpty
                              ? null
                              : _notesController.text,
                          isPaid: _isPaid,
                          paymentMethod: _paymentMethod,
                          discount: double.tryParse(_discountController.text),
                          issueDate: _issueDate ?? DateTime.now(),
                          selectedCar: _getSelectedCarDisplayText(),
                        ),
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

  // Client dropdown with search dialog
  Widget _buildClientDropdown(
    InvoiceManagementState state,
    List<Client> clients,
  ) {
    final selectedClient = _selectedClientId != null
        ? clients.firstWhere(
            (c) => c.id == _selectedClientId,
            orElse: () =>
                Client(id: '', name: 'غير معروف', cars: [], balance: 0.0),
          )
        : null;

    return GestureDetector(
      onTap: () => _showClientSelectionDialog(context, clients),
      child: AbsorbPointer(
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'اختر العميل *',
            border: OutlineInputBorder(),
          ),
          value: _selectedClientId,
          items: clients
              .map(
                (client) => DropdownMenuItem<String>(
                  value: client.id,
                  child: Text(
                    '${client.name} (${client.phoneNumber ?? 'بدون رقم'})',
                  ),
                ),
              )
              .toList(),
          onChanged: (_) {},
          hint: Text(
            selectedClient != null
                ? '${selectedClient.name} (${selectedClient.phoneNumber ?? 'بدون رقم'})'
                : 'اختر العميل',
          ),
          validator: (value) =>
              _selectedClientId == null ? 'العميل مطلوب' : null,
        ),
      ),
    );
  }

  // Car dropdown with search dialog
  Widget _buildCarDropdown(
    InvoiceManagementState state,
    List<Client> clients,
    BuildContext context,
  ) {
    final selectedClient = _selectedClientId != null
        ? clients.firstWhere(
            (c) => c.id == _selectedClientId,
            orElse: () =>
                Client(id: '', name: 'غير معروف', cars: [], balance: 0.0),
          )
        : null;
    final cars = selectedClient?.cars ?? [];
    final selectedCar = _selectedCar != null && cars.isNotEmpty
        ? cars.firstWhere(
            (c) =>
                '${c['type'] ?? ''}_${c['licensePlate'] ?? ''}' == _selectedCar,
            orElse: () => {'type': 'غير معروف', 'licensePlate': 'غير معروف'},
          )
        : null;

    return GestureDetector(
      onTap: _selectedClientId != null
          ? () => _showCarSelectionDialog(context, _selectedClientId!, cars)
          : null,
      child: AbsorbPointer(
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'اختر السيارة *',
            border: OutlineInputBorder(),
          ),
          value: _selectedCar,
          items: cars
              .map(
                (car) => DropdownMenuItem<String>(
                  value: '${car['type'] ?? ''}_${car['licensePlate'] ?? ''}',
                  child: Text(
                    '${car['type'] ?? 'غير محدد'} (${car['licensePlate'] ?? 'بدون لوحة'})',
                  ),
                ),
              )
              .toList(),
          onChanged: (_) {},
          hint: Text(
            selectedCar != null
                ? '${selectedCar['type'] ?? 'غير محدد'} (${selectedCar['licensePlate'] ?? 'بدون لوحة'})'
                : 'اختر السيارة',
          ),
          validator: (value) =>
              _selectedClientId != null && _selectedCar == null
              ? 'السيارة مطلوبة'
              : null,
        ),
      ),
    );
  }

  // Dialog for client selection with search
  void _showClientSelectionDialog(BuildContext context, List<Client> clients) {
    final searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredClients = clients
                .where(
                  (client) =>
                      client.name.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      ) ||
                      (client.phoneNumber?.toLowerCase().contains(
                            searchController.text.toLowerCase(),
                          ) ??
                          false),
                )
                .toList();

            return AlertDialog(
              title: const Text('اختر العميل'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'ابحث عن العميل',
                          hintText: 'الاسم أو رقم الهاتف',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredClients.length,
                          itemBuilder: (context, index) {
                            final client = filteredClients[index];
                            return ListTile(
                              title: Text(client.name),
                              subtitle: Text(client.phoneNumber ?? 'بدون رقم'),
                              onTap: () {
                                setState(() {
                                  _selectedClientId = client.id;
                                  _selectedCar = null;
                                });
                                Navigator.pop(dialogContext);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.clientManagement),
                  child: const Text('إضافة عميل جديد'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog for car selection with search
  void _showCarSelectionDialog(
    BuildContext context,
    String clientId,
    List<Map<String, dynamic>> cars,
  ) {
    // Get the cubit from the parent context
    final invoiceManagementCubit = BlocProvider.of<InvoiceManagementCubit>(
      context,
    );
    final searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCars = cars
                .where(
                  (car) =>
                      (car['type']?.toLowerCase()?.contains(
                            searchController.text.toLowerCase(),
                          ) ??
                          false) ||
                      (car['licensePlate']?.toLowerCase()?.contains(
                            searchController.text.toLowerCase(),
                          ) ??
                          false),
                )
                .toList();

            return AlertDialog(
              title: const Text('اختر السيارة'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'ابحث عن السيارة',
                          hintText: 'النوع أو لوحة السيارة',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredCars.length,
                          itemBuilder: (context, index) {
                            final car = filteredCars[index];
                            return ListTile(
                              title: Text(car['type'] ?? 'غير محدد'),
                              subtitle: Text(
                                car['licensePlate'] ?? 'بدون لوحة',
                              ),
                              onTap: () {
                                setState(() {
                                  // Use a unique identifier for the car
                                  _selectedCar =
                                      '${car['type'] ?? ''}_${car['licensePlate'] ?? ''}';
                                });
                                Navigator.pop(dialogContext);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () async {
                    final carData = await _showAddCarDialog(
                      context,
                      dialogContext,
                      clientId,
                      invoiceManagementCubit,
                    );
                    if (carData != null) {
                      setState(() {
                        cars.add(carData);
                      });
                    }
                  },
                  child: const Text('إضافة سيارة جديدة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog to add a new car to an existing client
  Future<Map<String, dynamic>?> _showAddCarDialog(
    BuildContext context,
    BuildContext dialogContext,
    String clientId,
    InvoiceManagementCubit invoiceManagementCubit,
  ) async {
    final carTypeController = TextEditingController();
    final carModelController = TextEditingController();
    final licensePlateNumberController = TextEditingController();
    final licensePlateLetterController = TextEditingController();

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (addCarContext) => AlertDialog(
        title: const Text('إضافة سيارة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carTypeController,
                decoration: const InputDecoration(labelText: 'نوع السيارة *'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: carModelController,
                decoration: const InputDecoration(labelText: 'الموديل'),
              ),
              SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: licensePlateNumberController,
                      decoration: const InputDecoration(
                        labelText: 'أرقام اللوحة',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[0-9 ]*')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: licensePlateLetterController,
                      decoration: const InputDecoration(
                        labelText: 'حروف اللوحة',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^[a-zA-Z\u0600-\u06FF ]*'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(addCarContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (carTypeController.text.isEmpty) {
                ScaffoldMessenger.of(addCarContext).showSnackBar(
                  const SnackBar(
                    content: Text('نوع السيارة مطلوب'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              String licensePlate = '';
              if (licensePlateNumberController.text.trim().isNotEmpty ||
                  licensePlateLetterController.text.trim().isNotEmpty) {
                licensePlate =
                    '${licensePlateNumberController.text.trim()} / ${licensePlateLetterController.text.trim()}';
              }
              // Use the passed cubit instance
              final carData = {
                'type': carTypeController.text,
                'model': carModelController.text.isEmpty
                    ? null
                    : carModelController.text,
                'licensePlate': licensePlate.isEmpty ? null : licensePlate,
              };
              invoiceManagementCubit.addCarToClient(clientId, carData);
              Navigator.pop(addCarContext, carData);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
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
              key: Key(item.id),
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
                  totalAmount -= (item.price ?? 0.0) * item.quantity;
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
                          totalAmount += (item.price ?? 0.0) * item.quantity;
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
                            'السعر: \$${item.price?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                                totalAmount -= item.price ?? 0.0;
                                _amountController.text = totalAmount.toString();
                                _discountController.clear();
                              });
                            }
                          },
                        ),
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
                                totalAmount += item.price ?? 0.0;
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
                              child: Text(
                                '${item.name} (المخزون: ${item.quantity})',
                              ),
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
                    }
                  },
                )
              else
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم العنصر'),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'سعر البيع *'),
                keyboardType: TextInputType.number,
              ),
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
                  final price = double.tryParse(priceController.text) ?? 0.0;
                  final inventoryItem = isInventoryItem && _inventory != null
                      ? _inventory!.items.firstWhere(
                          (i) => i.name == nameController.text,
                          orElse: () => Item(
                            id: '',
                            name: nameController.text,
                            quantity: 0,
                            code: null,
                            price: null,
                            cost: 0.0,
                            timeAdded: null,
                            description: null,
                          ),
                        )
                      : null;
                  setState(() {
                    final item = Item(
                      id: DateTime.now().toString(),
                      name: nameController.text,
                      quantity: 1,
                      code: inventoryItem?.code,
                      price: price,
                      cost: inventoryItem?.cost ?? 0.0,
                      timeAdded: DateTime.now(),
                      description: inventoryItem?.description,
                    );
                    _items.add(item);
                    totalAmount += price;
                    _amountController.text = totalAmount.toString();
                    _discountController.clear();
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

  // Helper method to get the display text for the selected car
  String _getSelectedCarDisplayText() {
    if (_selectedCar == null || clients.isEmpty) return '';

    final selectedClient = clients.firstWhere(
      (c) => c.id == _selectedClientId,
      orElse: () => Client(id: '', name: 'غير معروف', cars: [], balance: 0.0),
    );

    final selectedCarData = selectedClient.cars.firstWhere(
      (c) => '${c['type'] ?? ''}_${c['licensePlate'] ?? ''}' == _selectedCar,
      orElse: () => {'type': 'غير معروف', 'licensePlate': 'غير معروف'},
    );

    return '${selectedCarData['type'] ?? 'غير محدد'} (${selectedCarData['licensePlate'] ?? 'بدون لوحة'})';
  }
}
