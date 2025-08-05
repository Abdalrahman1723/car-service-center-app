import 'package:flutter/material.dart';
import 'package:m_world/modules/manager/features/inventory/domain/entities/inventory_entity.dart';

class InventoryCard extends StatelessWidget {
  final InventoryEntity inventory;
  final VoidCallback? onTap;
  final bool isSelected;

  const InventoryCard({
    super.key,
    required this.inventory,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      inventory.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    'Items',
                    '${inventory.totalItems}',
                    Icons.inventory,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    'Value',
                    '\$${inventory.totalValue.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                ],
              ),
              if (inventory.lowStockItems.isNotEmpty ||
                  inventory.outOfStockItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      if (inventory.outOfStockItems.isNotEmpty)
                        _buildWarningChip(
                          context,
                          '${inventory.outOfStockItems.length} Out of Stock',
                          Colors.red,
                        ),
                      if (inventory.lowStockItems.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildWarningChip(
                          context,
                          '${inventory.lowStockItems.length} Low Stock',
                          Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningChip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    if (inventory.outOfStockItems.isNotEmpty) {
      return Colors.red;
    } else if (inventory.lowStockItems.isNotEmpty) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getStatusText() {
    if (inventory.outOfStockItems.isNotEmpty) {
      return 'Critical';
    } else if (inventory.lowStockItems.isNotEmpty) {
      return 'Warning';
    } else {
      return 'Good';
    }
  }
}
