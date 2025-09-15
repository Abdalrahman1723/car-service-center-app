import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../cubit/suppliers_cubit.dart';
import '../widgets/supplier_card.dart';
import '../widgets/supplier_debt_settlement_dialog.dart';
import 'package:m_world/core/services/auth_service.dart';

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
  bool _isAdmin = false;

  @override
  void initState() {
    context.read<SuppliersCubit>().loadSuppliers();
    super.initState();
    // Automatically load suppliers when the screen initializes
    _searchController.addListener(_filterSuppliers);
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final auth = AuthService();
    final user = auth.currentUser;
    if (user != null) {
      final role = await auth.getUserRole(user.uid);
      if (mounted) {
        setState(() {
          _isAdmin = role == UserRole.admin;
        });
      }
    }
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
        title: const Text('جميع الموردين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة تحميل الموردين',
            onPressed: () {
              context.read<SuppliersCubit>().loadSuppliers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث في الموردين بالاسم أو الهاتف...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
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
                    return _buildEmptySearchState(context);
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
                        onSettleDebt: _isAdmin
                            ? () {
                                SupplierDebtSettlementDialog.show(
                                  context,
                                  supplier,
                                  () => context
                                      .read<SuppliersCubit>()
                                      .loadSuppliers(),
                                );
                              }
                            : null,
                        onDelete: () => showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('حذف المورد'),
                            content: Text(
                              'هل أنت متأكد من حذف ${supplier.name}؟',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text(AppStrings.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<SuppliersCubit>().deleteSupplier(
                                    supplier.id,
                                  );
                                },
                                child: const Text(
                                  AppStrings.delete,
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
                return const Center(child: Text('اضغط لتحميل الموردين'));
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
                      const Text('موردين ندين لهم'),
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
                    label: const Text('مسح الفلاتر'),
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
                    'إجمالي الدين:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${totalDebt.toStringAsFixed(2)} ${AppStrings.currency}',
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
                    'عدد الموردين:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$debtorsCount مورد',
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

  Widget _buildEmptySearchState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد موردين',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تعديل مصطلحات البحث',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
