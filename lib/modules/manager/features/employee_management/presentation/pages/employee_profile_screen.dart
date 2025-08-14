import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/modules/manager/features/employee_management/domain/entities/employee.dart';
import 'package:m_world/modules/manager/features/employee_management/presentation/cubit/employee_management_cubit.dart';

class EmployeeProfileScreen extends StatefulWidget {
  // Change to StatefulWidget
  final String employeeId;
  final String fullName;

  const EmployeeProfileScreen({
    super.key,
    required this.employeeId,
    required this.fullName,
  });

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  // Create a State class
  @override
  void initState() {
    super.initState();
    // This is the missing piece! Tell the cubit to load employees.
    context.read<EmployeeManagementCubit>().startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fullName),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Employee',
                onPressed: () async {
                  // The state is now guaranteed to be loaded when this button is active.
                  final employee =
                      (context.read<EmployeeManagementCubit>().state
                              as EmployeeManagementLoaded)
                          .employees
                          .firstWhere(
                            (e) => e.id == widget.employeeId,
                          ); // Use widget.employeeId
                  Navigator.pushNamed(
                    context,
                    Routes.addEmployee,
                    arguments: {'employee': employee, 'isEdit': true},
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Employee',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<EmployeeManagementCubit, EmployeeManagementState>(
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
            if (state.message.contains('deleted')) {
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          if (state is EmployeeManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EmployeeManagementLoaded) {
            final employee = state.employees.firstWhere(
              (e) => e.id == widget.employeeId,
              orElse: () => Employee(
                id: widget.employeeId,
                fullName: widget.fullName,
                role: '',
                phoneNumber: '',
                address: null,
                salary: null,
                isActive: true,
              ),
            );
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.white60,
                    child: ListTile(
                      title: Text(
                        employee.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Role: ${employee.role}'),
                          SelectableText('Phone: ${employee.phoneNumber}'),
                          Text(
                            'Address: ${employee.address == null || employee.address!.isEmpty ? 'N/A' : employee.address}',
                          ),
                          Text(
                            'Salary: \$${employee.salary != null ? employee.salary!.toStringAsFixed(2) : 'N/A'}',
                          ),
                          Text(
                            'Status: ${employee.isActive ? 'Active' : 'Inactive'}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.employeeAttendance,
                        arguments: {
                          'employee': Employee(
                            id: employee.id,
                            fullName: employee.fullName,
                            role: employee.role,
                            phoneNumber: employee.phoneNumber,
                            address: employee.address,
                            salary: employee.salary,
                            isActive: employee.isActive,
                          ),
                        },
                      );
                    },
                    child: const Text('View Attendance'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Employee not found'));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text(
          'Are you sure you want to delete this employee? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<EmployeeManagementCubit>().deleteEmployee(
                widget.employeeId,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
