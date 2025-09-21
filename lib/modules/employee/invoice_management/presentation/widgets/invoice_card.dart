import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_world/modules/employee/invoice_management/presentation/widgets/invoice_export_button.dart';
import '../../../../../shared/models/invoice.dart';

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

  // Helper method to get payment method display text in Arabic
  String _getPaymentMethodText(String? paymentMethod) {
    switch (paymentMethod) {
      case 'Cash':
        return 'نقداً';
      case 'Credit Card':
        return 'بطاقة ائتمان';
      case 'Bank Transfer':
        return 'تحويل بنكي';
      case 'Instapay':
        return 'انستاباي';
      default:
        return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: invoice.isPayLater ? Colors.red[50] : Colors.green[50],
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: onTap,
        onLongPress: () async {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Print Invoice'),
              content: const Text('Do you want to print/export this invoice?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                InvoiceExportButton(invoice: invoice, clientName: clientName),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row for Invoice Number and Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SelectableText(
                      'Invoice #${invoice.clientId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '\$${invoice.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: invoice.isPayLater
                          ? Colors.red[700]
                          : Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),

              // Client and Car details
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    invoice.selectedCar,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),

              // Payment Method (if available)
              if (invoice.paymentMethod != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.payment, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'طريقة الدفع: ${_getPaymentMethodText(invoice.paymentMethod)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
              ],

              // Date and Payment Status
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Issue Date: ${DateFormat.yMMMd().format(invoice.issueDate).toString()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(
                      invoice.isPayLater ? 'آجل' : 'مدفوع',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: invoice.isPayLater
                        ? Colors.red
                        : Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
