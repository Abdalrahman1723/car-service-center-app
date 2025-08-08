import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../supplier_management/domain/entities/supplier.dart';
import '../../domain/entities/shipment.dart';

// Reusable widget for displaying shipment details
class ShipmentCard extends StatelessWidget {
  final ShipmentEntity shipment;
  final SupplierEntity? supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShipmentCard({
    super.key,
    required this.shipment,
    this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final remainingAmount = shipment.totalAmount - shipment.paidAmount;
    return Card(
      color: Colors.amber.withOpacity(0.6),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          supplier?.name ?? 'Unknown Supplier',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${supplier?.phoneNumber ?? 'N/A'}'),
            Text('Payment: ${shipment.paymentMethod}'),
            Text('Paid: \$${shipment.paidAmount.toStringAsFixed(2)}'),
            Text('Remaining: \$${remainingAmount.toStringAsFixed(2)}'),
            Text('Items: ${shipment.items.length}'),
            Text('Date: ${DateFormat('yyyy-MM-dd').format(shipment.date)}'),
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
