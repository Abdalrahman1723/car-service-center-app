import 'package:flutter/material.dart';
import 'package:m_world/core/constants/app_strings.dart';

import '../../domain/entities/vault_transaction.dart';

class TransactionCard extends StatelessWidget {
  final VaultTransaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = transaction.type == 'income' ? Colors.green : Colors.red;
    return Card(
      color: color.shade200,
      child: ListTile(
        leading: Icon(
          transaction.type == 'income'
              ? Icons.arrow_upward
              : Icons.arrow_downward,
          color: color,
        ),
        title: Text('${transaction.category} - ${transaction.notes ?? ''}'),
        subtitle: Text(transaction.date.toString()),
        trailing: Column(
          children: [
            Text(
              '${transaction.type == 'income' ? '+' : '-'}${transaction.amount} ${AppStrings.currency}',
              style: TextStyle(color: color),
            ),
            Text(
              'الرصيد: ${transaction.runningBalance} ${AppStrings.currency}',
            ),
          ],
        ),
        onTap: onEdit,
        onLongPress: onDelete,
      ),
    );
  }
}
