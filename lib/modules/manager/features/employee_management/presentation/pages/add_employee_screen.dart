import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/manager/features/employee_management/presentation/cubit/employee_management_cubit.dart';

import '../../domain/entities/employee.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Employee? employee;
  final bool isEdit;

  const AddEmployeeScreen({super.key, this.employee, this.isEdit = false});

  @override
  AddEmployeeScreenState createState() => AddEmployeeScreenState();
}

class AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _salaryController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedRole;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.employee?.fullName ?? '',
    );
    _phoneNumberController = TextEditingController(
      text: widget.employee?.phoneNumber ?? '',
    );
    _addressController = TextEditingController(
      text: widget.employee?.address ?? '',
    );
    _salaryController = TextEditingController(
      text: widget.employee?.salary?.toString() ?? '',
    );
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _selectedRole = widget.employee?.role ?? 'Other';
    _isActive = widget.employee?.isActive ?? true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Employee' : 'Add Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedRole,
                  items: ['Manager', 'Supervisor', 'Inventory Worker', 'Other']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedRole = value),
                  validator: (value) =>
                      value == null ? 'Role is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Phone number is required' : null,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salary/Hourly Rate (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (!widget.isEdit) ...[
                  const SizedBox(height: 12),
                  //email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email  (for creating email)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  //password
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password (for creating email)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        _emailController.text.isEmpty && value!.isEmpty
                        ? null
                        : _emailController.text.isEmpty
                        ? "Enter email first to make the password"
                        : value!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                    obscureText: true,
                  ),
                ],
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value!),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final employee = Employee(
                        id: widget.employee?.id ?? '',
                        fullName: _fullNameController.text,
                        role: _selectedRole!,
                        phoneNumber: _phoneNumberController.text,
                        address: _addressController.text.isNotEmpty
                            ? _addressController.text
                            : null,
                        salary: _salaryController.text.isNotEmpty
                            ? double.parse(_salaryController.text)
                            : null,
                        isActive: _isActive,
                      );
                      if (widget.isEdit) {
                        context.read<EmployeeManagementCubit>().updateEmployee(
                          employee,
                        );
                      } else {
                        context.read<EmployeeManagementCubit>().addEmployee(
                          employee,
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(widget.isEdit ? 'Update' : 'Add'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
