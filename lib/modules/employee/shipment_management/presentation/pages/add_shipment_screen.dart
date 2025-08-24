import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/shared/models/item.dart';
import '../../../../manager/features/inventory/data/datasources/inventory_remote_datasource.dart';
import '../../../supplier_management/data/datasources/supplier_datasource.dart';
import '../../../supplier_management/domain/entities/supplier.dart';
import '../../domain/entities/shipment.dart';
import '../cubit/shipments_cubit.dart';

// شاشة إضافة أو تعديل الشحنة
class AddShipmentScreen extends StatefulWidget {
  final ShipmentEntity? shipment;
  final bool isEdit;

  const AddShipmentScreen({super.key, this.shipment, this.isEdit = false});

  @override
  AddShipmentScreenState createState() => AddShipmentScreenState();
}

class AddShipmentScreenState extends State<AddShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSupplierId;
  final List<Item> _items = [];
  String _paymentMethod = 'نقداً';
  final _paidAmountController = TextEditingController();
  final _notesController = TextEditingController();
  List<SupplierEntity> _suppliers = [];
  List<Item> _inventoryItems = [];
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSuppliersAndInventory();
    if (widget.isEdit && widget.shipment != null) {
      _selectedSupplierId = widget.shipment!.supplierId;
      _items.addAll(widget.shipment!.items);
      _paymentMethod = _translatePaymentMethod(widget.shipment!.paymentMethod);
      _paidAmountController.text = widget.shipment!.paidAmount.toString();
      _notesController.text = widget.shipment!.notes ?? '';
      _totalAmount = widget.shipment!.items.fold(
        0,
        (summ, item) => summ + item.cost * item.quantity,
      );
    }
  }

  String _translatePaymentMethod(String englishMethod) {
    switch (englishMethod) {
      case 'Cash':
        return 'نقداً';
      case 'Bank Transfer':
        return 'تحويل بنكي';
      case 'Credit':
        return 'آجل';
      default:
        return 'نقداً';
    }
  }

  String _translatePaymentMethodToEnglish(String arabicMethod) {
    switch (arabicMethod) {
      case 'نقداً':
        return 'Cash';
      case 'تحويل بنكي':
        return 'Bank Transfer';
      case 'آجل':
        return 'Credit';
      default:
        return 'Cash';
    }
  }

  Future<void> _loadSuppliersAndInventory() async {
    final supplierDataSource = SupplierDataSource(FirebaseFirestore.instance);
    final inventoryDataSource = InventoryRemoteDataSourceImpl(
      FirebaseFirestore.instance,
    );
    try {
      final suppliers = await supplierDataSource.getSuppliers();
      final inventory = await inventoryDataSource.getInventory();
      setState(() {
        _suppliers = suppliers.map((model) => model.toEntity()).toList();
        _inventoryItems = inventory.items;
        for (var supplier in _suppliers) {
          context.read<ShipmentsCubit>().cacheSupplier(supplier);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تحميل البيانات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showItemDialog(BuildContext context) {
    bool isInventoryItem = true;
    String? selectedItemId;
    final nameController = TextEditingController();
    final costController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('إضافة منتج'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<bool>(
                    value: isInventoryItem,
                    items: const [
                      DropdownMenuItem(value: true, child: Text('من المخزون')),
                      DropdownMenuItem(value: false, child: Text('منتج جديد')),
                    ],
                    onChanged: (value) => setDialogState(() {
                      isInventoryItem = value!;
                      selectedItemId = null;
                      nameController.clear();
                      costController.clear();
                      codeController.clear();
                    }),
                    decoration: const InputDecoration(
                      labelText: 'مصدر المنتج',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isInventoryItem)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'اختر المنتج',
                        border: OutlineInputBorder(),
                      ),
                      items: _inventoryItems
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(
                                '${item.name} (${item.cost.toStringAsFixed(2)} ${AppStrings.currency})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setDialogState(() {
                        selectedItemId = value;
                        final item = _inventoryItems.firstWhere(
                          (i) => i.id == value,
                        );
                        nameController.text = item.name;
                        costController.text = item.cost.toString();
                        codeController.text = item.code ?? '';
                      }),
                      validator: (value) => value == null && isInventoryItem
                          ? 'يجب اختيار منتج'
                          : null,
                    )
                  else ...[
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المنتج *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'اسم المنتج مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: costController,
                      decoration: const InputDecoration(
                        labelText: 'التكلفة *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'التكلفة مطلوبة';
                        final cost = double.tryParse(value.trim());
                        if (cost == null || cost <= 0) {
                          return 'تكلفة غير صحيحة';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'الكمية *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'الكمية مطلوبة';
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) return 'كمية غير صحيحة';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'الرمز (اختياري)',
                      border: OutlineInputBorder(),
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
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final quantityText = quantityController.text.trim();
                  final quantity = int.tryParse(quantityText);
                  if (quantity == null || quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('الكمية يجب أن تكون رقم موجب'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final code = codeController.text.isEmpty
                      ? null
                      : codeController.text;
                  Item newItem;
                  if (isInventoryItem && selectedItemId != null) {
                    final inventoryItem = _inventoryItems.firstWhere(
                      (i) => i.id == selectedItemId,
                    );
                    newItem = Item(
                      id: inventoryItem.id,
                      name: inventoryItem.name,
                      cost: inventoryItem.cost,
                      quantity: quantity,
                      timeAdded: inventoryItem.timeAdded,
                      code: code,
                    );
                  } else {
                    final costText = costController.text.trim();
                    if (costText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('التكلفة مطلوبة'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final cost = double.tryParse(costText);
                    if (cost == null || cost <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('التكلفة يجب أن تكون رقم موجب'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    newItem = Item(
                      id: DateTime.now().toString(),
                      name: nameController.text,
                      cost: cost,
                      quantity: quantity,
                      timeAdded: DateTime.now(),
                      code: code,
                    );
                  }
                  setState(() {
                    _items.add(newItem);
                    _totalAmount = _items.fold(
                      0,
                      (summ, item) => summ + item.cost * item.quantity,
                    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'تحديث الشحنة' : 'إضافة شحنة جديدة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<ShipmentsCubit, ShipmentsState>(
          listener: (context, state) {
            if (state is ShipmentsSuccess) {
              Navigator.pop(context);
            } else if (state is ShipmentsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (_suppliers.isEmpty || _inventoryItems.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'المورد *',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSupplierId,
                      items: _suppliers
                          .map(
                            (supplier) => DropdownMenuItem(
                              value: supplier.id,
                              child: Text(supplier.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSupplierId = value),
                      validator: (value) =>
                          value == null ? 'المورد مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'المنتجات *',
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
                            final inventoryItem = _inventoryItems.firstWhere(
                              (i) => i.id == item.id,
                              orElse: () => Item(
                                id: item.id,
                                name: item.name,
                                cost: item.cost,
                                quantity: 0,
                                timeAdded: item.timeAdded,
                                code: item.code,
                              ),
                            );
                            final totalQuantity = inventoryItem.quantity;
                            final Color statusColor = totalQuantity == 0
                                ? Colors.red
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
                                        'هل أنت متأكد من حذف ${item.name}؟',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('إلغاء'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
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
                                  _totalAmount = _items.fold(
                                    0,
                                    (summ, item) =>
                                        summ + item.cost * item.quantity,
                                  );
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم حذف ${item.name}'),
                                    action: SnackBarAction(
                                      label: 'تراجع',
                                      onPressed: () {
                                        setState(() {
                                          _items.insert(index, item);
                                          _totalAmount = _items.fold(
                                            0,
                                            (summ, item) =>
                                                summ +
                                                item.cost * item.quantity,
                                          );
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            'التكلفة: ${item.cost.toStringAsFixed(2)} ${AppStrings.currency}',
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
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          border: Border.all(
                                            color: statusColor,
                                            width: 1.2,
                                          ),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                  'في المخزون: $totalQuantity',
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
                                                _items[index] = Item(
                                                  id: item.id,
                                                  name: item.name,
                                                  cost: item.cost,
                                                  quantity: item.quantity - 1,
                                                  timeAdded: item.timeAdded,
                                                  code: item.code,
                                                );
                                                _totalAmount = _items.fold(
                                                  0,
                                                  (summ, item) =>
                                                      summ +
                                                      item.cost * item.quantity,
                                                );
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
                                            setState(() {
                                              _items[index] = Item(
                                                id: item.id,
                                                name: item.name,
                                                cost: item.cost,
                                                quantity: item.quantity + 1,
                                                timeAdded: item.timeAdded,
                                                code: item.code,
                                              );
                                              _totalAmount = _items.fold(
                                                0,
                                                (summ, item) =>
                                                    summ +
                                                    item.cost * item.quantity,
                                              );
                                            });
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
                                'إضافة منتج',
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
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        'المبلغ الإجمالي: ${_totalAmount.toStringAsFixed(2)} ${AppStrings.currency}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'طريقة الدفع *',
                        border: OutlineInputBorder(),
                      ),
                      value: _paymentMethod,
                      items: ['نقداً', 'تحويل بنكي', 'آجل']
                          .map(
                            (method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _paymentMethod = value!),
                      validator: (value) =>
                          value == null ? 'طريقة الدفع مطلوبة' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _paidAmountController,
                      decoration: const InputDecoration(
                        labelText: 'المبلغ المدفوع *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'المبلغ المدفوع مطلوب';
                        }
                        final paid = double.tryParse(value.trim());
                        if (paid == null || paid < 0) {
                          return 'مبلغ غير صحيح';
                        }
                        if (paid > _totalAmount) {
                          return 'المبلغ المدفوع لا يمكن أن يتجاوز المبلغ الإجمالي (${_totalAmount.toStringAsFixed(2)} ${AppStrings.currency})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed:
                          state is AddingShipment || state is UpdatingShipment
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                if (_items.every(
                                  (item) => item.quantity <= 0,
                                )) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'يجب أن يكون هناك منتج واحد على الأقل بكمية أكبر من صفر',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final shipment = ShipmentEntity(
                                  id: widget.shipment?.id ?? '',
                                  supplierId: _selectedSupplierId!,
                                  items: _items,
                                  paymentMethod:
                                      _translatePaymentMethodToEnglish(
                                        _paymentMethod,
                                      ),
                                  totalAmount: _totalAmount,
                                  paidAmount:
                                      double.tryParse(
                                        _paidAmountController.text.trim(),
                                      ) ??
                                      0.0,
                                  date: widget.shipment?.date ?? DateTime.now(),
                                  notes: _notesController.text.isEmpty
                                      ? null
                                      : _notesController.text,
                                );
                                if (widget.isEdit) {
                                  context.read<ShipmentsCubit>().updateShipment(
                                    widget.shipment!,
                                    shipment,
                                  );
                                } else {
                                  context.read<ShipmentsCubit>().addShipment(
                                    shipment,
                                  );
                                }
                              }
                            },
                      child:
                          state is AddingShipment || state is UpdatingShipment
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.isEdit ? 'تحديث الشحنة' : 'إضافة الشحنة',
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
