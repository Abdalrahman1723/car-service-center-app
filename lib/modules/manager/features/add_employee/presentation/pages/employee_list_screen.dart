import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/config/routes.dart';
import '../../domain/entities/employee.dart';
import '../cubit/employee_management_cubit.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  EmployeeListScreenState createState() => EmployeeListScreenState();
}

class EmployeeListScreenState extends State<EmployeeListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedRole;
  bool? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    context.read<EmployeeManagementCubit>().startListening();
  }

  void _applyFilters() {
    context.read<EmployeeManagementCubit>().startListening(
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      role: _selectedRole,
      isActive: _selectedStatus,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    // _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userRole = FirebaseAuth.instance.currentUser != null
        ? context.read<EmployeeManagementCubit>().state
                  is EmployeeManagementLoaded
              ? (context.read<EmployeeManagementCubit>().state
                        as EmployeeManagementLoaded)
                    .employees
              : <Employee>[]
                    .firstWhere(
                      (e) => e.id == FirebaseAuth.instance.currentUser!.uid,
                      orElse: () => const Employee(
                        id: '',
                        fullName: '',
                        role: 'manager',
                        phoneNumber: '',
                      ),
                    )
                    .role
        : 'manager';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          if (userRole == 'manager')
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Employee',
              onPressed: () => Navigator.pushNamed(context, Routes.addEmployee),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<EmployeeManagementCubit, EmployeeManagementState>(
              listener: (context, state) {
                if (state is EmployeeManagementError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else if (state is EmployeeManagementSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is EmployeeManagementLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EmployeeManagementLoaded) {
                  log('Loaded ${state.employees.length} employees');
                  if (state.employees.isEmpty) {
                    return const Center(
                      child: Text(
                        'No employees found. Try adding one or adjusting filters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemExtent: 80.0,
                    itemCount: state.employees.length,
                    itemBuilder: (context, index) {
                      final employee = state.employees[index];
                      return _buildEmployeeCard(
                        context,
                        employee,
                        userRole as String,
                      );
                    },
                  );
                }
                return const Center(
                  child: Text(
                    'No employees loaded. Tap refresh to try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(
    BuildContext context,
    Employee employee,
    String userRole,
  ) {
    return Card(
      color: employee.isActive ? Colors.green.shade500 : Colors.red.shade300,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(child: Text(employee.fullName[0])),
        title: Text(
          employee.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${employee.role} • ${employee.isActive ? 'Active' : 'Inactive'}',
        ),
        trailing: userRole == 'manager'
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Employee',
                onPressed: () => _confirmDelete(context, employee),
              )
            : null,
        onTap: () => Navigator.pushNamed(
          context,
          "",
          // Routes.employeeProfile,
          arguments: {'employee': employee},
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String? tempRole = _selectedRole;
    bool? tempStatus = _selectedStatus;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Employees'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  value: tempRole,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...[
                      'Manager',
                      'Supervisor',
                      'Inventory Worker',
                      'Other',
                    ].map((r) => DropdownMenuItem(value: r, child: Text(r))),
                  ],
                  onChanged: (value) => setDialogState(() => tempRole = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<bool>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: tempStatus,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    const DropdownMenuItem(value: true, child: Text('Active')),
                    const DropdownMenuItem(
                      value: false,
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => tempStatus = value),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedRole = null;
                _selectedStatus = null;
              });
              _applyFilters();
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedRole = tempRole;
                _selectedStatus = tempStatus;
              });
              _applyFilters();
              Navigator.pop(dialogContext);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<EmployeeManagementCubit>().deleteEmployee(
                employee.id,
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
