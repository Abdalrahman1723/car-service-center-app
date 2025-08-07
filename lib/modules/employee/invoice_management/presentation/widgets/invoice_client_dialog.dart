import 'package:flutter/material.dart';
import '../../../../../shared/models/client.dart';

// Widget to display client details for an invoice
class InvoiceClientDialog {
  static void show(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Client Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${client.name}'),
            if (client.phoneNumber != null)
              Text('Phone: ${client.phoneNumber}'),
            Text('Car: ${client.carType} ${client.model ?? ''}'),
            Text('Balance: \$${client.balance.toStringAsFixed(2)}'),
            if (client.email != null) Text('Email: ${client.email}'),
            if (client.licensePlate != null)
              Text('License Plate: ${client.licensePlate}'),
            if (client.notes != null) Text('Notes: ${client.notes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}