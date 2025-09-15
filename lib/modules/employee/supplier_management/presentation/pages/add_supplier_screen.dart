import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/supplier.dart';
import '../cubit/suppliers_cubit.dart';
import '../widgets/supplier_form_field.dart';
import 'package:m_world/core/services/auth_service.dart';

// Screen to add or edit a supplier
class AddSupplierScreen extends StatefulWidget {
  final SupplierEntity? supplier;
  final bool isEdit;

  const AddSupplierScreen({super.key, this.supplier, this.isEdit = false});

  @override
  AddSupplierScreenState createState() => AddSupplierScreenState();
}

class AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _balanceController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.supplier != null) {
      _nameController.text = widget.supplier!.name;
      _phoneController.text = widget.supplier!.phoneNumber;
      _balanceController.text = widget.supplier!.balance.toString();
      _notesController.text = widget.supplier!.notes ?? '';
    }
    _loadRole();
  }

  Future<void> _loadRole() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isEdit
          ? AppBar(title: Text("Update Supplier Data"))
          : AppBar(title: Text("Add New Supplier")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<SuppliersCubit, SuppliersState>(
          listener: (context, state) {
            if (state is SuppliersSuccess) {
              Navigator.of(context).pop();
            } else if (state is SuppliersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SupplierFormField(
                      controller: _nameController,
                      label: 'Name *',
                      validator: (value) =>
                          value!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    //phone number
                    SupplierFormField(
                      controller: _phoneController,
                      label: 'Phone Number *',
                      validator: (value) {
                        if (value!.isEmpty) return 'Phone number is required';
                        if (!RegExp(r'^\+?\d{9,}$').hasMatch(value)) {
                          return 'Invalid phone number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    //the balance
                    SupplierFormField(
                      controller: _balanceController,
                      label: _isAdmin ? 'Balance' : 'Balance (admins only)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (!_isAdmin) return null; // non-admin can't edit
                        if (value!.isNotEmpty &&
                            double.tryParse(value) == null) {
                          return 'Invalid balance';
                        }
                        return null;
                      },
                      readOnly: !_isAdmin,
                    ),
                    const SizedBox(height: 16),
                    //add notes
                    SupplierFormField(
                      controller: _notesController,
                      label: 'Notes',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    //------submit button
                    ElevatedButton(
                      onPressed:
                          state is SuppliersAdding || state is SuppliersUpdating
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                // If non-admin on edit, preserve original balance
                                final parsedBalance =
                                    double.tryParse(_balanceController.text) ??
                                    0.0;
                                final effectiveBalance =
                                    !_isAdmin &&
                                        widget.isEdit &&
                                        widget.supplier != null
                                    ? widget.supplier!.balance
                                    : parsedBalance;

                                final supplier = SupplierEntity(
                                  id: widget.supplier?.id ?? '',
                                  name: _nameController.text,
                                  phoneNumber: _phoneController.text,
                                  balance: effectiveBalance,
                                  notes: _notesController.text.isEmpty
                                      ? null
                                      : _notesController.text,
                                  createdAt:
                                      widget.supplier?.createdAt ??
                                      DateTime.now(),
                                );
                                if (widget.isEdit) {
                                  context.read<SuppliersCubit>().updateSupplier(
                                    supplier,
                                  );
                                } else {
                                  context.read<SuppliersCubit>().addSupplier(
                                    supplier,
                                  );
                                }
                              }
                            },
                      child:
                          state is SuppliersAdding || state is SuppliersUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.isEdit
                                  ? 'Update Supplier'
                                  : 'Add Supplier',
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
