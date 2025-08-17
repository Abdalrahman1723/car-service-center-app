import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/shared/models/item.dart';

class EditItemDialog extends StatefulWidget {
  final Item item;

  const EditItemDialog({super.key, required this.item});

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _quantityController;
  late TextEditingController _costController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _codeController = TextEditingController(text: widget.item.code ?? '');
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _costController = TextEditingController(
      text: widget.item.cost.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.item.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          const Text('تعديل العنصر'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'اسم العنصر',
              icon: Icons.inventory_2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'اسم العنصر مطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _codeController,
              label: 'كود العنصر',
              icon: Icons.qr_code,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _quantityController,
                    label: 'الكمية',
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الكمية مطلوبة';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity < 0) {
                        return 'يجب أن تكون الكمية رقم موجب';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _costController,
                    label: 'السعر',
                    icon: Icons.attach_money,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'السعر مطلوب';
                      }
                      final cost = double.tryParse(value);
                      if (cost == null || cost < 0) {
                        return 'يجب أن يكون السعر رقم موجب';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'الوصف (اختياري)',
              icon: Icons.description,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _validateAndSave,
          child: const Text('حفظ التغييرات'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
    );
  }

  void _validateAndSave() {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      _showError('اسم العنصر مطلوب');
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity < 0) {
      _showError('يجب أن تكون الكمية رقم موجب');
      return;
    }

    final cost = double.tryParse(_costController.text);
    if (cost == null || cost < 0) {
      _showError('يجب أن يكون السعر رقم موجب');
      return;
    }

    // Create updated item
    final updatedItem = Item(
      id: widget.item.id,
      name: _nameController.text.trim(),
      code: _codeController.text.trim().isEmpty
          ? null
          : _codeController.text.trim(),
      quantity: quantity,
      cost: cost, 
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      timeAdded: DateTime.now(),
    );

    Navigator.of(context).pop(updatedItem);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
