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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Row(
        children: [
          Icon(
            Icons.inventory_2,
            color: Colors.white,
            size: isTablet ? 32 : 28,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Flexible(
            child: Text(
              'عرض المخزون',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 22 : 20,
              ),
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    // Filter items based on search query
    final itemsToDisplay = _isSearching
        ? _filterItems(inventory.items, _searchController.text)
        : inventory.items;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
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
              Icon(
                Icons.inventory_2,
                color: Theme.of(context).primaryColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                'العناصر',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
              const Spacer(),
              _buildInventoryStats(context, inventory),
            ],
          ),
        ),
        // Search Bar
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 12 : 8,
          ),
          child: _buildSearchBar(context),
        ),
        Expanded(
          child: itemsToDisplay.isEmpty
              ? _buildEmptySearchState(context)
              : _buildResponsiveItemList(context, itemsToDisplay),
        ),
      ],
    );
  }

  Widget _buildResponsiveItemList(BuildContext context, List<Item> items) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeScreen = screenSize.width > 900;

    if (isLargeScreen) {
      // Use grid layout for large screens
      return GridView.builder(
        padding: EdgeInsets.all(isTablet ? 16 : 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: isTablet ? 16 : 12,
          mainAxisSpacing: isTablet ? 16 : 12,
          childAspectRatio: 3.5,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildRestrictedItemTile(context, item);
        },
      );
    } else {
      // Use list layout for smaller screens
      return ListView.builder(
        padding: EdgeInsets.all(isTablet ? 16 : 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildRestrictedItemTile(context, item);
        },
      );
    }
  }

  Widget _buildRestrictedItemTile(BuildContext context, Item item) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Card(
      color: Theme.of(context).cardColor,
      margin: EdgeInsets.symmetric(
        vertical: isTablet ? 6 : 4,
        horizontal: isTablet ? 12 : 8,
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          radius: isTablet ? 24 : 20,
          child: Icon(
            Icons.inventory_2,
            color: Theme.of(context).primaryColor,
            size: isTablet ? 24 : 20,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.code != null && item.code!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'الكود: ${item.code}',
                  style: TextStyle(fontSize: isTablet ? 14 : 12),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'الكمية: ${item.quantity}',
                style: TextStyle(fontSize: isTablet ? 14 : 12),
              ),
            ),
            if (item.description != null && item.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'الوصف: ${item.description}',
                  style: TextStyle(fontSize: isTablet ? 14 : 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 8,
            vertical: isTablet ? 6 : 4,
          ),
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
              fontSize: isTablet ? 14 : 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryStats(BuildContext context, InventoryEntity inventory) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Wrap(
      spacing: isTablet ? 12 : 8,
      runSpacing: isTablet ? 8 : 4,
      children: [
        _buildStatChip(
          context,
          'إجمالي العناصر',
          '${inventory.totalItems}',
          Icons.inventory,
          isTablet,
        ),
        _buildStatChip(
          context,
          'العناصر المتوفرة',
          '${inventory.items.where((item) => item.quantity > 0).length}',
          Icons.check_circle,
          isTablet,
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 6 : 4,
      ),
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
          Icon(
            icon,
            size: isTablet ? 18 : 16,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: isTablet ? 6 : 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: isTablet ? 12 : 10),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return TextField(
      controller: _searchController,
      style: TextStyle(fontSize: isTablet ? 16 : 14),
      decoration: InputDecoration(
        hintText: 'البحث في العناصر بالاسم أو الكود...',
        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
        prefixIcon: Icon(Icons.search, size: isTablet ? 24 : 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, size: isTablet ? 24 : 20),
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 16 : 12,
        ),
      ),
    );
  }

  Widget _buildEmptySearchState(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: isTablet ? 80 : 64,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'لا توجد نتائج للبحث',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor.withOpacity(0.7),
              fontSize: isTablet ? 18 : 16,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'جرب البحث بكلمات مختلفة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
