import 'package:flutter/material.dart';
import 'package:m_world/shared/models/item.dart';

class ItemListTile extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ItemListTile({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getStockColor(context),
          child: Icon(Icons.inventory_2, color: Colors.white, size: 20),
        ),
        title: Text(
          item.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null && item.description!.isNotEmpty)
              Text(
                item.description!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (item.code != null && item.code!.isNotEmpty)
              Text(
                'Code: ${item.code}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildInfoChip(
                      context,
                      'Qty: ${item.quantity}',
                      _getQuantityColor(context),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      '\$${item.price.toStringAsFixed(2)}',
                      Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                //date updated
                _buildInfoChip(
                  context,
                  '${item.timeAdded}',
                  Theme.of(context).hintColor,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 20),
                tooltip: 'Edit Item',
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                tooltip: 'Delete Item',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStockColor(BuildContext context) {
    if (item.quantity == 0) {
      return Colors.red;
    } else if (item.quantity <= 10) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Color _getQuantityColor(BuildContext context) {
    if (item.quantity == 0) {
      return Colors.red;
    } else if (item.quantity <= 10) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
