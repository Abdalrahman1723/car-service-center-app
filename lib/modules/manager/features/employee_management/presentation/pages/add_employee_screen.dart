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
    _selectedRole = widget.employee?.role ?? 'أخرى';
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
        title: Text(widget.isEdit ? 'تعديل الموظف' : 'إضافة موظف'),
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
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الاسم الكامل مطلوب' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'الدور',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedRole,
                  items: ['مدير', 'مشرف', 'عامل مخزون', 'أخرى']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedRole = value),
                  validator: (value) => value == null ? 'الدور مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'رقم الهاتف مطلوب' : null,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'الراتب/المعدل بالساعة (اختياري)',
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
                      labelText: 'البريد الإلكتروني (لإنشاء الحساب)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  //password
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور (لإنشاء الحساب)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        _emailController.text.isEmpty && value!.isEmpty
                        ? null
                        : _emailController.text.isEmpty
                        ? "أدخل البريد الإلكتروني أولاً لإنشاء كلمة المرور"
                        : value!.length < 6
                        ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                        : null,
                    obscureText: true,
                  ),
                ],
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('نشط'),
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
                  child: Text(widget.isEdit ? 'تحديث' : 'إضافة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
