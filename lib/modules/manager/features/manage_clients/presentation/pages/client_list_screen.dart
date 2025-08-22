import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/modules/manager/features/manage_clients/presentation/widgets/client_card.dart';
import 'package:m_world/shared/models/client.dart';

import '../cubit/client_management_cubit.dart';
import '../widgets/update_dialog.dart';

// Screen to display all clients in a card-based layout with update and delete options
class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showOnlyDebtors = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<ClientManagementCubit>().loadClients();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
  }

  List<Client> _filterClients(List<Client> clients, String query) {
    if (query.isEmpty) return clients;

    final lowercaseQuery = query.toLowerCase();
    return clients.where((client) {
      final name = client.name.toLowerCase();
      final phoneNumber = (client.phoneNumber ?? '').toLowerCase();

      return name.contains(lowercaseQuery) ||
          phoneNumber.contains(lowercaseQuery);
    }).toList();
  }

  List<Client> _filterDebtors(List<Client> clients) {
    if (!_showOnlyDebtors) return clients;
    return clients.where((client) => client.balance != 0).toList();
  }

  double _calculateTotalDebt(List<Client> clients) {
    return clients
        .where((client) => client.balance != 0)
        .fold(0.0, (sum, client) => sum + client.balance);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جميع العملاء')),
      body: BlocConsumer<ClientManagementCubit, ClientManagementState>(
        listener: (context, state) {
          // Handle success and error states with snackbar notifications
          if (state is ClientManagementSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // Reload clients after update or delete
            context.read<ClientManagementCubit>().loadClients();
          } else if (state is ClientManagementError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          // Display loading indicator while fetching clients
          if (state is ClientManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Display client list when loaded
          else if (state is ClientManagementClientsLoaded) {
            if (state.clients.isEmpty) {
              return const Center(child: Text('لا توجد عملاء'));
            }

            // Apply filters
            List<Client> filteredClients = state.clients;

            // Apply debt filter first
            filteredClients = _filterDebtors(filteredClients);

            // Then apply search filter
            if (_isSearching) {
              filteredClients = _filterClients(
                filteredClients,
                _searchController.text,
              );
            }

            // Calculate total debt for debtors
            final totalDebt = _calculateTotalDebt(state.clients);
            final debtorsCount = state.clients
                .where((client) => client.balance != 0)
                .length;

            return Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSearchBar(context),
                ),
                // Debt Filter and Summary
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildDebtFilterAndSummary(
                    context,
                    totalDebt,
                    debtorsCount,
                  ),
                ),
                // Client List
                Expanded(
                  child: filteredClients.isEmpty
                      ? _buildEmptySearchState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: filteredClients.length,
                          itemBuilder: (context, index) {
                            final client = filteredClients[index];
                            // Use ClientCard widget with correct context for actions
                            return ClientCard(
                              client: client,
                              onUpdate: () =>
                                  ClientUpdateDialog.show(context, client),
                              onDelete: () {
                                // Use context from ListView.builder for dialog
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('حذف العميل'),
                                    content: Text(
                                      'هل أنت متأكد من حذف ${client.name}؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: const Text(AppStrings.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Use context from ListView.builder for cubit access
                                          context
                                              .read<ClientManagementCubit>()
                                              .deleteClient(client.id);
                                          Navigator.pop(dialogContext);
                                        },
                                        child: const Text(
                                          AppStrings.delete,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }
          // Display initial state with loading prompt
          return const Center(child: Text('جاري تحميل العملاء...'));
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'البحث في العملاء بالاسم أو الهاتف أو رقم اللوحة...',
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

  Widget _buildDebtFilterAndSummary(
    BuildContext context,
    double totalDebt,
    int debtorsCount,
  ) {
    return Card(
      color: Colors.orange.shade50,
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
                        },
                      ),
                      const Text('عرض المدينين فقط'),
                    ],
                  ),
                ),
                if (_showOnlyDebtors || _isSearching)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showOnlyDebtors = false;
                        _searchController.clear();
                      });
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
                    'عدد المدينين:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$debtorsCount عميل',
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
            'لا توجد عملاء',
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
