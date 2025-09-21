import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/employee/shipment_management/presentation/cubit/shipments_cubit.dart';
import '../../../../../config/routes.dart';
import '../../../supplier_management/data/datasources/supplier_datasource.dart';
import '../../../supplier_management/domain/entities/supplier.dart';
import '../widgets/shipment_card.dart';

// شاشة عرض جميع الشحنات
class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  ShipmentsScreenState createState() => ShipmentsScreenState();
}

class ShipmentsScreenState extends State<ShipmentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter variables
  String? _selectedPaymentMethod;
  String? _selectedSupplierId;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;
  bool _showFilters = false;

  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSuppliers(); // تحميل جميع الموردين
    context.read<ShipmentsCubit>().loadShipments(); // تحميل الشحنات
  }

  // تحميل جميع الموردين وتخزينهم
  Future<void> _loadSuppliers() async {
    final supplierDataSource = SupplierDataSource(FirebaseFirestore.instance);
    try {
      final suppliers = await supplierDataSource.getSuppliers();
      for (var supplier in suppliers) {
        context.read<ShipmentsCubit>().cacheSupplier(supplier.toEntity());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تحميل الموردين: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedPaymentMethod = null;
      _selectedSupplierId = null;
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  void _applyFilters() {
    setState(() {
      _minAmount = _minAmountController.text.isNotEmpty
          ? double.tryParse(_minAmountController.text)
          : null;
      _maxAmount = _maxAmountController.text.isNotEmpty
          ? double.tryParse(_maxAmountController.text)
          : null;
      _showFilters = false;
    });
  }

  List<dynamic> _getFilteredShipments(
    List<dynamic> shipments,
    Map<String, SupplierEntity> suppliers,
  ) {
    return shipments.where((shipment) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final supplier =
            suppliers[shipment.supplierId] ??
            SupplierEntity(
              id: shipment.supplierId,
              name: 'مورد غير معروف',
              phoneNumber: '',
              balance: 0.0,
              notes: null,
              createdAt: DateTime.now(),
            );
        final nameMatch = supplier.name.toLowerCase().contains(_searchQuery);
        final phoneMatch = supplier.phoneNumber.toLowerCase().contains(
          _searchQuery,
        );
        if (!nameMatch && !phoneMatch) return false;
      }

      // Payment method filter
      if (_selectedPaymentMethod != null) {
        final paymentMethodMap = {
          'نقداً': 'Cash',
          'تحويل بنكي': 'Bank Transfer',
          'آجل': 'Credit',
        };
        if (shipment.paymentMethod !=
            paymentMethodMap[_selectedPaymentMethod]) {
          return false;
        }
      }

      // Supplier filter
      if (_selectedSupplierId != null &&
          shipment.supplierId != _selectedSupplierId) {
        return false;
      }

      // Date range filter
      if (_startDate != null && shipment.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null &&
          shipment.date.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }

      // Amount range filter
      if (_minAmount != null && shipment.totalAmount < _minAmount!) {
        return false;
      }
      if (_maxAmount != null && shipment.totalAmount > _maxAmount!) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشحنات'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            tooltip: _showFilters ? 'إخفاء المرشحات' : 'إظهار المرشحات',
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة تحميل الشحنات',
            onPressed: () {
              _loadSuppliers();
              context.read<ShipmentsCubit>().loadShipments();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'البحث باسم المورد أو رقم الهاتف',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // Filters section
          if (_showFilters) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'مرشحات البحث',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('مسح الكل'),
                          ),
                          const SizedBox(width: 8.0),
                          ElevatedButton(
                            onPressed: _applyFilters,
                            child: const Text('تطبيق'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Payment method filter
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'طريقة الدفع',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'نقداً', child: Text('نقداً')),
                      DropdownMenuItem(
                        value: 'تحويل بنكي',
                        child: Text('تحويل بنكي'),
                      ),
                      DropdownMenuItem(value: 'آجل', child: Text('آجل')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12.0),

                  // Supplier filter
                  BlocBuilder<ShipmentsCubit, ShipmentsState>(
                    builder: (context, state) {
                      if (state is ShipmentsLoaded) {
                        return DropdownButtonFormField<String>(
                          value: _selectedSupplierId,
                          decoration: const InputDecoration(
                            labelText: 'المورد',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('جميع الموردين'),
                            ),
                            ...state.suppliers.values.map(
                              (supplier) => DropdownMenuItem(
                                value: supplier.id,
                                child: Text(supplier.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSupplierId = value;
                            });
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 12.0),

                  // Date range filters
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20.0),
                                const SizedBox(width: 8.0),
                                Text(
                                  _startDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                      : 'من تاريخ',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: _startDate ?? DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20.0),
                                const SizedBox(width: 8.0),
                                Text(
                                  _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'إلى تاريخ',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),

                  // Amount range filters
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minAmountController,
                          decoration: const InputDecoration(
                            labelText: 'الحد الأدنى للمبلغ',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextFormField(
                          controller: _maxAmountController,
                          decoration: const InputDecoration(
                            labelText: 'الحد الأقصى للمبلغ',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],

          // Shipments list
          Expanded(
            child: BlocConsumer<ShipmentsCubit, ShipmentsState>(
              listener: (context, state) {
                if (state is ShipmentsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is ShipmentsSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ShipmentsLoading || state is SearchingShipments) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ShipmentsLoaded) {
                  final filteredShipments = _getFilteredShipments(
                    state.shipments,
                    state.suppliers,
                  );

                  if (filteredShipments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64.0,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            _searchQuery.isNotEmpty ||
                                    _selectedPaymentMethod != null ||
                                    _selectedSupplierId != null ||
                                    _startDate != null ||
                                    _endDate != null ||
                                    _minAmount != null ||
                                    _maxAmount != null
                                ? 'لا توجد شحنات تطابق المرشحات المحددة'
                                : 'لا توجد شحنات',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchQuery.isNotEmpty ||
                              _selectedPaymentMethod != null ||
                              _selectedSupplierId != null ||
                              _startDate != null ||
                              _endDate != null ||
                              _minAmount != null ||
                              _maxAmount != null)
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('مسح المرشحات'),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredShipments.length,
                    itemBuilder: (context, index) {
                      final shipment = filteredShipments[index];
                      final supplier =
                          state.suppliers[shipment.supplierId] ??
                          SupplierEntity(
                            id: shipment.supplierId,
                            name: 'مورد غير معروف',
                            phoneNumber: '',
                            balance: 0.0,
                            notes: null,
                            createdAt: DateTime.now(),
                          );
                      return ShipmentCard(
                        shipment: shipment,
                        supplier: supplier,
                        onEdit: () => Navigator.of(context).pushNamed(
                          Routes.addShipment,
                          arguments: {'shipment': shipment, 'isEdit': true},
                        ),
                        onDelete: () => showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('حذف الشحنة'),
                            content: const Text(
                              'هل أنت متأكد من حذف هذه الشحنة؟',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<ShipmentsCubit>().deleteShipment(
                                    shipment,
                                  );
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'حذف',
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
                return const Center(child: Text('اضغط لتحميل الشحنات'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.addShipment),
        child: const Icon(Icons.add),
      ),
    );
  }
}
