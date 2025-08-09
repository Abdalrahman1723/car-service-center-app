import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/employee/shipment_management/presentation/cubit/shipments_cubit.dart';
import '../../../../../config/routes.dart';
import '../../../supplier_management/data/datasources/supplier_datasource.dart';
import '../../../supplier_management/domain/entities/supplier.dart';
import '../widgets/shipment_card.dart';

// Screen to display all shipments
class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  ShipmentsScreenState createState() => ShipmentsScreenState();
}

class ShipmentsScreenState extends State<ShipmentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSuppliers(); // Load all suppliers
    context.read<ShipmentsCubit>().loadShipments(); // Load shipments
  }

  // Load all suppliers and cache them
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
          content: Text('Failed to load suppliers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipments')),
      body: Column(
        children: [
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
                hintText: 'Search by supplier name or phone number',
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
                  final shipments = _searchQuery.isNotEmpty
                      ? state.shipments.where((shipment) {
                          final supplier =
                              state.suppliers[shipment.supplierId] ??
                              SupplierEntity(
                                id: shipment.supplierId,
                                name: 'Unknown Supplier',
                                phoneNumber: '',
                                balance: 0.0,
                                notes: null,
                                createdAt: DateTime.now(),
                              );
                          final nameMatch = supplier.name
                              .toLowerCase()
                              .contains(_searchQuery);
                          final phoneMatch = supplier.phoneNumber
                              .toLowerCase()
                              .contains(_searchQuery);
                          return nameMatch || phoneMatch;
                        }).toList()
                      : state.shipments;
                  if (shipments.isEmpty) {
                    return const Center(child: Text('No shipments found'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: shipments.length,
                    itemBuilder: (context, index) {
                      final shipment = shipments[index];
                      final supplier =
                          state.suppliers[shipment.supplierId] ??
                          SupplierEntity(
                            id: shipment.supplierId,
                            name: 'Unknown Supplier',
                            phoneNumber: '',
                            balance: 0.0,
                            notes: null,
                            createdAt: DateTime.now(),
                          );
                      return ShipmentCard(
                        shipment: shipment,
                        supplier: supplier,
                        onEdit: () =>
                            Navigator.of(context).pushNamed(Routes.addShipment,
                            arguments: {
                              'shipment': shipment,
                              'isEdit': true,
                            }
                            ),
                        onDelete: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Shipment'),
                            content: Text(
                              'Are you sure you want to delete this shipment?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<ShipmentsCubit>().deleteShipment(
                                    shipment,
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
                return const Center(child: Text('Tap to load shipments'));
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
