import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/models/invoice.dart';

// Widget to display a single invoice in a card
class InvoiceCard extends StatelessWidget {
  final Invoice invoice;

  final VoidCallback onTap;
  final String clientName;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
    required this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: onTap,
        title: Text('Invoice #${invoice.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: $clientName'),
            Text('Amount: \$${invoice.amount.toStringAsFixed(2)}'),
            Text('Issue Date: ${DateFormat.yMMMd().format(invoice.issueDate)}'),
            Text('Paid: ${invoice.isPaid ? 'Yes' : 'No'}'),
          ],
        ),
      ),
    );
  }
}
