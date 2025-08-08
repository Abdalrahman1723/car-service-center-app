import 'package:flutter/material.dart';

import '../../domain/entities/supplier.dart';

// Reusable widget for displaying supplier details
class SupplierCard extends StatelessWidget {
  final SupplierEntity supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SupplierCard({
    super.key,
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${supplier.phoneNumber}'),
            Text('Balance: \$${supplier.balance.toStringAsFixed(2)}'),
            Text('Items: ${supplier.items.length}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
