import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/modules/manager/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:m_world/modules/manager/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/cubit/inventory_state.dart';
import 'package:m_world/modules/employee/inventory/presentation/cubit/read_only_inventory_cubit.dart';
import 'package:m_world/shared/models/item.dart';

class RestrictedInventoryPanel extends StatefulWidget {
  const RestrictedInventoryPanel({super.key});

  @override
  State<RestrictedInventoryPanel> createState() =>
      _RestrictedInventoryPanelState();
}

class _RestrictedInventoryPanelState extends State<RestrictedInventoryPanel> {
  late ReadOnlyInventoryCubit _inventoryCubit;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeCubit();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeCubit() {
    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = InventoryRemoteDataSourceImpl(firestore);
    final repository = InventoryRepositoryImpl(remoteDataSource);

    _inventoryCubit = ReadOnlyInventoryCubit(
      getInventoryUseCase: GetInventoryUseCase(repository),
    );

    _loadInventory();
  }

  Future<void> _loadInventory() async {
    await _inventoryCubit.loadInventory();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
  }

  List<Item> _filterItems(List<Item> items, String query) {
    if (query.isEmpty) return items;

    final lowercaseQuery = query.toLowerCase();
    return items.where((item) {
      final name = item.name.toLowerCase();
      final code = (item.code ?? '').toLowerCase();

      return name.contains(lowercaseQuery) || code.contains(lowercaseQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _inventoryCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _inventoryCubit,
      child: BlocConsumer<ReadOnlyInventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: _appBar(context, state),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(child: _buildInventoryContent(context, state)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, InventoryState state) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Row(
        children: [
          const Icon(Icons.inventory_2, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            'عرض المخزون',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryContent(BuildContext context, InventoryState state) {
    if (state is InventoryLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is InventoryLoaded) {
      return _buildItemList(context, state.inventory);
    } else {
      log("loading item error");
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildItemList(BuildContext context, InventoryEntity inventory) {
    // Filter items based on search query
    final itemsToDisplay = _isSearching
        ? _filterItems(inventory.items, _searchController.text)
        : inventory.items;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.inventory_2, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'العناصر',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildInventoryStats(context, inventory),
            ],
          ),
        ),
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildSearchBar(context),
        ),
        Expanded(
          child: itemsToDisplay.isEmpty
              ? _buildEmptySearchState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: itemsToDisplay.length,
                  itemBuilder: (context, index) {
                    final item = itemsToDisplay[index];
                    return _buildRestrictedItemTile(context, item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRestrictedItemTile(BuildContext context, Item item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(Icons.inventory_2, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.code != null && item.code!.isNotEmpty)
              Text('الكود: ${item.code}'),
            Text('الكمية: ${item.quantity}'),
            if (item.description != null && item.description!.isNotEmpty)
              Text('الوصف: ${item.description}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: item.quantity > 0
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.quantity > 0 ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Text(
            item.quantity > 0 ? 'متوفر' : 'غير متوفر',
            style: TextStyle(
              color: item.quantity > 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryStats(BuildContext context, InventoryEntity inventory) {
    return Row(
      children: [
        _buildStatChip(
          context,
          'إجمالي العناصر',
          '${inventory.totalItems}',
          Icons.inventory,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          context,
          'العناصر المتوفرة',
          '${inventory.items.where((item) => item.quantity > 0).length}',
          Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'البحث في العناصر بالاسم أو الكود...',
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
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
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج للبحث',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب البحث بكلمات مختلفة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
