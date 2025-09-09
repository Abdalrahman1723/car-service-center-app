import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_world/core/constants/app_strings.dart';

import '../../../supplier_management/domain/entities/supplier.dart';
import '../../domain/entities/shipment.dart';
import 'export_shipment_invoice.dart';

// Widget قابل لإعادة الاستخدام لعرض تفاصيل الشحنة
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

  String _translatePaymentMethod(String englishMethod) {
    switch (englishMethod) {
      case 'Cash':
        return 'نقداً';
      case 'Bank Transfer':
        return 'تحويل بنكي';
      case 'Credit':
        return 'آجل';
      default:
        return englishMethod;
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingAmount = shipment.totalAmount - shipment.paidAmount;
    return Card(
      color: Colors.amber.withOpacity(0.6),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          supplier?.name ?? 'مورد غير معروف',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الهاتف: ${supplier?.phoneNumber ?? 'غير متوفر'}'),
            Text(
              'طريقة الدفع: ${_translatePaymentMethod(shipment.paymentMethod)}',
            ),
            Text(
              'المدفوع: ${shipment.paidAmount.toStringAsFixed(2)} ${AppStrings.currency}',
            ),
            Text(
              'المتبقي: ${remainingAmount.toStringAsFixed(2)} ${AppStrings.currency}',
            ),
            Text('المنتجات: ${shipment.items.length}'),
            Text('التاريخ: ${DateFormat('yyyy-MM-dd').format(shipment.date)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.green),
              onPressed: () {
                if (supplier != null) {
                  // Show the export button widget
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('تصدير PDF'),
                      content: ShipmentExportButton(
                        shipment: shipment,
                        supplier: supplier!,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إغلاق'),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'لا يمكن تصدير الفاتورة - معلومات المورد غير متوفرة',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
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
