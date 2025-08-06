import 'package:flutter/material.dart';

import '../../../../../../shared/models/client.dart';

// Widget to display a single client's information in a card with update and delete actions
class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const ClientCard({
    super.key,
    required this.client,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white38,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client name and car type
            SelectableText(
              client.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Car: ${client.carType} ${client.model ?? ''}'),
            if (client.phoneNumber != null) ...[
              const SizedBox(height: 4),
              SelectableText('Phone: ${client.phoneNumber}'),
            ],
            if (client.email != null) ...[
              const SizedBox(height: 4),
              Text('Email: ${client.email}'),
            ],
            if (client.licensePlate != null) ...[
              const SizedBox(height: 4),
              SelectableText('License Plate: ${client.licensePlate}'),
            ],
            const SizedBox(height: 8),
            SelectableText('Balance: \$${client.balance.toStringAsFixed(2)}'),
            if (client.notes != null) ...[
              const SizedBox(height: 4),
              Text('Notes: ${client.notes}'),
            ],
            const SizedBox(height: 16),
            // Action buttons for update and delete
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Update button triggers callback
                TextButton(onPressed: onUpdate, child: const Text('Update')),
                // Delete button triggers callback
                TextButton(
                  onPressed: onDelete,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
