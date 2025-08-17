import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/modules/manager/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:m_world/modules/manager/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/add_item_to_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/remove_item_from_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/domain/usecases/update_item_in_inventory_usecase.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/cubit/inventory_state.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/widgets/add_item_dialog.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/widgets/edit_item_dialog.dart';
import 'package:m_world/modules/manager/features/inventory/presentation/widgets/item_list_tile.dart';
import 'package:m_world/shared/models/item.dart';

class InventoryPanel extends StatefulWidget {
  const InventoryPanel({super.key});

  @override
  State<InventoryPanel> createState() => _InventoryPanelState();
}

class _InventoryPanelState extends State<InventoryPanel> {
  late InventoryCubit _inventoryCubit;
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

    _inventoryCubit = InventoryCubit(
      getInventoryUseCase: GetInventoryUseCase(repository),
      addItemToInventoryUseCase: AddItemToInventoryUseCase(repository),
      updateItemInInventoryUseCase: UpdateItemInInventoryUseCase(repository),
      removeItemFromInventoryUseCase: RemoveItemFromInventoryUseCase(
        repository,
      ),
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
      child: BlocConsumer<InventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ItemAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تمت إضافة العنصر بنجاح!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ItemUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث العنصر بنجاح!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ItemRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حذف العنصر بنجاح!'),
                backgroundColor: Colors.green,
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
            floatingActionButton: _buildFloatingActionButton(context, state),
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
          const Icon(Icons.car_repair, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            'إدارة المخزون',
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
                    return ItemListTile(
                      item: item,
                      onEdit: () => _showEditItemDialog(context, item),
                      onDelete: () => _showDeleteItemDialog(context, item),
                    );
                  },
                ),
        ),
      ],
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
          'إجمالي القيمة',
          '${inventory.totalValue.toStringAsFixed(2)} ${AppStrings.currency}',
          Icons.attach_money,
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
            'لا توجد عناصر',
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

  Widget _buildFloatingActionButton(
    BuildContext context,
    InventoryState state,
  ) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddItemDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('إضافة عنصر'),
    );
  }

  void _showAddItemDialog(BuildContext context) async {
    final item = await showDialog<Item>(
      context: context,
      builder: (context) =>
          const AddItemDialog(inventoryName: 'المخزون الرئيسي'),
    );

    if (item != null && mounted) {
      await _inventoryCubit.addItemToInventory(item);
    }
  }

  void _showEditItemDialog(BuildContext context, Item item) async {
    final updatedItem = await showDialog<Item>(
      context: context,
      builder: (context) => EditItemDialog(item: item),
    );

    if (updatedItem != null && mounted) {
      // Update the item using the cubit
      await _inventoryCubit.updateItemInInventory(updatedItem);
    }
  }

  void _showDeleteItemDialog(BuildContext context, Item item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العنصر'),
        content: Text('هل أنت متأكد من حذف "${item.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Delete the item using the cubit
      await _inventoryCubit.removeItemFromInventory(item.id);
    }
  }
}
