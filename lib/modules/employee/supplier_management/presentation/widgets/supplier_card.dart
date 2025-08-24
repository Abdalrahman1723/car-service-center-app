import 'package:flutter/material.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../domain/entities/supplier.dart';

// Reusable widget for displaying supplier details
class SupplierCard extends StatelessWidget {
  final SupplierEntity supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSettleDebt;

  const SupplierCard({
    super.key,
    required this.supplier,
    required this.onEdit,
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
            // Supplier name
            SelectableText(
              supplier.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Phone number
            SelectableText('الهاتف: ${supplier.phoneNumber}'),

            const SizedBox(height: 8),

            // Balance with visual indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: supplier.balance > 0
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: supplier.balance > 0
                      ? Colors.red.shade300
                      : Colors.green.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    supplier.balance > 0
                        ? Icons.account_balance_wallet
                        : Icons.check_circle,
                    size: 16,
                    color: supplier.balance > 0
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'الرصيد: ${supplier.balance.toStringAsFixed(2)} ${AppStrings.currency}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: supplier.balance > 0
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons for edit, delete, and debt settlement
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Debt settlement button (only show if supplier has debt)
                if (supplier.balance > 0 && onSettleDebt != null)
                  TextButton.icon(
                    onPressed: onSettleDebt,
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('تسوية الدين'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                    ),
                  ),
                // Edit button
                TextButton(
                  onPressed: onEdit,
                  child: const Text(AppStrings.update),
                ),
                // Delete button
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
