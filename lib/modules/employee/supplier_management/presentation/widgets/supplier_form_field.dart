import 'package:flutter/material.dart';

// Reusable widget for form fields
class SupplierFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;

  const SupplierFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
    );
  }
}