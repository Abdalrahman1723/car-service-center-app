import 'package:flutter/material.dart';
import 'package:m_world/shared/models/item.dart';

// Reusable widget for selecting item quantity
class ItemQuantitySelector extends StatefulWidget {
  final Item item;
  final Function(int, String?) onQuantityChanged;
  final VoidCallback onRemove;

  const ItemQuantitySelector({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  ItemQuantitySelectorState createState() => ItemQuantitySelectorState();
}

class ItemQuantitySelectorState extends State<ItemQuantitySelector> {
  final _quantityController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.item.quantity.toString();
    _codeController.text = widget.item.code ?? '';
    _quantityController.addListener(() {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      widget.onQuantityChanged(
        quantity,
        _codeController.text.isEmpty ? null : _codeController.text,
      );
    });
    _codeController.addListener(() {
      widget.onQuantityChanged(
        int.tryParse(_quantityController.text) ?? 0,
        _codeController.text.isEmpty ? null : _codeController.text,
      );
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.item.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Code (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: widget.onRemove,
      ),
    );
  }
}
