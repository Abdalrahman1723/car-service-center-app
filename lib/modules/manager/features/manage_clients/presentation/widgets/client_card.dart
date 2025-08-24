import 'package:flutter/material.dart';
import 'package:m_world/core/constants/app_strings.dart';

import '../../../../../../shared/models/client.dart';

// Widget to display a single client's information in a card with update and delete actions
class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final VoidCallback? onSettleDebt;

  const ClientCard({
    super.key,
    required this.client,
    required this.onUpdate,
    required this.onDelete,
    this.onSettleDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white60,
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
            //show clients cars
            ...client.cars.isNotEmpty
                ? client.cars.map((car) {
                    final type = car['type'] ?? '';
                    final model = car['model'] ?? '';
                    return Text(
                      'السيارة: $type ${model.isNotEmpty ? model : ''}',
                    );
                  }).toList()
                : [const Text('السيارة: لا يوجد سيارات')],
            if (client.phoneNumber != null) ...[
              const SizedBox(height: 4),
              SelectableText('الهاتف: ${client.phoneNumber}'),
            ],
            if (client.email != null) ...[
              const SizedBox(height: 4),
              Text('البريد الإلكتروني: ${client.email}'),
            ],

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: client.balance > 0
                    ? Colors.orange.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: client.balance > 0
                      ? Colors.orange.shade300
                      : Colors.green.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    client.balance > 0
                        ? Icons.account_balance_wallet
                        : Icons.check_circle,
                    size: 16,
                    color: client.balance > 0
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'الرصيد: ${client.balance.toStringAsFixed(2)} ${AppStrings.currency}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: client.balance > 0
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (client.notes != null) ...[
              const SizedBox(height: 4),
              Text('ملاحظات: ${client.notes}'),
            ],
            const SizedBox(height: 16),
            // Action buttons for update, delete, and debt settlement
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Debt settlement button (only show if client has debt)
                if (client.balance > 0 && onSettleDebt != null)
                  TextButton.icon(
                    onPressed: onSettleDebt,
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('تسوية الدين'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                    ),
                  ),
                // Update button triggers callback
                TextButton(
                  onPressed: onUpdate,
                  child: const Text(AppStrings.update),
                ),
                // Delete button triggers callback
                TextButton(
                  onPressed: onDelete,
                  child: const Text(
                    AppStrings.delete,
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
