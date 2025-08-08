import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/config/routes.dart';

import '../../domain/entities/supplier.dart';
import '../cubit/suppliers_cubit.dart';
import '../widgets/supplier_form_field.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.supplier != null) {
      _nameController.text = widget.supplier!.name;
      _phoneController.text = widget.supplier!.phoneNumber;
      _balanceController.text = widget.supplier!.balance.toString();
      _notesController.text = widget.supplier!.notes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<SuppliersCubit, SuppliersState>(
          listener: (context, state) {
            if (state is SuppliersSuccess) {
              Navigator.of(context).pushReplacementNamed(Routes.suppliers);
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
                    SupplierFormField(
                      controller: _balanceController,
                      label: 'Balance',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isNotEmpty &&
                            double.tryParse(value) == null) {
                          return 'Invalid balance';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                                final supplier = SupplierEntity(
                                  id: widget.supplier?.id ?? '',
                                  name: _nameController.text,
                                  phoneNumber: _phoneController.text,
                                  balance:
                                      double.tryParse(
                                        _balanceController.text,
                                      ) ??
                                      0.0,
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
